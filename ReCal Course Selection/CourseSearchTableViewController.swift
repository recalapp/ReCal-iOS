//
//  CourseSearchTableViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import CoreData
import ReCalCommon

private let searchResultCellIdentifier = "SearchResult"
private let paddingCellIdentifier = "Padding"
private let courseDetailsViewControllerStoryboardId = "CourseDetails"

class CourseSearchTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // MARK: Variables
    weak var delegate: CourseSearchTableViewControllerDelegate?
    
    /// The semester term code to search in
    var semesterTermCode: String = "" {
        didSet {
            self.searchController.active = false
        }
    }
    
    /// Enrolled courses, represented as an Array<Course>
    var enrolledCourses: [Course] {
        set {
            let courseManagedObjects = newValue.map { (course: Course)->CDCourse? in
                switch course.managedObjectProxyId {
                case .Existing(let id):
                    var result: CDCourse?
                    self.searchManagedObjectContext.performBlockAndWait {
                        result = self.searchManagedObjectContext.objectWithID(id) as? CDCourse
                    }
                    return result
                case .NewObject:
                    assertionFailure("Cannot get here")
                    return nil
                }
            }
            self.enrolledCoursesSet = Set<CDCourse>(initialItems: courseManagedObjects.filter { $0 != nil }.map { $0! })
            self.clearVisibleCoursesStorageCache()
            self.tableView.reloadData()
        }
        get {
            return self.enrolledCoursesSet.toArray().map { Course(managedObject: $0) }
        }
    }
    
    /// Internal representation of enrolled courses, as a Set<CDCourse>
    private var enrolledCoursesSet: Set<CDCourse> = Set<CDCourse>()
    
    /// Filtered set of courses
    private var filteredCourses: [CDCourse] = [] {
        didSet {
            self.clearVisibleCoursesStorageCache()
        }
    }
    
    /// Visible courses that are also enrolled
    private var visibleEnrolledCourses: [CDCourse] = []
    
    /// Visible courses that are not enrolled
    private var visibleUnenrolledCourses: [CDCourse] = []
    
    /// View controller for displaying course details
    lazy private var courseDetailsViewController: CourseDetailsViewController = {
        return self.storyboard?.instantiateViewControllerWithIdentifier(courseDetailsViewControllerStoryboardId) as CourseDetailsViewController
    }()
    
    /// The controller for search
    private var searchController: UISearchController!
    
    /// Background operation queue for searching. We only allow one operation in this queue at a time (by cancelling before adding a new operation)
    lazy private var searchOperationQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .UserInitiated
        return queue
    }()
    
    /// Managed object context for searching
    private var searchManagedObjectContext: NSManagedObjectContext!
    
    private var notificationObservers: [AnyObject] = []
    
    // MARK: - Methods
    private func clearVisibleCoursesStorageCache() {
        self.visibleEnrolledCourses = self.enrolledCoursesSet.toArray().sorted { $0.displayText < $1.displayText }
        self.visibleUnenrolledCourses = self.filteredCourses.filter { !self.enrolledCoursesSet.contains($0) } // filtered courses already sorted
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up managed object context
        self.searchOperationQueue.addOperationWithBlock {
            self.searchManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            self.searchManagedObjectContext.persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as AppDelegate).persistentStoreCoordinator
        }
        self.searchOperationQueue.waitUntilAllOperationsAreFinished()
        
        // UI setups
        self.definesPresentationContext = true
        self.tableView.keyboardDismissMode = .OnDrag
        self.tableView.rowHeight = 66
        self.searchController = {
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.frame = CGRect(origin: CGPointZero, size: CGSize(width: self.tableView.bounds.size.width, height: 44))
            searchController.searchResultsUpdater = self
            searchController.delegate = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = false
            self.tableView.tableHeaderView = searchController.searchBar
            return searchController
        }()
        
        let observer = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { (notification) -> Void in
            self.searchManagedObjectContext.performBlockAndWait {
                self.searchManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            }
        }
        let updateWithColorScheme: ()->Void = {
            self.tableView.reloadData()
            switch Settings.currentSettings.theme {
            case .Light:
                self.searchController.searchBar.barStyle = .Default
                self.searchController.searchBar.keyboardAppearance = .Default
            case .Dark:
                self.searchController.searchBar.barStyle = .Black
                self.searchController.searchBar.keyboardAppearance = .Dark
            }
        }
        updateWithColorScheme()
        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateWithColorScheme()
        }
        self.notificationObservers.append(observer)
        self.notificationObservers.append(observer1)
    }
    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    private func courseAtIndexPath(indexPath: NSIndexPath) -> CDCourse {
        switch (indexPath.section, indexPath.row) {
        case (0, let row):
            assert(row < self.visibleUnenrolledCourses.count, "Invalid index path")
            return self.visibleUnenrolledCourses[row]
        case (1, let row):
            assert(row < self.visibleEnrolledCourses.count, "Invalid index path")
            return self.visibleEnrolledCourses[row]
        default:
            assertionFailure("not implemented")
        }
    }

    private func indexPathForCourse(course: CDCourse) -> NSIndexPath? {
        let toSearch = self.enrolledCoursesSet.contains(course) ? self.visibleEnrolledCourses : self.visibleUnenrolledCourses
        let indexes = arrayFindIndexesOfElement(array: toSearch, element: course)
        if indexes.count == 0 {
            return nil
        }
        assert(indexes.count <= 1, "Duplicate courses")
        let section = self.enrolledCoursesSet.contains(course) ? 1 : 0
        return NSIndexPath(forRow: indexes.last!, inSection: section)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        switch section {
        case 0:
            return self.visibleUnenrolledCourses.count
        case 1:
            return self.visibleEnrolledCourses.count
        default:
            assertionFailure("not implemented")
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = Settings.currentSettings.colorScheme.secondaryContentBackgroundColor
        let label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        headerView.addSubview(label)
        headerView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(label, inParentView: headerView, withInsets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)))
        switch section {
        case 0:
            label.text = "Search Results"
        case 1:
            label.text = "Enrolled"
        default:
            assertionFailure("not implemented")
        }
        label.textColor = Settings.currentSettings.colorScheme.textColor
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if self.visibleUnenrolledCourses.count == 0 {
                return 0
            }
        case 1:
            if self.visibleEnrolledCourses.count == 0 {
                return 0
            }
        default:
            assertionFailure("not implemented")
        }
        return 22
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCellWithIdentifier(searchResultCellIdentifier, forIndexPath: indexPath) as CourseSearchResultTableViewCell
        
        let course = self.courseAtIndexPath(indexPath)
        
        cell.course = course
        if self.enrolledCoursesSet.contains(course) {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
        
        return cell
    }

    // MARK: Table View Delegate
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let course = Course(managedObject: self.courseAtIndexPath(indexPath))
        if course == self.courseDetailsViewController.course {
            return
        } else {
            let present:()->Void = {
                let cell = tableView.cellForRowAtIndexPath(indexPath)!
                
                self.courseDetailsViewController.modalPresentationStyle = .Popover
                self.courseDetailsViewController.course = course
                self.courseDetailsViewController.popoverPresentationController?.delegate = self
                self.presentViewController(self.courseDetailsViewController, animated: true, completion: nil)
                
                let popoverPresentationController = self.courseDetailsViewController.popoverPresentationController
                popoverPresentationController?.permittedArrowDirections = .Left
                popoverPresentationController?.sourceView = cell
                popoverPresentationController?.sourceRect = cell.bounds
            }
            if self.presentedViewController == self.courseDetailsViewController {
                self.courseDetailsViewController.dismissViewControllerAnimated(false) {
                    present()
                }
            } else {
                present()
            }
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let course = self.courseAtIndexPath(indexPath)
        assert(self.enrolledCoursesSet.contains(course), "Deselecting an unselected cell")
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        self.delegate?.courseSearchTableViewController(self, shouldDeleteCourse: Course(managedObject: course))
//        self.enrolledCoursesSet.remove(course)
//        self.clearVisibleCoursesStorageCache()
//        if let newIndexPath = self.indexPathForCourse(course) {
//            tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
//        } else {
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//        }
//        self.delegate?.enrollmentsDidChangeForCourseSearchTableViewController(self)
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let course = self.courseAtIndexPath(indexPath)
        assert(!self.enrolledCoursesSet.contains(course), "Selecting an selected cell")
        
        self.enrolledCoursesSet.add(course)
        self.clearVisibleCoursesStorageCache()
        if let newIndexPath = self.indexPathForCourse(course) {
            tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
        } else {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        self.delegate?.enrollmentsDidChangeForCourseSearchTableViewController(self)
    }
    
    // MARK: - Search Results Updating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController == self.searchController {
            let query = searchController.searchBar.text
            let searchOperation = CourseSearchOperation(searchQuery: query, semesterTermCode: self.semesterTermCode, managedObjectContext: self.searchManagedObjectContext, successHandler: { (courses: [CDCourse]) in
                let filtered = courses.sorted { $0.displayText < $1.displayText }
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.filteredCourses = filtered
                    self.tableView.reloadData()
                })
            })
            self.searchOperationQueue.cancelAllOperations()
            self.searchOperationQueue.addOperation(searchOperation)
        }
    }
    // MARK: - Search Controller Delegate
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.setShowsCancelButton(false, animated: false)
    }
    // MARK: - Adaptive Presentation Controller Delegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: Popover Presentation Controller Delegate
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        if let course = self.courseDetailsViewController.course {
            self.courseDetailsViewController.course = nil
        }
    }
}

protocol CourseSearchTableViewControllerDelegate: class {
    func enrollmentsDidChangeForCourseSearchTableViewController(viewController: CourseSearchTableViewController)
    func courseSearchTableViewController(viewController: CourseSearchTableViewController, shouldDeleteCourse course: Course)
}

