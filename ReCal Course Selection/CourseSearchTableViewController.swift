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
    
    var enrolledCourses: [Course] = []
    var allCourses: [Course] = []
    private var filteredCourses: [Course] = []
    
    private var visibleCourses: [Course] {
        if self.searchController == nil || self.searchController.searchBar.text == "" {
            return self.allCourses // TODO display recommended courses instead?
        }
        return self.filteredCourses
    }

    lazy private var courseSearchPredicate: SearchPredicate<Course, String> = {
        // TODO add more predicates
        let departmentCodePredicate = ClosureSearchPredicate<Course, String> { (course, query) in
            course.departmentCode.contains(query, caseSensitive: false)
        }
        let courseNumberPredicate = ClosureSearchPredicate<Course, String> { (course, query) in
            course.courseNumber.description.contains(query, caseSensitive: false)
        }
        return OrSearchPredicate(childPredicates: [departmentCodePredicate, courseNumberPredicate])
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

    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.visibleCourses.count * 2
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(searchResultCellIdentifier, forIndexPath: indexPath) as CourseSearchResultTableViewCell
            
            cell.course = self.visibleCourses[indexPath.row / 2]
            
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
        if indexPath == self.courseDetailsViewController.indexPath {
            return
        } else {
            let present:()->Void = {
                let cell = tableView.cellForRowAtIndexPath(indexPath)!
                
                self.courseDetailsViewController.modalPresentationStyle = .Popover
                self.courseDetailsViewController.indexPath = indexPath
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
        if let indexPath = self.courseDetailsViewController.indexPath {
            self.courseDetailsViewController.indexPath = nil
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
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
