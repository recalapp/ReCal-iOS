//
//  CourseSearchTableViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let searchResultCellIdentifier = "SearchResult"
private let paddingCellIdentifier = "Padding"
private let courseDetailsViewControllerStoryboardId = "CourseDetails"

class CourseSearchTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    weak var delegate: CourseSearchTableViewControllerDelegate?
    
    var enrolledCourses: [Course] {
        set {
            self.enrolledCoursesSet = Set<Course>(initialItems: newValue)
        }
        get {
            return self.enrolledCoursesSet.toArray()
        }
    }
    private var enrolledCoursesSet: Set<Course> = Set<Course>()
    var allCourses: [Course] = []
    private var filteredCourses: [Course] = []
    
    private var visibleCourses: [Course] {
        if self.searchController == nil || self.searchController.searchBar.text == "" {
            return self.allCourses // TODO display recommended courses instead?
        }
        return self.filteredCourses
    }
    
    private var visibleEnrolledCourses: [Course] {
        return self.visibleCourses.filter { self.enrolledCoursesSet.contains($0) }
    }
    
    private var visibleUnenrolledCourses: [Course] {
        return self.visibleCourses.filter { !self.enrolledCoursesSet.contains($0) }
    }

    lazy private var courseSearchPredicate: SearchPredicate<Course, String> = {
        // TODO add more predicates
        let titlePredicate = ClosureSearchPredicate<Course, String> { (course, query) in
            course.title.contains(query, caseSensitive: false)
        }
        let departmentCodePredicate = ClosureSearchPredicate<Course, String> { (course, query) in
            course.departmentCode.contains(query, caseSensitive: false)
        }
        let courseNumberPredicate = ClosureSearchPredicate<Course, String> { (course, query) in
            course.courseNumber.description.contains(query, caseSensitive: false)
        }
        return OrSearchPredicate(childPredicates: [titlePredicate, departmentCodePredicate, courseNumberPredicate])
    }()
    
    lazy private var courseDetailsViewController: CourseDetailsViewController = {
        return self.storyboard?.instantiateViewControllerWithIdentifier(courseDetailsViewControllerStoryboardId) as CourseDetailsViewController
    }()
    
    private var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.tableView.keyboardDismissMode = .OnDrag
        self.searchController = {
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.frame = CGRect(origin: CGPointZero, size: CGSize(width: self.tableView.bounds.size.width, height: 44))
            searchController.searchResultsUpdater = self
            searchController.searchBar.barStyle = .Black
            searchController.delegate = self
            searchController.dimsBackgroundDuringPresentation = false
            self.tableView.tableHeaderView = searchController.searchBar
            return searchController
        }()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func courseAtIndexPath(indexPath: NSIndexPath) -> Course {
        switch (indexPath.section, indexPath.row) {
        case (0, let row):
            assert(row/2 < self.visibleUnenrolledCourses.count, "Invalid index path")
            return self.visibleUnenrolledCourses[row/2]
        case (1, let row):
            assert(row/2 < self.visibleEnrolledCourses.count, "Invalid index path")
            return self.visibleEnrolledCourses[row/2]
        default:
            assertionFailure("not implemented")
        }
    }

    private func indexPathForCourse(course: Course) -> NSIndexPath {
        let toSearch = self.enrolledCoursesSet.contains(course) ? self.visibleEnrolledCourses : self.visibleUnenrolledCourses
        let indexes = arrayFindIndexesOfElement(array: toSearch, element: course)
        assert(indexes.count != 0, "Trying to search for a course that is not visible")
        assert(indexes.count == 1, "Duplicate courses")
        let section = self.enrolledCoursesSet.contains(course) ? 1 : 0
        return NSIndexPath(forRow: indexes.last! * 2  + 1, inSection: section)
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
            return self.visibleUnenrolledCourses.count * 2
        case 1:
            return self.visibleEnrolledCourses.count * 2
        default:
            assertionFailure("not implemented")
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row % 2 == 1 {
            return 66
        } else {
            return 8 // padding
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row % 2 == 1
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.darkBlackGrayColor()
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
        label.textColor = UIColor.lightTextColor()
        return headerView
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(searchResultCellIdentifier, forIndexPath: indexPath) as CourseSearchResultTableViewCell
            
            let course = self.courseAtIndexPath(indexPath)
            
            cell.course = course
            if self.enrolledCoursesSet.contains(course) {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
            
            return cell
        }
        else {
            return tableView.dequeueReusableCellWithIdentifier(paddingCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        }
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
        self.delegate?.enrollmentsDidChangeForCourseSearchTableViewController(self)
        let newIndexPath = self.indexPathForCourse(course)
        tableView.beginUpdates()
        tableView.moveRowAtIndexPath(NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section), toIndexPath: NSIndexPath(forRow: newIndexPath.row - 1, inSection: newIndexPath.section))
        tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
        tableView.endUpdates()
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let course = self.courseAtIndexPath(indexPath)
        assert(!self.enrolledCoursesSet.contains(course), "Selecting an selected cell")
        self.enrolledCoursesSet.add(course)
        self.delegate?.enrollmentsDidChangeForCourseSearchTableViewController(self)
        let newIndexPath = self.indexPathForCourse(course)
        tableView.beginUpdates()
        tableView.moveRowAtIndexPath(NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section), toIndexPath: NSIndexPath(forRow: newIndexPath.row - 1, inSection: newIndexPath.section))
        tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
        tableView.endUpdates()
    }
    
    // MARK: - Search Results Updating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController == self.searchController {
            let query = searchController.searchBar.text
            self.filteredCourses = self.allCourses.filter { self.courseSearchPredicate.evaluate($0, withQuery: query) }
            self.tableView.reloadData()
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

