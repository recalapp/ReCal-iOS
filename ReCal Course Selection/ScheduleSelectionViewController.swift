//
//  ScheduleSelectionViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/6/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let scheduleCellIdentifier = "ScheduleCell"

class ScheduleSelectionViewController: UITableViewController {
    weak var delegate: ScheduleSelectionDelegate?
    
    lazy private var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as AppDelegate).persistentStoreCoordinator
        return managedObjectContext
        }()
    private var visibleSemesters: [CDSemester] = []
    private var semesterToSchedulesMapping: Dictionary<CDSemester, [CDSchedule]> = Dictionary() {
        didSet {
            self.visibleSemesters = self.semesterToSchedulesMapping.keys.array.sorted { $0.termCode < $1.termCode }
        }
    }
    
    private var notificationObservers: [AnyObject] = []

    private func fetchSchedules() {
        let fetchRequest = NSFetchRequest(entityName: "CDSemester")
        fetchRequest.predicate = NSPredicate(format: "schedules.@count > 0")
        var fetched: [CDSemester]?
        var errorOpt: NSError?
        self.managedObjectContext.performBlockAndWait {
            fetched = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt) as? [CDSemester]
        }
        if let error = errorOpt {
            println("Error fetching schedules. Error: \(error)")
            return
        }
        if let semesters = fetched {
            var newMapping: Dictionary<CDSemester, [CDSchedule]> = Dictionary()
            for semester in semesters {
                newMapping[semester] = (semester.schedules.allObjects as [CDSchedule]).sorted { $0.name < $1.name }
            }
            self.semesterToSchedulesMapping = newMapping
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let updateColorScheme: ()->Void = {
            self.tableView.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
            self.tableView.reloadData()
        }
        updateColorScheme()
        let observer = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { (notification) -> Void in
            self.managedObjectContext.performBlockAndWait {
                self.managedObjectContext.mergeChangesFromContextDidSaveNotification    (notification)
            }
            self.fetchSchedules()
        }
        self.notificationObservers.append(observer)
        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateColorScheme()
        }
        self.notificationObservers.append(observer1)
        self.fetchSchedules()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    
    private func scheduleAtIndexPath(indexPath: NSIndexPath) -> CDSchedule? {
        return self.semesterToSchedulesMapping[self.visibleSemesters[indexPath.section]]?[indexPath.row]
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return self.visibleSemesters.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        let semester = self.visibleSemesters[section]
        return self.semesterToSchedulesMapping[semester]?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.visibleSemesters[section].termCode
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(scheduleCellIdentifier, forIndexPath: indexPath) as UITableViewCell

        cell.textLabel.textColor = Settings.currentSettings.colorScheme.textColor
        cell.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
        if let schedule = self.scheduleAtIndexPath(indexPath) {
            cell.textLabel.text = schedule.name
        } else {
            cell.textLabel.text = "(Empty)"
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
    
    // MARK: - Table View Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let schedule = self.scheduleAtIndexPath(indexPath) {
            self.delegate?.didSelectScheduleWithObjectId(schedule.objectID)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let scheduleCreationViewController = segue.destinationViewController as? ScheduleCreationViewController {
            scheduleCreationViewController.delegate = self.delegate
            scheduleCreationViewController.managedObjectContext = self.managedObjectContext
        }
    }
    

}
