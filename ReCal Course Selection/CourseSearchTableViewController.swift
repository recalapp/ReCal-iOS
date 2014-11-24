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
    
    weak var delegate: CourseSearchTableViewControllerDelegate?
    
    var semesterTermCode: String = ""
    
    var enrolledCourses: [Course] {
        set {
            self.enrolledCoursesSet = Set<Course>(initialItems: newValue)
            self.clearVisibleCoursesStorageCache()
            self.tableView.reloadData()
        }
        get {
            return self.enrolledCoursesSet.toArray()
        }
    }
    private var enrolledCoursesSet: Set<Course> = Set<Course>()
    
    private var filteredCourses: [Course] = [] {
        didSet {
            self.clearVisibleCoursesStorageCache()
        }
    }
    
    private var visibleCourses: [Course] {
        if self.searchController != nil && self.searchController.searchBar.text == "" {
            return self.enrolledCourses
        }
        return self.filteredCourses
    }
    
    private var visibleEnrolledCourses: [Course] = []
    
    private var visibleUnenrolledCourses: [Course] = []
    
    lazy private var courseDetailsViewController: CourseDetailsViewController = {
        return self.storyboard?.instantiateViewControllerWithIdentifier(courseDetailsViewControllerStoryboardId) as CourseDetailsViewController
    }()
    
    private var searchController: UISearchController!
    
    lazy private var searchOperationQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .UserInitiated
        return queue
    }()
    
    private var searchManagedObjectContext: NSManagedObjectContext!
    
    private var notificationObservers: [AnyObject] = []
    
    private func clearVisibleCoursesStorageCache() {
        self.visibleEnrolledCourses = self.visibleCourses.filter { self.enrolledCoursesSet.contains($0) }
        self.visibleUnenrolledCourses = self.visibleCourses.filter { !self.enrolledCoursesSet.contains($0) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchOperationQueue.addOperationWithBlock {
            self.searchManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            self.searchManagedObjectContext.persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as AppDelegate).persistentStoreCoordinator
        }
        self.searchOperationQueue.waitUntilAllOperationsAreFinished()
        self.definesPresentationContext = true
        self.tableView.keyboardDismissMode = .OnDrag
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func courseAtIndexPath(indexPath: NSIndexPath) -> Course {
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

    private func indexPathForCourse(course: Course) -> NSIndexPath? {
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
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
            label.text = "Unenrolled"
        case 1:
            label.text = "Enrolled"
        default:
            assertionFailure("not implemented")
        }
        label.textColor = Settings.currentSettings.colorScheme.textColor
        return headerView
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: Table View Delegate
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let course = self.courseAtIndexPath(indexPath)
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
        
        self.enrolledCoursesSet.remove(course)
        self.clearVisibleCoursesStorageCache()
        if let newIndexPath = self.indexPathForCourse(course) {
            tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
        } else {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        self.delegate?.enrollmentsDidChangeForCourseSearchTableViewController(self)
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
                let filtered = courses.sorted { $0.displayText < $1.displayText }.map { Course(managedObject:$0) }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

protocol CourseSearchTableViewControllerDelegate: class {
    func enrollmentsDidChangeForCourseSearchTableViewController(viewController: CourseSearchTableViewController)
}

