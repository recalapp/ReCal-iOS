//
//  EventViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import CoreData
import ReCalCommon

class EventViewController: UITableViewController {
    private typealias SectionInfo = StaticTableViewDataSource.SectionInfo
    private typealias ItemInfo = StaticTableViewDataSource.ItemInfo
    private let basicCellIdentifier = "Basic"
    private let timeCellIdentifier = "Time"
    private let descriptionCellIdentifier = "Description"
    private let dataSource = StaticTableViewDataSource()
    
    weak var delegate: EventViewControllerDelegate?
    var eventObjectId: NSManagedObjectID? {
        didSet {
            if eventObjectId != nil {
                self.event = self.managedObjectContext.objectWithID(eventObjectId!) as? CDEvent
            }
        }
    }
    private var event: CDEvent? {
        didSet {
            if event != nil {
                self.navigationItem.title = event!.eventTitle
                self.navigationController?.navigationBar.barTintColor = event?.color
                self.tableView.reloadData()
            }
        }
    }
    
    private var notificationObservers: [AnyObject] = []
    
    lazy private var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as AppDelegate).persistentStoreCoordinator
        return managedObjectContext
    }()

    @IBOutlet weak var dismissButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { (notification) -> Void in
            if self.managedObjectContext.isEqual(notification.object) {
                return
            }
            self.managedObjectContext.performBlockAndWait {
                self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            }
        }
        self.notificationObservers.append(observer1)
        let updateColorScheme: ()->Void = {
            self.navigationController?.navigationBar.tintColor = Settings.currentSettings.colorScheme.textColor
            self.view.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
        }
        updateColorScheme()
        let observer2 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateColorScheme()
        }
        self.notificationObservers.append(observer2)
        
        let dateFormatter = NSDateFormatter.formatterWithUSLocale()
        dateFormatter.dateFormat = "EEEE, MMM d, y" // Tuesday, Nov 4, 2014
        let timeFormatter = NSDateFormatter.formatterWithUSLocale()
        timeFormatter.timeStyle = .ShortStyle
        let dateSection = SectionInfo(name: .Empty, items: [
            ItemInfo(cellIdentifier: self.basicCellIdentifier, cellProcessBlock: { (cell:UITableViewCell) -> UITableViewCell in
                if let event = self.event {
                    cell.textLabel?.text = dateFormatter.stringFromDate(event.eventStart)
                    
                }
                return cell
            }),
            ItemInfo(cellIdentifier: self.timeCellIdentifier, cellProcessBlock: { (cell: UITableViewCell) -> UITableViewCell in
                let timeCell = cell as EventTimeTableViewCell
                if let event = self.event {
                    timeCell.startLabel.text = timeFormatter.stringFromDate(event.eventStart)
                    timeCell.endLabel.text = timeFormatter.stringFromDate(event.eventEnd)
                }
                return timeCell
            })
        ])
        let descriptionSection = SectionInfo(name: .Literal("Description"), items: [
            ItemInfo(cellIdentifier: self.descriptionCellIdentifier, cellProcessBlock: { (cell) -> UITableViewCell in
                let descriptionCell = cell as EventDescriptionTableViewCell
                if let event = self.event {
                    descriptionCell.descriptionLabel.text = "Some really long text here\nMore text here, hopefully this overflows. Should overflow"
                }
                return descriptionCell
            })
        ])
        self.dataSource.setSectionInfos([dateSection, descriptionSection])
        self.tableView.dataSource = self.dataSource
    }
    
    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }

    @IBAction func dismissButtonTapped(sender: UIBarButtonItem) {
        self.delegate?.eventViewControllerDidTapDismissButton(self)
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

protocol EventViewControllerDelegate: class {
    func eventViewControllerDidTapDismissButton(eventViewController: EventViewController)
}
