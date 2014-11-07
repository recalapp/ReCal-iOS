//
//  CourseSelectionViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let courseCellIdentifier = "CourseCell"
private let searchViewControllerStoryboardId = "CourseSearch"

class CourseSelectionViewController: DoubleSidebarViewController, UICollectionViewDelegate, UITableViewDelegate, ScheduleCollectionViewDataSourceDelegate, EnrolledCoursesTableViewDataSourceDelegate, CourseSearchTableViewControllerDelegate {
    
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
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as AppDelegate).persistentStoreCoordinator
        return managedObjectContext
    }()
    
    // MARK: Models
    var schedule: Schedule! {
        didSet {
            if oldValue != schedule {
                self.reloadScheduleView()
                self.reloadEnrolledCoursesView()
                self.reloadSearchViewController()
            }
        }
    }
    
    // MARK: Views and View Controllers
    private var scheduleView: UICollectionView!
    private var enrolledCoursesView: UITableView!
    private var searchViewController: CourseSearchTableViewController!
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.leftSidebarCoverText = "SEARCH"
        self.rightSidebarCoverText = "ENROLLED"
        self.initializeScheduleView()
        self.initializeEnrolledCoursesView()
        self.initializeSearchViewController()
    }
    
    private func saveSchedule() {
        if self.schedule != nil {
            self.schedule.commitToManagedObjectContext(self.managedObjectContext)
            var errorOpt: NSError?
            self.managedObjectContext.performBlock {
                let _ = self.managedObjectContext.save(&errorOpt)
            }
            if let error = errorOpt {
                println("Error saving. Error: \(error)")
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
        self.rightSidebarBackgroundColor = UIColor.lightBlackGrayColor()
        
        let enrolledLabel: UILabel = {
            let enrolledLabel = UILabel()
            enrolledLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            enrolledLabel.textColor = UIColor.lightTextColor()
            enrolledLabel.text = "Enrolled"
            self.rightSidebarContentView.addSubview(enrolledLabel)
            let topLabelConstraint = NSLayoutConstraint(item: self.rightSidebarContentView, attribute: .TopMargin, relatedBy: .Equal, toItem: enrolledLabel, attribute: .Top, multiplier: 1, constant: 0)
            let leadingLabelConstraint = NSLayoutConstraint(item: self.rightSidebarContentView, attribute: .LeadingMargin, relatedBy: .Equal, toItem: enrolledLabel, attribute: .Leading, multiplier: 1, constant: 0)
            self.rightSidebarContentView.addConstraints([topLabelConstraint, leadingLabelConstraint])
            return enrolledLabel
        }()
        
        let line: UIView = {
            let line = UIView()
            line.backgroundColor = UIColor.lightTextColor()
            line.setTranslatesAutoresizingMaskIntoConstraints(false)
            line.addConstraint(NSLayoutConstraint(item: line, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 1))
            self.rightSidebarContentView.addSubview(line)
            let topLineConstraint = NSLayoutConstraint(item: line, attribute: .Top, relatedBy: .Equal, toItem: enrolledLabel, attribute: .Bottom, multiplier: 1.0, constant: 8.0)
            let leadingLineConstraint = NSLayoutConstraint(item: self.rightSidebarContentView, attribute: .Left, relatedBy: .Equal, toItem: line, attribute: .Leading, multiplier: 1, constant: 0)
            let trailingLineConstraint = NSLayoutConstraint(item: self.rightSidebarContentView, attribute: .Right, relatedBy: .Equal, toItem: line, attribute: .Trailing, multiplier: 1, constant: 0)
            self.rightSidebarContentView.addConstraints([topLineConstraint, leadingLineConstraint, trailingLineConstraint])
            return line
        }()
        
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
        self.leftSidebarBackgroundColor = UIColor.lightBlackGrayColor()
        
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
        if self.schedule == nil {
            return
        }
        self.enrolledCoursesTableViewDataSource.enrollments = self.schedule.courseSectionTypeEnrollments
        self.enrolledCoursesView.reloadData()
    }
    
    private func reloadScheduleView() {
        if self.schedule == nil {
            return
        }
        self.scheduleCollectionViewDataSource.enrollments = self.schedule.courseSectionTypeEnrollments
        self.scheduleView.reloadData()
    }
    
    private func reloadSearchViewController() {
        if self.schedule == nil {
            return
        }
        self.searchViewController.semesterTermCode = self.schedule.termCode
        self.searchViewController.enrolledCourses = self.schedule.enrolledCourses.toArray()
    }
    
    private func showCourseDeletePromptForCourse(course: Course) {
        if self.schedule == nil {
            return
        }
        assert(self.schedule.enrolledCourses.contains(course), "Trying to delete a course that wasn't enrolled")
        let alertController = UIAlertController(title: "Delete \(course)", message: "Are you sure you want to delete this course?", preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (alertAction: UIAlertAction!) -> Void in
            self.schedule.enrolledCourses.remove(course)
            self.schedule.updateCourseSectionTypeEnrollments()
            self.reloadEnrolledCoursesView()
            self.reloadScheduleView()
            self.reloadSearchViewController()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (_) -> Void in
            
        })
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
        assert(dataSource == self.enrolledCoursesTableViewDataSource, "Wrong data source object for enrolled courses view")
        self.schedule.courseSectionTypeEnrollments = dataSource.enrollments
        self.reloadScheduleView()
        self.saveSchedule()
    }
    
    // MARK: - Schedule Collection View Data Source Delegate
    func enrollmentDidChangeForScheduleCollectionViewDataSource(dataSource: ScheduleCollectionViewDataSource) {
        assert(dataSource == self.scheduleCollectionViewDataSource, "Wrong data source object for schedule view")
        self.schedule.courseSectionTypeEnrollments = dataSource.enrollments
        self.reloadEnrolledCoursesView()
        self.saveSchedule()
    }
    
    // MARK: - Course Search Table View Controller Delegate
    func enrollmentsDidChangeForCourseSearchTableViewController(viewController: CourseSearchTableViewController) {
        assert(viewController == self.searchViewController, "Wrong view controller")
        self.schedule.enrolledCourses = OrderedSet(initialValues: viewController.enrolledCourses)
        self.schedule.updateCourseSectionTypeEnrollments()
        self.reloadScheduleView()
        self.reloadEnrolledCoursesView()
        self.saveSchedule()
    }
}
