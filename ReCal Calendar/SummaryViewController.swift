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

class SummaryViewController: UITableViewController, SummaryDayTableViewCellDelegate {
    weak var delegate: SummaryViewControllerDelegate?
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
    
    private var topDateStorage = NSDate()
    
    var topDate: NSDate {
        get {
            return topDateStorage
        }
        set {
            topDateStorage = newValue.dateWithZeroHour
            if let index = self.nearestIndexPathForDate(topDateStorage) {
                self.tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Top, animated: false)
            }
        }
    }
    
    private var notificationObservers: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadTableViewData()
        
        let updateColorScheme: Void->Void = {
            self.view.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
        }
        updateColorScheme()
        
        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateColorScheme()
        }
        self.notificationObservers.append(observer1)
    }
    
    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
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
    
    private func nearestIndexPathForDate(var date: NSDate)->NSIndexPath? {
        date = date.dateWithZeroHour
        var prev: NSIndexPath?
        for (index, section) in enumerate(self.fetchedResultsController.sections!) {
            if let event = (section as? NSFetchedResultsSectionInfo)?.objects.last as? CDEvent {
                let startDate = event.eventStart.dateWithZeroHour
                switch date.compare(startDate) {
                case .OrderedAscending:
                    break
                case .OrderedDescending:
                    prev = NSIndexPath(forItem: 0, inSection: index)
                    continue
                case .OrderedSame:
                    return NSIndexPath(forItem: 0, inSection: index)
                }
            }
        }
        return prev
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
        cell.delegate = self
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
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.tableView {
            let indexesOpt = self.tableView.indexPathsForVisibleRows() as? [NSIndexPath]
            if let indexes = indexesOpt {
                let visibleIndexOpt = indexes.reduce(nil) { (previousMinOpt: NSIndexPath?, curIndexPath: NSIndexPath) -> NSIndexPath? in
                    if let previousMin = previousMinOpt {
                        if curIndexPath.section < previousMin.section {
                            return curIndexPath
                        } else if curIndexPath.section == previousMin.section && curIndexPath.row < previousMin.row {
                            return curIndexPath
                        }
                        return previousMin
                    } else {
                        return curIndexPath
                    }
                }
                if let visibleIndex = visibleIndexOpt {
                    if let event = (self.fetchedResultsController.sections?[visibleIndex.section] as? NSFetchedResultsSectionInfo)?.objects.last as? CDEvent {
                        self.topDateStorage = event.eventStart.dateWithZeroHour // bypass the observer
                        self.delegate?.summaryViewController(self, didScrollToVisibleDate: self.topDate)
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Summary Day Table View Cell Delegate
    
    func summaryDayTableViewCell(summaryDayTableViewCell: SummaryDayTableViewCell, didSelectEvent event: SummaryDayViewEvent) {
        if let adapter = event as? SummaryDayViewEventAdapter {
            self.delegate?.summaryViewController(self, didSelectEventWithManagedObjectId: adapter.managedObjectId)
        }
    }
    
    // MARK: - Declarations
    struct SummaryDayViewEventAdapter : SummaryDayViewEvent {
        let title: String
        let time: SummaryDayView.EventTime
        let color: UIColor
        let highlightedColor: UIColor
        let managedObjectId: NSManagedObjectID
        init(event: CDEvent) {
            self.title = "\(event.section.course.displayText) \(event.eventTitle)"
            self.time = SummaryDayView.EventTime(startHour: event.eventStart.hour, startMinute: event.eventStart.minute, endHour: event.eventEnd.hour, endMinute: event.eventEnd.minute)
            self.highlightedColor = event.color!.darkerColor().darkerColor()
            self.color = event.color!.lighterColor().lighterColor()
            self.managedObjectId = event.objectID
        }
    }
}

protocol SummaryViewControllerDelegate: class {
    func summaryViewController(summaryViewController: SummaryViewController, didSelectEventWithManagedObjectId managedObjectId: NSManagedObjectID)
    func summaryViewController(summaryViewController: SummaryViewController, didScrollToVisibleDate date: NSDate)
}