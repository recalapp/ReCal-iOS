//
//  AgendaViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/10/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class AgendaViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadTableViewData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private let agendaCellIdentifier = "AgendaCell"
    private let paddingCellIdentifier = "Padding"
    
    private subscript(indexPath: NSIndexPath)->CDEvent {
        get {
            return self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row / 2, inSection: indexPath.section)) as CDEvent
        }
    }
    
    lazy private var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as AppDelegate).persistentStoreCoordinator
        return managedObjectContext
    }()
    
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "CDEvent")
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let today = NSDate()
        
        let startDate: NSDate = {
            let components = calendar.components(NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear, fromDate: today)
            components.day -= 1
            return calendar.dateFromComponents(components)!
            }()
        
        let endDate: NSDate = {
            let components = calendar.components(NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear, fromDate: today)
            components.day = 0
            components.month += 1 // TODO what about december
            return calendar.dateFromComponents(components)!
            }()
        let startPredicate = NSPredicate(format: "eventStart > %@", startDate)!
        let endPredicate = NSPredicate(format: "eventStart < %@", endDate)!
        fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates([startPredicate, endPredicate])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "eventStart", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "agendaSection", cacheName: "agendaCache")
        return fetchedResultsController
    }()
    
    var numberOfSections: Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    private func numberOfRowsInSection(section: Int) -> Int {
        return (self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo).numberOfObjects * 2
    }
    
    private func titleForSection(section: Int) -> String {
        return (self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo).name ?? "No Name"
    }
    
    private func reloadTableViewData() {
        var errorOpt: NSError?
        NSFetchedResultsController.deleteCacheWithName("agendaCache")
        self.managedObjectContext.performBlockAndWait {
            let _ = self.fetchedResultsController.performFetch(&errorOpt)
        }
        if let error = errorOpt {
            println("Error fetching agenda data. Error: \(error)")
            return
        }
    }
    
    private func indexPathIsPadding(indexPath: NSIndexPath) -> Bool {
        return indexPath.row % 2 != 0
    }
    
    // MARK: - Table View Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.numberOfSections
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRowsInSection(section)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.titleForSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !self.indexPathIsPadding(indexPath) {
            let cell = tableView.dequeueReusableCellWithIdentifier(agendaCellIdentifier, forIndexPath: indexPath) as AgendaTableViewCell
            
            let event = self[indexPath]
            // TODO display event
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(paddingCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            
            return cell
        }
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
    
    
    // MARK: - Declarations
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}