//
//  CourseSelectionViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let changeScheduleSegueId = "ChangeSchedule"
private let courseCellIdentifier = "CourseCell"
private let searchViewControllerStoryboardId = "CourseSearch"
private let courseDownloadViewControllerStoryboardId = "CourseDownload"
private let scheduleSelectionNavigationControllerStoryboardId = "ScheduleSelectionNavigation"

class CourseSelectionViewController: DoubleSidebarViewController, UICollectionViewDelegate, UITableViewDelegate, ScheduleCollectionViewDataSourceDelegate, EnrolledCoursesTableViewDataSourceDelegate, CourseSearchTableViewControllerDelegate,
    ScheduleSelectionDelegate, SettingsViewControllerDelegate, SidebarOverlayPresentationDelegate, CourseDownloadViewControllerDelegate {
    
    // MARK: - Variables
    private let enrolledCoursesTableViewDataSource = EnrolledCoursesTableViewDataSource()
    private let scheduleCollectionViewDataSource = ScheduleCollectionViewDataSource()
    /// The width of the sidebars
    override var sidebarWidth: CGFloat {
        get {
            return self.viewContentSize.width / 3.5
        }
    }
    
    lazy private var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as AppDelegate).persistentStoreCoordinator
        return managedObjectContext
    }()
    private var notificationObservers: [AnyObject] = []
    
    override var sidebarState: DoubleSidebarState {
        willSet {
            switch newValue {
            case .LeftSidebarShown:
                self.searchViewController?.viewWillAppear(true)
            case .RightSidebarShown, .Unselected:
                self.searchViewController?.viewWillDisappear(true)
            }
        }
        didSet {
            switch sidebarState {
            case .RightSidebarShown:
                Settings.currentSettings.scheduleDisplayTextStyle = .SectionName
            case .LeftSidebarShown, .Unselected:
                Settings.currentSettings.scheduleDisplayTextStyle = .CourseNumber
            }
            
            switch sidebarState {
            case .LeftSidebarShown:
                self.searchViewController?.viewDidAppear(true)
            case .RightSidebarShown, .Unselected:
                self.searchViewController?.viewDidDisappear(true)
            }
        }
    }
    
    // MARK: Models
    // NOTE: didSet gets called on a struct even if we just assign one of its value, not the struct itself
    var schedule: Schedule? {
        didSet {
            if let schedule = self.schedule {
                self.navigationItem.title = schedule.name
                switch schedule.managedObjectProxyId {
                case .Existing(let id):
                    Settings.currentSettings.lastOpenedScheduleIdUri = id.URIRepresentation()
                case .NewObject:
                    // impossible
                    break
                }
                
            } else {
                self.navigationItem.title = "(No schedule selected)"
                Settings.currentSettings.lastOpenedScheduleIdUri = nil
                self.presentScheduleSelection()
            }
        }
    }
    
    // MARK: Views and View Controllers
    private var scheduleView: UICollectionView!
    private var enrolledCoursesView: UITableView!
    private var searchViewController: CourseSearchTableViewController!
    lazy private var settingsViewController: SettingsViewController = {
        let settingsVC = SettingsViewController.instantiateFromStoryboard()
        settingsVC.delegate = self
        return settingsVC
        }()
    lazy private var scheduleSelectionNavigationController: UINavigationController = {
        let navigationVC = self.storyboard?.instantiateViewControllerWithIdentifier(scheduleSelectionNavigationControllerStoryboardId) as UINavigationController
        
        let scheduleSelectionViewController = navigationVC.topViewController as ScheduleSelectionViewController
        scheduleSelectionViewController.delegate = self
        return navigationVC
    }()
    private var courseDownloadViewControllerTransitioningDelegate: UIViewControllerTransitioningDelegate?
    private var settingsViewControllerTransitioningDelegate: UIViewControllerTransitioningDelegate?
    private var scheduleSelectionViewControllerTransitioningDelegate: UIViewControllerTransitioningDelegate?
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    private var enrolledLabel: UILabel!
    private var enrolledLine: UIView!
    
    // MARK: - Methods
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let idUri = Settings.currentSettings.lastOpenedScheduleIdUri {
            if let id = self.managedObjectContext.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(idUri) {
                var errorOpt: NSError?
                if let scheduleManagedObject = self.managedObjectContext.existingObjectWithID(id, error: &errorOpt) as? CDSchedule {
                    self.schedule = Schedule(managedObject: scheduleManagedObject)
                }
            }
        }
        if self.schedule != nil && self.schedule!.enrolledCourses.count > 0 {
            self.setSidebarState(.RightSidebarShown, animated: false)
        }
        let observer = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { (notification) -> Void in
            if self.managedObjectContext.isEqual(notification.object) {
                return
            }
            self.managedObjectContext.performBlockAndWait {
                self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            }
            if let schedule = self.schedule {
                self.schedule = Schedule.updatedCopy(schedule, managedObjectContext: self.managedObjectContext)
            }
        }
        let observer2 = NSNotificationCenter.defaultCenter().addObserverForName(authenticatorStateDidChangeNofication, object: nil, queue: nil) { (_) -> Void in
            // delete all the schedules
            
            let fetchRequest = NSFetchRequest(entityName: "CDSchedule")
            fetchRequest.includesPropertyValues = false
            var errorOpt: NSError?
            var fetched: [CDSchedule]?
            self.managedObjectContext.performBlockAndWait {
                fetched = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt) as? [CDSchedule]
            }
            if let error = errorOpt {
                println("Error fetching schedules. Error: \(error)")
                return
            }
            if let schedules = fetched {
                for schedule in schedules {
                    self.managedObjectContext.performBlockAndWait {
                        self.managedObjectContext.deleteObject(schedule)
                    }
                }
                self.managedObjectContext.performBlockAndWait {
                    self.managedObjectContext.persistentStoreCoordinator!.lock()
                    self.managedObjectContext.save(&errorOpt)
                    self.managedObjectContext.persistentStoreCoordinator!.unlock()
                }
                if let error = errorOpt {
                    println("Error deleting schedule. Error: \(error)")
                    return
                }
            }
        }
        let updateWithColorScheme: ()->Void = {
            if let scheduleView = self.scheduleView {
                scheduleView.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
            }
            if let enrolledLabel = self.enrolledLabel {
                enrolledLabel.textColor = Settings.currentSettings.colorScheme.textColor
            }
            if let enrolledLine = self.enrolledLine {
                enrolledLine.backgroundColor = Settings.currentSettings.colorScheme.selectedContentBackgroundColor
            }
            self.rightSidebarBackgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
            self.leftSidebarBackgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
            switch Settings.currentSettings.theme {
            case .Light:
                self.scheduleSelectionNavigationController.navigationBar.barStyle = .Default
            case .Dark:
                self.scheduleSelectionNavigationController.navigationBar.barStyle = .Black
            }
            self.scheduleSelectionNavigationController.view.tintColor = Settings.currentSettings.colorScheme.actionableTextColor
        }
        let observer3 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateWithColorScheme()
        }
        updateWithColorScheme()
        self.notificationObservers.append(observer)
        self.notificationObservers.append(observer2)
        self.notificationObservers.append(observer3)
        
        self.definesPresentationContext = true
        self.leftSidebarCoverText = "SEARCH"
        self.rightSidebarCoverText = "ENROLLED"
        self.initializeScheduleView()
        self.initializeEnrolledCoursesView()
        self.initializeSearchViewController()
        self.settingsButton.title = navigationThreeBars
    }
    
    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.schedule == nil {
            self.presentScheduleSelection()
        }
    }
    
    private func presentScheduleSelection() {
        if self.scheduleSelectionNavigationController.presentingViewController == self {
            return
        }
        let delegate = SidebarOverlayTransitioningDelegate(direction: .Right)
        delegate.delegate = self
        self.scheduleSelectionViewControllerTransitioningDelegate = delegate
        self.scheduleSelectionNavigationController.modalPresentationStyle = .Custom
        self.scheduleSelectionNavigationController.transitioningDelegate = self.scheduleSelectionViewControllerTransitioningDelegate
        self.presentViewController(self.scheduleSelectionNavigationController, animated: true, completion: nil)
    }
    
    private func saveSchedule() {
        if self.schedule != nil {
            self.schedule!.commitToManagedObjectContext(self.managedObjectContext)
            var errorOpt: NSError?
            self.managedObjectContext.performBlock {
                self.managedObjectContext.persistentStoreCoordinator!.lock()
                self.managedObjectContext.save(&errorOpt)
                self.managedObjectContext.persistentStoreCoordinator!.unlock()
                if let error = errorOpt {
                    println("Error saving. Error: \(error)")
                }
            }
        }
    }
    
    private func initializeScheduleView() {
        self.scheduleView = {
            let scheduleView = UICollectionView(frame: CGRectZero, collectionViewLayout: CollectionViewCalendarWeekLayout())
            scheduleView.setTranslatesAutoresizingMaskIntoConstraints(false)
            scheduleView.allowsMultipleSelection = true
            self.primaryContentView.addSubview(scheduleView)
            self.primaryContentView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(scheduleView, inParentView: self.primaryContentView, withInsets: UIEdgeInsetsZero))
            scheduleView.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
            return scheduleView
        }()
        
        let dataSource = self.scheduleCollectionViewDataSource
        dataSource.delegate = self
        let layout = self.scheduleView.collectionViewLayout as CollectionViewCalendarWeekLayout
        layout.dataSource = dataSource
        self.scheduleView.dataSource = dataSource
        self.scheduleView.delegate = self
        dataSource.registerReusableViewsWithCollectionView(self.scheduleView, forLayout: self.scheduleView.collectionViewLayout)
        self.reloadScheduleView()
    }
    
    private func initializeEnrolledCoursesView() {
        self.rightSidebarBackgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
        
        let enrolledLabel: UILabel = {
            let enrolledLabel = UILabel()
            enrolledLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            enrolledLabel.textColor = Settings.currentSettings.colorScheme.textColor
            enrolledLabel.text = "Enrolled"
            self.rightSidebarContentView.addSubview(enrolledLabel)
            let topLabelConstraint = NSLayoutConstraint(item: self.rightSidebarContentView, attribute: .TopMargin, relatedBy: .Equal, toItem: enrolledLabel, attribute: .Top, multiplier: 1, constant: 0)
            let leadingLabelConstraint = NSLayoutConstraint(item: self.rightSidebarContentView, attribute: .LeadingMargin, relatedBy: .Equal, toItem: enrolledLabel, attribute: .Leading, multiplier: 1, constant: 0)
            self.rightSidebarContentView.addConstraints([topLabelConstraint, leadingLabelConstraint])
            return enrolledLabel
        }()
        self.enrolledLabel = enrolledLabel
        
        let line: UIView = {
            let line = UIView()
            line.backgroundColor = Settings.currentSettings.colorScheme.selectedContentBackgroundColor
            line.setTranslatesAutoresizingMaskIntoConstraints(false)
            line.addConstraint(NSLayoutConstraint(item: line, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 1))
            self.rightSidebarContentView.addSubview(line)
            let topLineConstraint = NSLayoutConstraint(item: line, attribute: .Top, relatedBy: .Equal, toItem: enrolledLabel, attribute: .Bottom, multiplier: 1.0, constant: 8.0)
            let leadingLineConstraint = NSLayoutConstraint(item: self.rightSidebarContentView, attribute: .Left, relatedBy: .Equal, toItem: line, attribute: .Leading, multiplier: 1, constant: 0)
            let trailingLineConstraint = NSLayoutConstraint(item: self.rightSidebarContentView, attribute: .Right, relatedBy: .Equal, toItem: line, attribute: .Trailing, multiplier: 1, constant: 0)
            self.rightSidebarContentView.addConstraints([topLineConstraint, leadingLineConstraint, trailingLineConstraint])
            return line
        }()
        self.enrolledLine = line
        
        self.enrolledCoursesView = {
            let enrolledCoursesView = UITableView()
            enrolledCoursesView.backgroundColor = UIColor.clearColor()
            enrolledCoursesView.separatorStyle = .None
            enrolledCoursesView.setTranslatesAutoresizingMaskIntoConstraints(false)
            enrolledCoursesView.registerNib(UINib(nibName: "EnrolledCourseTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: courseCellIdentifier)
            self.rightSidebarContentView.addSubview(enrolledCoursesView)
            let topConstraint = NSLayoutConstraint(item: enrolledCoursesView, attribute: .Top, relatedBy: .Equal, toItem: line, attribute: .Bottom, multiplier: 1.0, constant: 0)
            let leadingConstraint = NSLayoutConstraint(item: self.rightSidebarContentView, attribute: .Left, relatedBy: .Equal, toItem: enrolledCoursesView, attribute: .Leading, multiplier: 1, constant: 0)
            let trailingConstraint = NSLayoutConstraint(item: self.rightSidebarContentView, attribute: .Right, relatedBy: .Equal, toItem: enrolledCoursesView, attribute: .Trailing, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: self.rightSidebarContentView, attribute: .Bottom, relatedBy: .Equal, toItem: enrolledCoursesView, attribute: .Bottom, multiplier: 1.0, constant: 0)
            self.rightSidebarContentView.addConstraints([topConstraint, leadingConstraint, trailingConstraint, bottomConstraint])
            return enrolledCoursesView
        }()
        
        self.enrolledCoursesTableViewDataSource.delegate = self
        self.enrolledCoursesView.dataSource = self.enrolledCoursesTableViewDataSource
        self.enrolledCoursesView.delegate = self
        self.reloadEnrolledCoursesView()
    }
    
    private func initializeSearchViewController() {
        self.leftSidebarBackgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
        
        self.searchViewController = {
            let searchViewController = self.storyboard?.instantiateViewControllerWithIdentifier(searchViewControllerStoryboardId) as CourseSearchTableViewController
            searchViewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.addChildViewController(searchViewController)
            self.leftSidebarContentView.addSubview(searchViewController.view)
            self.leftSidebarContentView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(searchViewController.view, inParentView: self.leftSidebarContentView, withInsets: UIEdgeInsetsZero))
            
            searchViewController.delegate = self
            return searchViewController
        }()
        self.reloadSearchViewController()
    }
    
    private func reloadEnrolledCoursesView() {
        if let schedule = self.schedule {
            self.enrolledCoursesTableViewDataSource.courseColorMap = schedule.courseColorMap
            self.enrolledCoursesTableViewDataSource.enrollments = schedule.courseSectionTypeEnrollments
            self.enrolledCoursesView?.reloadData()
        }
    }
    
    private func reloadScheduleView() {
        if let schedule = self.schedule {
            // must set color map first
            self.scheduleCollectionViewDataSource.courseColorMap = schedule.courseColorMap
            self.scheduleCollectionViewDataSource.enrollments = schedule.courseSectionTypeEnrollments
            self.scheduleView?.reloadData()
        }
    }
    
    private func reloadSearchViewController() {
        if let schedule = self.schedule {
            self.searchViewController.semesterTermCode = schedule.termCode
            self.searchViewController.enrolledCourses = schedule.enrolledCourses.toArray()
        }
    }
    
    private func showCourseDeletePromptForCourse(course: Course) {
        if self.schedule != nil {
            assert(self.schedule!.enrolledCourses.contains(course), "Trying to delete a course that wasn't enrolled")
            let alertController = UIAlertController(title: "Delete \(course)", message: "Are you sure you want to delete this course?", preferredStyle: .ActionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (alertAction: UIAlertAction!) -> Void in
                self.schedule!.enrolledCourses.remove(course)
                self.schedule!.updateColorUsageForDeletedCourse(course)
                self.schedule!.updateCourseSectionTypeEnrollments()
                self.reloadEnrolledCoursesView()
                self.reloadScheduleView()
                self.reloadSearchViewController()
                self.saveSchedule()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (_) -> Void in
                
            })
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    @IBAction func settingsButtonTapped(sender: UIBarButtonItem) {
        assert(self.presentedViewController == nil)
        self.settingsViewControllerTransitioningDelegate = SidebarOverlayTransitioningDelegate(direction: .Left)
        let settingsVC = self.settingsViewController
        settingsVC.modalPresentationStyle = .Custom
        settingsVC.transitioningDelegate = self.settingsViewControllerTransitioningDelegate!
        self.presentViewController(settingsVC, animated: true, completion: nil)
    }
    
    @IBAction func scheduleChangeButtonTapped(sender: UIBarButtonItem) {
        self.presentScheduleSelection()
    }
    // MARK: - Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.enrolledCoursesView {
            self.enrolledCoursesTableViewDataSource.handleSelectionInTableView(tableView, forRowAtIndexPath: indexPath)
        }
    }
    
    // MARK: - Collection View Delegate
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.scheduleView {
            self.scheduleCollectionViewDataSource.handleDeselectionInCollectionView(collectionView, forItemAtIndexPath: indexPath)
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.scheduleView {
            self.scheduleCollectionViewDataSource.handleSelectionInCollectionView(collectionView, forItemAtIndexPath: indexPath)
        }
    }
    
    // MARK: - Enrolled Courses Table View Data Source Delegate
    func enrollmentsDidChangeForEnrolledCoursesTableViewDataSource(dataSource: EnrolledCoursesTableViewDataSource) {
        if self.schedule != nil {
            assert(dataSource == self.enrolledCoursesTableViewDataSource, "Wrong data source object for enrolled courses view")
            self.schedule!.courseSectionTypeEnrollments = dataSource.enrollments
            self.reloadScheduleView()
        }
    }
    func enrolledCoursesTableViewDataSource(dataSource: EnrolledCoursesTableViewDataSource, shouldDeleteCourse course: Course) {
        assert(dataSource == self.enrolledCoursesTableViewDataSource, "Wrong data source object for enrolled courses view")
        self.showCourseDeletePromptForCourse(course)
    }
    func enrollmentsDidStopChangingForEnrolledCoursesTableViewDataSource(dataSource: EnrolledCoursesTableViewDataSource) {
        assert(dataSource == self.enrolledCoursesTableViewDataSource, "Wrong data source object for schedule view")
        // enrollments already set in enrollmentsDidChange
        self.saveSchedule()
    }
    
    // MARK: - Schedule Collection View Data Source Delegate
    func enrollmentDidChangeForScheduleCollectionViewDataSource(dataSource: ScheduleCollectionViewDataSource) {
        if self.schedule != nil {
            assert(dataSource == self.scheduleCollectionViewDataSource, "Wrong data source object for schedule view")
            self.schedule!.courseSectionTypeEnrollments = dataSource.enrollments
            self.reloadEnrolledCoursesView()
            self.saveSchedule()
        }
    }
    
    
    // MARK: - Course Search Table View Controller Delegate
    func enrollmentsDidChangeForCourseSearchTableViewController(viewController: CourseSearchTableViewController) {
        if self.schedule != nil {
            assert(viewController == self.searchViewController, "Wrong view controller")
            let newEnrolled = Set(initialItems: viewController.enrolledCourses)
            let deletedCourses = self.schedule!.enrolledCourses.toArray().filter { !newEnrolled.contains($0) }
            self.schedule!.enrolledCourses = newEnrolled
            for deleted in deletedCourses {
                self.schedule!.updateColorUsageForDeletedCourse(deleted)
            }
            self.schedule!.updateCourseSectionTypeEnrollments()
            self.schedule!.updateCourseColorMap()
            self.reloadScheduleView()
            self.reloadEnrolledCoursesView()
            self.saveSchedule()
        }
    }
    
    func courseSearchTableViewController(viewController: CourseSearchTableViewController, shouldDeleteCourse course: Course) {
        assert(viewController == self.searchViewController, "Wrong view controller")
        self.showCourseDeletePromptForCourse(course)
    }
    
    // MARK: - Schedule Selection Delegate
    func didDeleteScheduleWithObjectId(objectId: NSManagedObjectID) {
        if let schedule = self.schedule {
            switch schedule.managedObjectProxyId {
            case .Existing(let id):
                if id.isEqual(objectId) {
                    self.schedule = nil
                }
            case .NewObject:
                break
            }
        }
    }
    func didSelectScheduleWithObjectId(objectId: NSManagedObjectID) {
        assert(self.presentedViewController == self.scheduleSelectionNavigationController)
        var schedule: CDSchedule?
        var coursesCount: Int = 0
        var errorOpt: NSError?
        self.managedObjectContext.performBlockAndWait {
            schedule = self.managedObjectContext.existingObjectWithID(objectId, error: &errorOpt) as? CDSchedule
            coursesCount = schedule!.semester.courses.count
        }
        if schedule != nil {
            self.schedule = Schedule(managedObject: schedule!)
            self.reloadEnrolledCoursesView()
            self.reloadScheduleView()
            self.reloadSearchViewController()
        } else {
            assertionFailure("Failed to get schedule")
        }
        self.dismissViewControllerAnimated(true) {
            self.scheduleSelectionViewControllerTransitioningDelegate = nil
            if coursesCount < 800 /* TODO safe? */ {
                let courseDownloadVC = self.storyboard?.instantiateViewControllerWithIdentifier(courseDownloadViewControllerStoryboardId) as CourseDownloadViewController
                courseDownloadVC.termCode = schedule!.semester.termCode
                courseDownloadVC.delegate = self
                courseDownloadVC.modalPresentationStyle = .Custom
                self.courseDownloadViewControllerTransitioningDelegate = FadeOverlayPresentation.TransitioningDelegate()
                courseDownloadVC.transitioningDelegate = self.courseDownloadViewControllerTransitioningDelegate
                self.presentViewController(courseDownloadVC, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Settings View Controller Delegate
    func settingsViewControllerDidTapDismissButton(settingsViewController: SettingsViewController) {
        assert(self.presentedViewController == self.settingsViewController)
        self.dismissViewControllerAnimated(true, completion: {
            self.settingsViewControllerTransitioningDelegate = nil
        })
    }
    func settingsViewControllerDidTapLogOutButton(settingsViewController: SettingsViewController) {
        assert(self.presentedViewController == self.settingsViewController)
        self.dismissViewControllerAnimated(true, completion: {
            self.settingsViewControllerTransitioningDelegate = nil
            Settings.currentSettings.authenticator.logOut()
            self.schedule = nil
        })
    }
    
    // MARK: - Sidebar Overlay Transitioning Delegate
    func sidebarOverlayPresentation(presentationController: UIPresentationController, didTapOutsidePresentedViewController presentedViewController: UIViewController, presentingViewController: UIViewController) {
        assert(self.presentedViewController == self.scheduleSelectionNavigationController)
        if self.schedule == nil {
            let alertController = UIAlertController(title: "Please select a schedule", message: nil, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentedViewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true) {
                self.scheduleSelectionViewControllerTransitioningDelegate = nil
                self.schedule = Schedule.updatedCopy(self.schedule!, managedObjectContext: self.managedObjectContext)
                self.reloadEnrolledCoursesView()
                self.reloadScheduleView()
                self.reloadSearchViewController()
            }
        }
    }

    // MARK: - Course Download Delegate
    func courseDownloadDidFinish(courseDownloadViewController: CourseDownloadViewController) {
        assert(self.presentedViewController == courseDownloadViewController)
        self.dismissViewControllerAnimated(true) {
            self.courseDownloadViewControllerTransitioningDelegate = nil
            if let schedule = self.schedule {
                self.schedule = Schedule.updatedCopy(schedule, managedObjectContext: self.managedObjectContext)
                self.reloadEnrolledCoursesView()
                self.reloadScheduleView()
                self.reloadSearchViewController()
            }
        }
    }
    func courseDownloadDidFail(courseDownloadViewController: CourseDownloadViewController) {
        assert(self.presentedViewController == courseDownloadViewController)
        self.dismissViewControllerAnimated(true) {
            self.courseDownloadViewControllerTransitioningDelegate = nil
            let alertController = UIAlertController(title: "Failed to download courses", message: "Please try again later.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
