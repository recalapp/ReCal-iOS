//
//  WeekViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/18/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class WeekViewController: UICollectionViewController, CollectionViewDataSourceCalendarWeekLayout {

    // MARK: Constants
    private let eventCellIdentifier = "EventsCell"
    private let dayColumnHeaderViewIdentifier = "DayHeader"
    private let timeRowHeaderViewIdentifier = "TimeHeader"
    private let minimumHour = 6
    private let maximumHour = 23
    private let hourStep = 1
    private let numberOfVisibleDays = 100
    
    // MARK: Variables
    weak var delegate: WeekViewControllerDelegate?
    private var centerDateStorage: NSDate = NSDate()
    
    var centerDate: NSDate {
        get {
            return centerDateStorage
        }
        set {
            centerDateStorage = self.zeroOutHourForDate(newValue)
            // this does the right invalidation of layout
            let contentOffset = self.layout.contentOffsetForSection(self.sectionForCenterDate)
            self.collectionView?.setContentOffset(contentOffset, animated: false)
            self.collectionView?.reloadData()
        }
    }
    
    private var todayDate: NSDate {
        return self.zeroOutHourForDate(NSDate())
    }
    
    private var sectionForCenterDate: Int {
        return self.sectionForDate(self.centerDate)
    }
    
    lazy private var calendar: NSCalendar = {
        let calendarOpt = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        assert(calendarOpt != nil, "Calendar cannot be nil")
        return calendarOpt!
    }()
    
    private var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h a" // 9 AM
        return formatter
    }()
    
    private var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d" // Dec 7
        return formatter
    }()
    
    private var dayFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE" // Tues
        return formatter
    }()
    
    lazy private var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as AppDelegate).persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private var eventsIdCache: Cache<NSDate, [NSManagedObjectID]> = Cache()
    
    private var notificationObservers: [AnyObject] = []
    
    private weak var layout: CollectionViewCalendarWeekLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventsIdCache.itemConstructor = { (date: NSDate)->[NSManagedObjectID] in
            let fetchRequest: NSFetchRequest = {
                let components = self.calendar.components(NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitYear, fromDate: date)
                components.minute = 0
                components.second = 0
                components.hour = 0
                let startDate = self.calendar.dateFromComponents(components)!
                components.day += 1
                let endDate = self.calendar.dateFromComponents(components)!
                let fetchRequest = NSFetchRequest(entityName: "CDEvent")
                fetchRequest.resultType = NSFetchRequestResultType.ManagedObjectIDResultType
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "eventStart", ascending: true)]
                fetchRequest.predicate = NSPredicate(format: "eventStart <= %@ AND eventStart >= %@", endDate, startDate)
                return fetchRequest
            }()
            var errorOpt: NSError?
            var fetched: [NSManagedObjectID]?
            self.managedObjectContext.performBlockAndWait {
                fetched = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt) as? [NSManagedObjectID]
            }
            if let error = errorOpt {
                println("Error fetching IDs. error: \(error)")
            }
            if fetched != nil {
                return fetched!
            } else {
                return []
            }
        }
        
        self.layout = self.collectionViewLayout as CollectionViewCalendarWeekLayout
        layout.dataSource = self
        self.collectionView?.registerNib(UINib(nibName: "EventCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: eventCellIdentifier)
        self.collectionView?.registerNib(UINib(nibName: "TimeRowHeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: CollectionViewCalendarWeekLayoutSupplementaryViewKind.TimeRowHeader.rawValue, withReuseIdentifier: timeRowHeaderViewIdentifier)
        self.collectionView?.registerNib(UINib(nibName: "DayColumnHeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: CollectionViewCalendarWeekLayoutSupplementaryViewKind.DayColumnHeader.rawValue, withReuseIdentifier: dayColumnHeaderViewIdentifier)
        layout.registerClass(TimeRowHeaderBackgroundView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.TimeRowHeaderBackground.rawValue)
        layout.registerClass(DayColumnHeaderBackgroundView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.DayColumnHeaderBackground.rawValue)
        layout.registerClass(GridLineView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.HorizontalGridLine.rawValue)
        layout.registerClass(GridLineView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.VerticalGridLine.rawValue)
        
        let updateColorScheme: Void -> Void = {
            self.collectionView!.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
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
    
    func dateForSection(section: Int) -> NSDate {
        let deltaSection = section - self.sectionForCenterDate
        let date = self.calendar.dateByAddingUnit(NSCalendarUnit.DayCalendarUnit, value: deltaSection, toDate: self.centerDate, options: NSCalendarOptions.allZeros)!
        return date
    }
    
    func sectionForDate(date: NSDate) -> Int {
        let dayDelta = self.calendar.components(NSCalendarUnit.DayCalendarUnit, fromDate: date, toDate: self.centerDate, options: NSCalendarOptions.allZeros).day
        return self.numberOfVisibleDays / 2 - dayDelta
    }

    private func eventForIndexPath(indexPath: NSIndexPath) -> CDEvent? {
        let objectIds = self.eventsIdCache[self.dateForSection(indexPath.section)]
        if indexPath.item < objectIds.count {
            return self.managedObjectContext.objectWithID(objectIds[indexPath.item]) as? CDEvent
        } else {
            return nil
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.numberOfVisibleDays
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.eventsIdCache[self.dateForSection(section)].count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(eventCellIdentifier, forIndexPath: indexPath) as EventCollectionViewCell
        if let event = self.eventForIndexPath(indexPath) {
            cell.viewModel = EventCellViewModelAdapter(event: event)
        } else {
            cell.viewModel = nil
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let getViewIdentifier:(CollectionViewCalendarWeekLayoutSupplementaryViewKind)->String = {(type) in
            switch type {
            case .DayColumnHeader:
                return self.dayColumnHeaderViewIdentifier
            case .TimeRowHeader:
                return self.timeRowHeaderViewIdentifier
            }
        }
        if let viewType = CollectionViewCalendarWeekLayoutSupplementaryViewKind(rawValue: kind) {
            let supplementaryView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: getViewIdentifier(viewType), forIndexPath: indexPath) as UICollectionReusableView
            switch viewType {
            case .DayColumnHeader:
                let date = self.dateForSection(indexPath.section)
                let dayColumnHeaderView = supplementaryView as DayColumnHeaderView
                dayColumnHeaderView.weekDayLabel.text = self.dayFormatter.stringFromDate(date)
                dayColumnHeaderView.dateLabel.text = self.dateFormatter.stringFromDate(date)
                dayColumnHeaderView.type = indexPath.section == self.sectionForDate(todayDate)  ? .Today : .Normal
            case .TimeRowHeader:
                let hour = self.minimumHour + indexPath.indexAtPosition(0) * self.hourStep
                let timeRowHeaderView = supplementaryView as TimeRowHeaderView
                let timeComponent = NSDateComponents()
                timeComponent.hour = hour
                let time = self.calendar.dateFromComponents(timeComponent)!
                timeRowHeaderView.timeLabel.text = self.timeFormatter.stringFromDate(time)
            }
            
            return supplementaryView
        }
        assert(false, "Invalid supplementary view type")
    }
    
    private func zeroOutHourForDate(date: NSDate) -> NSDate {
        let component = self.calendar.components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: date)
        component.minute = 0
        component.hour = 0
        component.second = 0
        return self.calendar.dateFromComponents(component)!
    }

    // MARK: UICollectionViewDelegate

    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        assert(scrollView === self.collectionView)
        if !decelerate {
            // adjust data source so that the visible day become the center day again
            self.centerDate = self.dateForSection(self.layout.firstVisibleSection)
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        assert(scrollView === self.collectionView)
        // adjust data source so that the visible day become the center day again
        self.centerDate = self.dateForSection(self.layout.firstVisibleSection)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let eventOpt = self.eventForIndexPath(indexPath)
        assert(eventOpt != nil)
        if let event = eventOpt {
            self.delegate?.weekViewController(self, didSelectEventWithManagedObjectId: event.objectID)
        }
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    // MARK: - Calendar Week View Layout Data Source
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate? {
        return self.eventForIndexPath(indexPath)?.eventStart
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate? {
        return self.eventForIndexPath(indexPath)?.eventEnd
    }

    /// Return the width for a day
    func daySectionWidthForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->CollectionViewCalendarWeekLayoutDaySectionWidth {
        return CollectionViewCalendarWeekLayoutDaySectionWidth.VisibleNumberOfDays(6)
    }
    
    /// Return the height of the week view (scrollable height, not frame height)
    func heightForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->CollectionViewCalendarWeekLayoutHeight {
        let height: Float = Float(collectionView.bounds.height) * 3
        return CollectionViewCalendarWeekLayoutHeight.Exact(height)
    }
    
    /// Return the height of the day header
    func dayColumnHeaderHeightForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Float {
        return 60.0
    }
    
    /// Return the width of the time header
    func timeRowHeaderWidthForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Float {
        return 70.0
    }
    
    /// Return the minimum hour, from 0 to 23
    func minimumHourForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Int {
        return self.minimumHour
    }
    
    /// Return the maximum hour, from 1 to 24. This is the first hour not seen. For example, setting this to 10 means that you will see the hour 9-10, but not 10-11
    func maximumHourForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Int {
        return self.maximumHour
    }
    
    /// Return how many hours (can be fractional) each vertical slot represent
    func hourStepForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Float {
        return Float(self.hourStep)
    }
}

protocol WeekViewControllerDelegate: class {
    func weekViewController(weekViewController: WeekViewController, didSelectEventWithManagedObjectId managedObjectId: NSManagedObjectID)
}

struct EventCellViewModelAdapter: EventCellViewModel {
    let title: String
    let highlightedColor: UIColor
    let normalColor: UIColor
    
    init(event: CDEvent) {
        self.title = "\(event.section.course.primaryListing.displayText) \(event.eventTitle)"
        self.highlightedColor = event.color!.darkerColor().darkerColor()
        self.normalColor = event.color!.lighterColor().lighterColor()
    }
}
