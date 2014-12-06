//
//  SummaryViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let summaryDayCellIdentifier = "SummaryDayCell"

class SummaryViewController: UITableViewController {
    
    lazy private var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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
        let startPredicate = NSPredicate(format: "eventStart > %@", startDate)!
        fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates([startPredicate])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "eventStart", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "eventStartWithZeroHour", cacheName: "eventStartWithZeroHour")
        return fetchedResultsController
        }()
    
    lazy private var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter.formatterWithUSLocale()
        formatter.dateStyle = .MediumStyle
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadTableViewData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    private func reloadTableViewData() {
        var errorOpt: NSError?
        NSFetchedResultsController.deleteCacheWithName("eventStartWithZeroHour")
        self.managedObjectContext.performBlockAndWait {
            let _ = self.fetchedResultsController.performFetch(&errorOpt)
        }
        if let error = errorOpt {
            println("Error fetching event data. Error: \(error)")
            return
        }
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table View Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(summaryDayCellIdentifier, forIndexPath: indexPath) as SummaryDayTableViewCell
        if let events = (self.fetchedResultsController.sections?[indexPath.section] as? NSFetchedResultsSectionInfo)?.objects as? [CDEvent] {
            cell.viewModel = SummaryDayView.SummaryDayViewModel(events: events.map{SummaryDayViewEventAdapter(event: $0)})
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SummaryDayHeaderView()
        if let event = (self.fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo)?.objects.last as? CDEvent {
            view.headerLabel.text = self.dateFormatter.stringFromDate(event.eventStart)
        }
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    struct SummaryDayViewEventAdapter : SummaryDayViewEvent {
        let title: String
        let time: SummaryDayView.EventTime
        let color: UIColor
        let highlightedColor: UIColor
        init(event: CDEvent) {
            self.title = event.eventTitle
            self.time = SummaryDayView.EventTime(startHour: event.eventStart.hour, startMinute: event.eventStart.minute, endHour: event.eventEnd.hour, endMinute: event.eventEnd.minute)
            self.highlightedColor = event.color!.darkerColor().darkerColor()
            self.color = event.color!.lighterColor().lighterColor()
        }
    }
}