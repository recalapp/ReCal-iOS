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

    // MARK: Constants
    
    /// The number of courses to download in one connection
    private let batchSize = 1200 // not needed any more, as we download in one shot
    
    /// The estimated total number of courses, used in the inital download
    private let estimatedTotalCount = 1200
    
    // MARK: Variables
    weak var delegate: CourseDownloadViewControllerDelegate?
    
    /// The actual total number of courses
    private var totalCountStorage: Int?
    
    /// The value used to calculate progress
    private var totalCount: Int {
        return self.totalCountStorage ?? self.estimatedTotalCount
    }
    
    /// The number of times we have to connect
    private var batchCount: Int {
        return (self.totalCount + self.batchSize - 1) / self.batchSize // round up if there's any decimal
    }
    
    /// The semester term code
    var termCode: String = ""

    /// The UIProgressView used to display progress
    @IBOutlet weak var progressView: UIProgressView!
    
    /// The label for the progress view
    @IBOutlet weak var progressTextLabel: UILabel!
    
    /// The array of download tasks
    private var downloadTasks: [DownloadTask] = []
    
    /// The total progress
    private var totalProgressFraction: Double {
        self.adjustDownloadTasksArrayLength()
        let total = self.downloadTasks.map { $0.progressFraction }.reduce(0, combine: +)
        return total / Double(self.downloadTasks.count)
    }
    
    private var allFinished: Bool {
        return self.downloadTasks.map {
            switch $0 {
            case .Finished:
                return true
            case .Active(_), .NotStarted:
                return false
            }
        }.reduce(true) { (old: Bool, cur: Bool) in old && cur }
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startDownloadTask(index: 0)
    }
    
    private func startDownloadTask(#index: Int) {
        self.adjustDownloadTasksArrayLength()
        println("Starting task # \(index + 1) out of \(self.batchCount)")
        assert(index < self.downloadTasks.count, "Invalid download task index")
        switch self.downloadTasks[index] {
        case .NotStarted:
            let task = SemesterDownloadTask(termCode: self.termCode, limit: self.batchSize, offset: index * self.batchSize)
            task.progress.addObserver(self, forKeyPath: "cancelled", options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Initial, context: nil)
            task.progress.addObserver(self, forKeyPath: "fractionCompleted", options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Initial, context: nil)
            self.downloadTasks[index] = .Active(task)
            task.downloadPromise.onDone { (_) in
                println("Download completed for task # \(index + 1) out of \(self.batchCount)")
            }
            task.importPromise.onDone { (_) in
                println("Import completed for task # \(index + 1) out of \(self.batchCount)")
            }
//            task.downloadPromise.onSuccess { (downloadedDictionary: NSDictionary) in
//                if let totalCount = downloadedDictionary["meta"]?["total_count"] as? NSNumber {
//                    self.totalCountStorage = totalCount.integerValue
//                } else {
//                    self.handleCancellation()
//                }
//                self.adjustDownloadTasksArrayLength()
//                if index + 1 < self.batchCount {
//                    self.startDownloadTask(index: index + 1)
//                }
//            }
            
            
        case .Active(_), .Finished:
            assertionFailure("Not allowed to restart a task")
            break
        }
    }
    
    private func adjustDownloadTasksArrayLength() {
        while self.downloadTasks.count > self.batchCount {
            self.downloadTasks.removeLast()
        }
        while self.downloadTasks.count < self.batchCount {
            self.downloadTasks.append(.NotStarted)
        }
    }
    
    private func handleCancellation() {
        // TODO delete downloaded courses so we know to redownload next time
        NSOperationQueue.mainQueue().addOperationWithBlock {
            let _ = self.delegate?.courseDownloadDidFail(self)
        }
    }
    
    private func progressTextForProgressFraction(progressFraction: Double) -> String {
        switch progressFraction {
        case _ where progressFraction <= 0.4:
            return "Downloading course data. May take a few minutes."
        case _ where progressFraction <= 0.7:
            return "Please do not quit this app during download."
        case _ where progressFraction > 0.7:
            return "Hang tight, almost there!"
        default:
            assertionFailure("impossible")
            break
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        assert(object is NSProgress)
        func findProgressIndex(progress: NSProgress) -> Int? {
            for (i, task) in enumerate(self.downloadTasks) {
                if task.progressObject === progress {
                    return i
                }
            }
            return nil
        }
        switch keyPath {
        case "fractionCompleted":
            let fraction = (change[NSKeyValueChangeNewKey] as? NSNumber)?.floatValue ?? 0.0
            let indexOpt = findProgressIndex(object as NSProgress)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if fraction >= 1 {
                    if let index = indexOpt {
                        object.removeObserver(self, forKeyPath: "fractionCompleted")
                        object.removeObserver(self, forKeyPath: "cancelled")
                        self.downloadTasks[index] = .Finished
                    }
                }
                let totalProgressFraction = self.totalProgressFraction
                self.progressTextLabel.text = self.progressTextForProgressFraction(totalProgressFraction)
                self.progressView.setProgress(Float(totalProgressFraction), animated: true)
                if self.allFinished {
                    self.delegate?.courseDownloadDidFinish(self)
                }
            }
        case "cancelled":
            let cancelled = (change[NSKeyValueChangeNewKey] as? NSNumber)?.boolValue ?? false
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if cancelled {
                    self.handleCancellation()
                }
            }
        default:
            assertionFailure("KVO not supported")
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    private enum DownloadTask {
        case NotStarted
        case Active(SemesterDownloadTask)
        case Finished
        
        var progressFraction: Double {
            switch self {
            case .NotStarted:
                return 0
            case .Active(let task):
                return task.progress.fractionCompleted
            case .Finished:
                return 1
            }
        }
        
        var progressObject: NSProgress? {
            switch self {
            case .NotStarted:
                return nil
            case .Active(let task):
                return task.progress
            case .Finished:
                return nil
            }
        }
    }
}
// MARK: - Delegate
protocol CourseDownloadViewControllerDelegate: class {
    func courseDownloadDidFinish(courseDownloadViewController: CourseDownloadViewController)
    func courseDownloadDidFail(courseDownloadViewController: CourseDownloadViewController)
}