//
//  CourseDownloadViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/21/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class CourseDownloadViewController: UIViewController {

    weak var delegate: CourseDownloadViewControllerDelegate?
    
    var termCode: String = ""
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressTextLabel: UILabel!
    private var downloadState: DownloadState = .Preparing {
        willSet {
            switch downloadState {
            case .Preparing:
                break
            case .Downloading(let progress):
                progress.removeObserver(self, forKeyPath: "fractionCompleted")
                progress.removeObserver(self, forKeyPath: "cancelled")
            case .Writing:
                break
            case .Importing(let progress):
                progress.removeObserver(self, forKeyPath: "fractionCompleted")
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
            case .Writing:
                break
            case .Importing:
                break
            case .Finished:
                self.delegate?.courseDownloadDidFinish(self)
            }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.progressView.setProgress(self.downloadState.progressFraction, animated: true)
            }
            self.progressTextLabel.text = downloadState.progressText
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let courseServerCommunication = ServerCommunicator.OneTimeServerCommunication(identifier: "Courses", urlString: Urls.courses(semesterTermCode: self.termCode)) { (result: ServerCommunicator.Result) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                switch result {
                case .Success(_, let data):
                    self.downloadState = .Writing
                    Settings.currentSettings.coreDataImporter.performBlock {
                        Settings.currentSettings.coreDataImporter.writeJSONDataToPendingItemsDirectory(data, withTemporaryFileName: CourseSelectionCoreDataImporter.TemporaryFileNames.courses)
                        let progress = Settings.currentSettings.coreDataImporter.importPendingItems(temporaryFileName: CourseSelectionCoreDataImporter.TemporaryFileNames.courses)
                        self.downloadState = .Importing(progress)
                        progress.addObserver(self, forKeyPath: "fractionCompleted", options: NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.New, context: nil)
                    }
                    
                case .Failure(_):
                    self.delegate?.courseDownloadDidFail(self)
                }
            }
            
        }
        Settings.currentSettings.serverCommunicator.performBlockAndWait {
            Settings.currentSettings.serverCommunicator.registerServerCommunication(courseServerCommunication)
            let observer = Settings.currentSettings.serverCommunicator.startServerCommunicationWithIdentifier(courseServerCommunication.identifier)
            if observer != nil {
                self.downloadState = .Downloading(observer!.progress)
                observer!.progress.addObserver(self, forKeyPath: "fractionCompleted", options: NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.New, context: nil)
                observer!.progress.addObserver(self, forKeyPath: "cancelled", options: NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.New, context: nil)
            }
        }
        self.progressTextLabel.text = self.downloadState.progressText
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch self.downloadState {
        case .Downloading:
            switch keyPath {
            case "fractionCompleted":
                let fraction = (change[NSKeyValueChangeNewKey] as? NSNumber)?.floatValue ?? 0.0
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.progressView.setProgress(self.downloadState.progressFraction + fraction * self.downloadState.progressSize, animated: true)
                }
            case "cancelled":
                let cancelled = (change[NSKeyValueChangeNewKey] as? NSNumber)?.boolValue ?? false
                if cancelled {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        let _ = self.delegate?.courseDownloadDidFail(self)
                    }
                }
            default:
                assertionFailure("KVO not supported")
            }
        case .Importing:
            switch keyPath {
            case "fractionCompleted":
                let fraction = (change[NSKeyValueChangeNewKey] as? NSNumber)?.floatValue ?? 0.0
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.progressView.setProgress(self.downloadState.progressFraction + fraction * self.downloadState.progressSize, animated: true)
                    if fraction >= 1.0 {
                        self.downloadState = .Finished
                    }
                }
            default:
                assertionFailure("KVO not supported")
            }
        case .Finished, .Preparing, .Writing:
            assertionFailure("Should not be observing in these states")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    private enum DownloadState {
        case Preparing
        case Downloading(NSProgress)
        case Writing
        case Importing(NSProgress)
        case Finished
        var progressFraction: Float {
            switch self {
            case .Preparing:
                return 0
            case .Downloading:
                return 0.1
            case .Writing:
                return 0.5
            case .Importing:
                return 0.6
            case .Finished:
                return 1
            }
        }
        var progressSize: Float {
            switch self {
            case .Preparing:
                return 0.1 - self.progressFraction
            case .Downloading:
                return DownloadState.Writing.progressFraction - self.progressFraction
            case .Writing:
                return 0.6 - self.progressFraction
            case .Importing:
                return DownloadState.Finished.progressFraction - self.progressFraction
            case .Finished:
                return 0
            }
        }
        var progressText: String {
            switch self {
            case .Preparing:
                fallthrough
            case .Downloading(_):
                fallthrough
            case .Writing:
                return "Downloading courses data for this semester. May take a few minutes."
            case .Importing(_):
                return "Hang tight. Almost done!"
            case .Finished:
                return "Done!"
            }
        }
    }
}

protocol CourseDownloadViewControllerDelegate: class {
    func courseDownloadDidFinish(courseDownloadViewController: CourseDownloadViewController)
    func courseDownloadDidFail(courseDownloadViewController: CourseDownloadViewController)
}