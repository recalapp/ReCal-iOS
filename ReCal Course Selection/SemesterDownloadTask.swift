//
//  SemesterDownloadTask.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/25/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class SemesterDownloadTask : NSObject {
    
    let progress: NSProgress
    let downloadPromise: Promise<NSArray, NSError>
    let importPromise: Promise<NSObject, NSError>
    let termCode: String
    let limit: Int
    let offset: Int
    
    private var urlString: String {
        return Urls.courses(semesterTermCode: self.termCode, limit: self.limit, offset: self.offset)
    }
    
    private let granularity: Int64 = 100
    
    /// DFA state
    private var downloadState: DownloadState = .Preparing {
        willSet {
            switch downloadState {
            case .Preparing:
                break
            case .Downloading(let progress):
                progress.removeObserver(self, forKeyPath: "fractionCompleted")
                progress.removeObserver(self, forKeyPath: "cancelled")
            case .Importing(let progress):
                progress.removeObserver(self, forKeyPath: "fractionCompleted")
                progress.removeObserver(self, forKeyPath: "cancelled")
            case .Finished:
                assertionFailure("Not allowed to leave Finished state")
            }
        }
        didSet {
            switch downloadState {
            case .Preparing:
                assertionFailure("Not allowed to come back to preparing state")
            case .Downloading:
                break
            case .Importing:
                break
            case .Finished:
                break
            }
            self.progress.completedUnitCount = Int64(self.downloadState.progressFraction * Double(self.granularity))
        }
    }
    
    init(termCode: String, limit: Int, offset: Int) {
        assert(limit >= 0)
        assert(offset >= 0)
        self.progress = NSProgress(totalUnitCount: self.granularity)
        self.downloadPromise = Promise()
        self.importPromise = Promise()
        self.termCode = termCode
        self.limit = limit
        self.offset = offset
        super.init()
        self.downloadPromise.onFailure {(_) in
            self.progress.cancel()
        }
        self.importPromise.onFailure {(_) in
            self.progress.cancel()
        }
        self.initializeDownload()
    }
    
    private func initializeDownload() {
        switch self.downloadState {
        case .Preparing:
            let queue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
            let courseServerCommunication = ServerCommunicator.OneTimeServerCommunication(identifier: "Courses-\(self.termCode)-\(self.limit)-\(self.offset)", urlString: self.urlString) { (result: ServerCommunicator.Result) in
                queue.addOperationWithBlock {
                    switch result {
                    case .Success(_, let data):
                        var errorOpt: NSError?
                        let downloadedDictionaryOpt = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &errorOpt) as? NSArray // NSDictionary
                        if let error = errorOpt {
                            println("Error parsing JSON data. Error: \(error)")
                            self.downloadPromise.failWith(error)
                            return
                        }
                        if let downloadedDictionary = downloadedDictionaryOpt {
                            self.downloadPromise.succeedWith(downloadedDictionary)
                            self.advanceToImportState(data: NSKeyedArchiver.archivedDataWithRootObject(downloadedDictionary))
                        } else {
                            let error = NSError(domain: "io.recal.ReCal-Course-Selection", code: 0, userInfo: nil)
                            self.downloadPromise.failWith(error)
                            return
                        }
                    case .Failure(let error):
                        self.downloadPromise.failWith(error)
                    }
                }
            }
            let serverCommunicator = Settings.currentSettings.serverCommunicator
            serverCommunicator.performBlock {
                serverCommunicator.registerServerCommunication(courseServerCommunication)
                let observer = Settings.currentSettings.serverCommunicator.startServerCommunicationWithIdentifier(courseServerCommunication.identifier)
                if observer != nil {
                    self.downloadState = .Downloading(observer!.progress)
                    observer!.progress.addObserver(self, forKeyPath: "fractionCompleted", options: NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.New, context: nil)
                    observer!.progress.addObserver(self, forKeyPath: "cancelled", options: NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.New, context: nil)
                }
            }
        case .Downloading(_), .Importing(_), .Finished:
            assertionFailure("Not allowed to start a download twice")
        }
    }
    
    private func advanceToImportState(#data: NSData) {
        Settings.currentSettings.coreDataImporter.performBlockAndWait {
            let progress = Settings.currentSettings.coreDataImporter.importPendingItems(temporaryFileName: CourseSelectionCoreDataImporter.TemporaryFileNames.courses, fileData: data)
            self.downloadState = .Importing(progress)
            progress.addObserver(self, forKeyPath: "fractionCompleted", options: NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.New, context: nil)
            progress.addObserver(self, forKeyPath: "cancelled", options: NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.New, context: nil)
        }
    }
    
    private func advanceToFinishedState() {
        self.downloadState = .Finished
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch self.downloadState {
        case .Downloading(let progress):
            assert(progress === object)
            switch keyPath {
            case "fractionCompleted":
                let fraction = Double((change[NSKeyValueChangeNewKey] as? NSNumber)?.floatValue ?? 0.0)
                let newCount = Int64((self.downloadState.progressFraction + fraction * self.downloadState.progressSize) * Double(self.granularity))
                if newCount != self.progress.completedUnitCount {
                    self.progress.completedUnitCount = newCount
                }
                
            case "cancelled":
                let cancelled = (change[NSKeyValueChangeNewKey] as? NSNumber)?.boolValue ?? false
                if cancelled {
                    let error = NSError(domain: "io.recal.ReCal-Course-Selection", code: 0, userInfo: nil)
                    self.downloadPromise.failWith(error)
                }
            default:
                assertionFailure("KVO not supported")
            }
        case .Importing(let progress):
            assert(progress === object)
            switch keyPath {
            case "fractionCompleted":
                let fraction = Double((change[NSKeyValueChangeNewKey] as? NSNumber)?.floatValue ?? 0.0)
                let newCount = Int64((self.downloadState.progressFraction + fraction * self.downloadState.progressSize) * Double(self.granularity))
                if newCount != self.progress.completedUnitCount {
                    self.progress.completedUnitCount = newCount
                }
                if fraction >= 1.0 {
                    println("about to succeed import promise")
                    self.importPromise.succeedWith(NSObject())
                    self.advanceToFinishedState()
                }
            case "cancelled":
                let cancelled = (change[NSKeyValueChangeNewKey] as? NSNumber)?.boolValue ?? false
                if cancelled {
                    let error = NSError(domain: "io.recal.ReCal-Course-Selection", code: 0, userInfo: nil)
                    self.importPromise.failWith(error)
                }
            default:
                assertionFailure("KVO not supported")
            }
        case .Finished, .Preparing:
            assertionFailure("Should not be observing in these states")
        }
    }
    
    /// DFA State
    private enum DownloadState {
        case Preparing
        case Downloading(NSProgress)
        case Importing(NSProgress)
        case Finished
        var progressFraction: Double {
            switch self {
            case .Preparing:
                return 0
            case .Downloading:
                return 0.1
            case .Importing:
                return 0.6
            case .Finished:
                return 1
            }
        }
        var progressSize: Double {
            switch self {
            case .Preparing:
                return 0.1 - self.progressFraction
            case .Downloading:
                return 0.6 - self.progressFraction
            case .Importing:
                return DownloadState.Finished.progressFraction - self.progressFraction
            case .Finished:
                return 0
            }
        }
    }
}