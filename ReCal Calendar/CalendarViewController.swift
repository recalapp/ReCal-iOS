//
//  CalendarViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/8/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let calendarViewContentViewSegueId = "CalendarEmbed"
private let agendaViewControllerStoryboardId = "AgendaViewController"
private let eventNavigationViewControllerStoryboardId = "eventNavigationViewController"

class CalendarViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, AgendaViewControllerDelegate, EventViewControllerDelegate, SettingsViewControllerDelegate {
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var viewControllerSegmentedControl: UISegmentedControl!
    
    lazy private var agendaViewController: AgendaViewController = {
        let agendaVC = self.storyboard?.instantiateViewControllerWithIdentifier(agendaViewControllerStoryboardId) as AgendaViewController
        agendaVC.delegate = self
        return agendaVC
    }()
    lazy private var dayViewController: UIViewController = {
        return UIViewController()
    }()
    lazy private var eventNavigationViewController: UINavigationController = {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(eventNavigationViewControllerStoryboardId) as UINavigationController
        let eventVC = vc.viewControllers.first as EventViewController
        eventVC.delegate = self
        return vc
    }()
    lazy private var settingsNavigationViewController: UINavigationController = {
        let settingsVC = SettingsViewController.instantiateFromStoryboard()
        let navigationController = UINavigationController(rootViewController: settingsVC)
        settingsVC.delegate = self
        return navigationController
    }()
    lazy private var viewControllers: [UIViewController] = {
        return [self.agendaViewController, self.dayViewController]
    }()
    
    weak private var pageViewController: UIPageViewController!
    
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Settings.currentSettings.authenticator.authenticate()
        switch Settings.currentSettings.theme {
        case .Light:
            self.navigationController?.navigationBar.barStyle = .Default
        case .Dark:
            self.navigationController?.navigationBar.barStyle = .Black
        }
        self.view.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
        self.settingsButton.title = navigationThreeBars
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func viewControllerSegmentedControlValueChanged(sender: UISegmentedControl) {
        assert(sender.selectedSegmentIndex >= 0)
        assert(sender.selectedSegmentIndex < self.viewControllers.count)
        let currentViewControllerIndex = arrayFindIndexesOfElement(array: self.viewControllers, element: self.pageViewController.viewControllers.last! as UIViewController).last!
        
        self.pageViewController.setViewControllers([self.viewControllers[sender.selectedSegmentIndex]], direction: currentViewControllerIndex < sender.selectedSegmentIndex ? .Forward : .Reverse, animated: true) { (_) -> Void in
            
        }
    }
    private func presentEventViewController(#eventObjectId: NSManagedObjectID) {
        let eventViewController = self.eventNavigationViewController.viewControllers.first as EventViewController
        eventViewController.eventObjectId = eventObjectId
        self.presentViewController(self.eventNavigationViewController, animated: true, completion: nil)
    }
    @IBAction func settingsButtonTapped(sender: UIBarButtonItem) {
        assert(self.presentedViewController == nil)
        self.presentViewController(self.settingsNavigationViewController, animated: true, completion: nil)
    }
    // MARK: - Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let indexes = arrayFindIndexesOfElement(array: self.viewControllers, element: viewController)
        assert(indexes.count == 1)
        let index = indexes.last! - 1
        if index < 0 {
            return nil
        } else {
            return self.viewControllers[index]
        }
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let indexes = arrayFindIndexesOfElement(array: self.viewControllers, element: viewController)
        assert(indexes.count == 1)
        let index = indexes.last! + 1
        if index >= self.viewControllers.count {
            return nil
        } else {
            return self.viewControllers[index]
        }
    }
    
    // MARK: - Page View Controller Delegate
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        if pageViewController == self.pageViewController {
            let currentViewControllerIndex = arrayFindIndexesOfElement(array: self.viewControllers, element: pageViewController.viewControllers.last! as UIViewController).last!
            self.viewControllerSegmentedControl.selectedSegmentIndex = currentViewControllerIndex
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case .Some(calendarViewContentViewSegueId):
            let pageViewController = segue.destinationViewController as UIPageViewController
            pageViewController.dataSource = self
            pageViewController.delegate = self
            pageViewController.setViewControllers([self.viewControllers.first!], direction: .Forward, animated: false, completion: { (_) -> Void in
                
            })
            self.pageViewController = pageViewController
        default:
            break
        }
    }

    // MARK: - Agenda View Controller Delegate
    func agendaViewController(agendaViewController: AgendaViewController, didSelectEventWithManagedObjectId managedObjectId: NSManagedObjectID) {
        self.presentEventViewController(eventObjectId: managedObjectId)
    }
    
    // MARK: - Event View Controller Delegate
    func eventViewControllerDidTapDismissButton(eventViewController: EventViewController) {
        assert(self.presentedViewController == self.eventNavigationViewController)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Settings View Controller Delegate
    func settingsViewControllerDidTapDismissButton(settingsViewController: SettingsViewController) {
        assert(self.presentedViewController == self.settingsNavigationViewController)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func settingsViewControllerDidTapLogOutButton(settingsViewController: SettingsViewController) {
        assert(self.presentedViewController == self.settingsNavigationViewController)
        self.dismissViewControllerAnimated(true, completion: nil)
        Settings.currentSettings.authenticator.logOut()
    }
}
