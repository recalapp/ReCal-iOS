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
    
    private let basicCellIdentifier = "Basic"
    private let timeCellIdentifier = "Time"
    private let descriptionCellIdentifier = "Description"
    
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
    
    private var sections: [SectionInfo] = []
    
    lazy private var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as AppDelegate).persistentStoreCoordinator
        return managedObjectContext
    }()

    @IBOutlet weak var dismissButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { (notification) -> Void in
            self.managedObjectContext.performBlockAndWait {
                self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            }
        }
        self.notificationObservers.append(observer1)
        
        self.dismissButton.title = "\u{2573} "
        self.navigationController?.navigationBar.tintColor = Settings.currentSettings.colorScheme.textColor
        self.view.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, y" // Tuesday, Nov 4, 2014
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = .ShortStyle
        let dateSection = SectionInfo(name: .Empty, items: [
            ItemInfo(cellIdentifier: self.basicCellIdentifier, cellProcessBlock: { (cell:UITableViewCell) -> UITableViewCell in
                if let event = self.event {
                    cell.textLabel.text = dateFormatter.stringFromDate(event.eventStart)
                    
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
        self.sections = [dateSection, descriptionSection]
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

    @IBAction func dismissButtonTapped(sender: UIBarButtonItem) {
        self.delegate?.eventViewControllerDidTapDismissButton(self)
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return self.sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self[section].numberOfItems
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let itemInfo = self[indexPath.section, indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(itemInfo.cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.textColor = Settings.currentSettings.colorScheme.textColor
        cell.detailTextLabel?.textColor = Settings.currentSettings.colorScheme.textColor
        cell.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
        return itemInfo.cellProcessBlock(cell)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = self[section]
        switch sectionInfo.name {
        case .Literal(let name):
            return name
        case .Empty:
            return nil
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
    
    subscript(sectionIndex: Int)->SectionInfo {
        return self.sections[sectionIndex]
    }
    subscript(sectionIndex: Int, itemIndex: Int)->ItemInfo {
        return self.sections[sectionIndex][itemIndex]
    }
    
    struct SectionInfo {
        let name: SectionName
        let items: [ItemInfo]
        var numberOfItems: Int {
            return items.count
        }
        subscript(itemIndex: Int)->ItemInfo {
            return items[itemIndex]
        }
        enum SectionName {
            case Literal(String)
            case Empty
        }
    }
    struct ItemInfo {
        let cellIdentifier: String
        let cellProcessBlock: (UITableViewCell)->UITableViewCell
    }
}

protocol EventViewControllerDelegate: class {
    func eventViewControllerDidTapDismissButton(eventViewController: EventViewController)
}
