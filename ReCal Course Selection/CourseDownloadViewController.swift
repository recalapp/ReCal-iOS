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

    // MARK: Variables
    weak var delegate: CourseDownloadViewControllerDelegate?
    
    /// The semester term code
    var termCode: String = ""

    /// The UIProgressView used to display progress
    @IBOutlet weak var progressView: UIProgressView!
    
    /// The label for the progress view
    @IBOutlet weak var progressTextLabel: UILabel!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let task = SemesterDownloadTask(termCode: termCode)
        task.progress.addObserver(self, forKeyPath: "cancelled", options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Initial, context: nil)
        task.progress.addObserver(self, forKeyPath: "fractionCompleted", options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Initial, context: nil)
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
        case "fractionCompleted":
            let fraction = (change[NSKeyValueChangeNewKey] as? NSNumber)?.floatValue ?? 0.0
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.progressView.setProgress(fraction, animated: true)
                if fraction >= 1.0 {
                    self.delegate?.courseDownloadDidFinish(self)
                }
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
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
// MARK: - Delegate
protocol CourseDownloadViewControllerDelegate: class {
    func courseDownloadDidFinish(courseDownloadViewController: CourseDownloadViewController)
    func courseDownloadDidFail(courseDownloadViewController: CourseDownloadViewController)
}