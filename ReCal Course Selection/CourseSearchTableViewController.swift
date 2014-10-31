//
//  CourseSearchTableViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

let searchResultCellIdentifier = "SearchResult"
let courseDetailsViewControllerStoryboardId = "CourseDetails"

class CourseSearchTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate  {

    private var courseDetailsViewController: CourseDetailsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.courseDetailsViewController = self.storyboard?.instantiateViewControllerWithIdentifier(courseDetailsViewControllerStoryboardId) as CourseDetailsViewController
//        let searchController = UISearchController(searchResultsController: self)
//        self.definesPresentationContext = true
//        self.tableView.tableHeaderView = searchController.searchBar
        
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
        return 10
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(searchResultCellIdentifier, forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

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
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == self.courseDetailsViewController?.indexPath {
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
