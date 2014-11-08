//
//  CourseSelectionContainerViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let courseSelectionViewControllerStoryboardId = "CourseSelection"
private let courseSelectionEmbedSegueId = "CourseSelectionEmbed"
private let changeScheduleSegueId = "ChangeSchedule"

class CourseSelectionContainerViewController: UIViewController, ScheduleSelectionDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarTitleItem: UINavigationItem!
    private var courseSelectionViewController: CourseSelectionViewController!
    private var currentSchedule: Schedule! {
        didSet {
            if oldValue != currentSchedule {
                assert(currentSchedule != nil)
                self.navigationBarTitleItem.title = currentSchedule.name
                if let courseSelectionViewController = self.courseSelectionViewController {
                    courseSelectionViewController.schedule = self.currentSchedule
                }
            }
        }
    }
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = Settings.currentSettings.colorScheme.actionableTextColor
        switch Settings.currentSettings.theme {
        case .Light:
            self.navigationBar.barStyle = .Default
        case .Dark:
            self.navigationBar.barStyle = .Black
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.courseSelectionViewController.viewContentSize = self.contentView.bounds.size
        if self.currentSchedule == nil {
            self.performSegueWithIdentifier(changeScheduleSegueId, sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Schedule Selection Delegate
    func didSelectSchedule(schedule: Schedule) {
        self.currentSchedule = schedule
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - Content Container
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if container === self.courseSelectionViewController {
            return self.contentView.bounds.size
        }
        return super.sizeForChildContentContainer(container, withParentContainerSize: parentSize)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue {
        case let _ where segue.identifier == courseSelectionEmbedSegueId:
            self.courseSelectionViewController = segue.destinationViewController as CourseSelectionViewController
            self.courseSelectionViewController.schedule = self.currentSchedule
        case let _ where segue.identifier == changeScheduleSegueId:
            let navigationController = segue.destinationViewController as UINavigationController
            switch Settings.currentSettings.theme {
            case .Light:
                navigationController.navigationBar.barStyle = .Default
            case .Dark:
                navigationController.navigationBar.barStyle = .Black
            }
            
            let scheduleSelectionViewController = navigationController.topViewController as ScheduleSelectionViewController
            scheduleSelectionViewController.delegate = self
        default:
            break
        }
    }
    

}
