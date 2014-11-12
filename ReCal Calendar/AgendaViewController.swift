//
//  AgendaViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/10/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

private let agendaCellIdentifier = "AgendaCell"
private let paddingCellIdentifier = "Padding"

class AgendaViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func indexPathIsPadding(indexPath: NSIndexPath) -> Bool {
        return indexPath.row % 2 != 0
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 10
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if !self.indexPathIsPadding(indexPath) {
            return 88
        } else {
            return 22
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !self.indexPathIsPadding(indexPath)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !self.indexPathIsPadding(indexPath) {
            let cell = tableView.dequeueReusableCellWithIdentifier(agendaCellIdentifier, forIndexPath: indexPath) as AgendaTableViewCell
            
            // Configure the cell...
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(paddingCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            
            return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

extension CDEvent {
    var agendaSection: AgendaSection? {
        return AgendaSection(date: self.eventStart)
    }
}

enum AgendaSection: String {
    case Yesterday = "Yesterday", Today = "Today", ThisWeek = "This Week", ThisMonth = "This Month"
    init?(date: NSDate) {
        let calendar = NSCalendar.currentCalendar()
        let today = NSDate()
        let interval = date.timeIntervalSinceDate(today)
        let unitFlags = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth
        let components = calendar.components(unitFlags, fromDate: today, toDate: date, options: NSCalendarOptions.allZeros)
        switch (components.day, components.month) {
        case (let day, _) where day < -1:
            return nil
        case (_, let month) where month >= 1:
            return nil
        case (let day, _) where day < 0:
            self = .Yesterday
        case (let day, _) where day < 1:
            self = .Today
        case (let day, _) where day < 7:
            self = .ThisWeek
        default:
            self = .ThisMonth
        }
    }
}