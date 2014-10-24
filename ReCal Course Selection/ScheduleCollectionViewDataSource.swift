//
//  ScheduleCollectionViewDataSource.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon



class ScheduleCollectionViewDataSource: NSObject, UICollectionViewDataSource, CollectionViewDataSourceCalendarWeekLayout {
    
    // MARK: constants
    private let eventCellIdentifier = "EventsCell"
    private let dayColumnHeaderViewIdentifier = "DayHeader"
    private let timeRowHeaderViewIdentifier = "TimeHeader"
    private let minimumHour = 8
    private let maximumHour = 22
    private let hourStep = 2
    
    
    // MARK: variables
    lazy private var calendar: NSCalendar = {
        let calendarOpt = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        assert(calendarOpt != nil, "Calendar cannot be nil")
        return calendarOpt!
    }()
    
    lazy private var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    var events: [ScheduleEvent] = []
    
    // MARK: methods
    /// Register the collection view and layout with the appropriate view classes
    func registerReusableViewsWithCollectionView(collectionView: UICollectionView, forLayout layout: UICollectionViewLayout) {
        collectionView.registerNib(UINib(nibName: "EventCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: eventCellIdentifier)
        collectionView.registerNib(UINib(nibName: "TimeRowHeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: CollectionViewCalendarWeekLayoutSupplementaryViewKind.TimeRowHeader.rawValue, withReuseIdentifier: timeRowHeaderViewIdentifier)
        collectionView.registerNib(UINib(nibName: "DayColumnHeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: CollectionViewCalendarWeekLayoutSupplementaryViewKind.DayColumnHeader.rawValue, withReuseIdentifier: dayColumnHeaderViewIdentifier)
        layout.registerClass(TimeRowHeaderBackgroundView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.TimeRowHeaderBackground.rawValue)
        layout.registerClass(DayColumnHeaderBackgroundView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.DayColumnHeaderBackground.rawValue)
        layout.registerClass(GridLineView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.HorizontalGridLine.rawValue)
        layout.registerClass(GridLineView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.VerticalGridLine.rawValue)
    }
    
    /// Returns an array of events for day
    func eventsForDay(day: Day) -> [ScheduleEvent] {
        let filtered = self.events.filter { (event) in arrayContainsElement(array: event.days, element: day) }
        return filtered
    }
    
    /// Returns the event for index path
    func eventForIndexPath(indexPath: NSIndexPath) -> ScheduleEvent {
        let dayOpt = Day(rawValue: indexPath.section)
        assert(dayOpt != nil, "If dayOpt is nil, then the section value passed in is wrong")
        let day = dayOpt!
        let events = self.eventsForDay(day)
        assert(indexPath.row < events.count, "If row is bigger than the number of events, then the row value passed in is wrong")
        return events[indexPath.row]
    }
    
    // MARK: - Collection View Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dayOpt = Day(rawValue: section)
        assert(dayOpt != nil, "If dayOpt is nil, then the section value passed in is wrong")
        let day = dayOpt!
        return self.eventsForDay(day).count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(eventCellIdentifier, forIndexPath: indexPath) as EventCollectionViewCell
        cell.event = self.eventForIndexPath(indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
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
                let day = Day(rawValue: indexPath.indexAtPosition(0))!
                let dayColumnHeaderView = supplementaryView as DayColumnHeaderView
                dayColumnHeaderView.weekDayLabel.text = day.description
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
    
    // MARK: - Calendar Week View Layout Data Source
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate? {
        let event = self.eventForIndexPath(indexPath)
        return self.calendar.dateFromComponents(event.endTime)
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate? {
        let event = self.eventForIndexPath(indexPath)
        return self.calendar.dateFromComponents(event.startTime)
    }
    
    /// Return the width for a day
    func daySectionWidthForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->CollectionViewCalendarWeekLayoutDaySectionWidth {
        return CollectionViewCalendarWeekLayoutDaySectionWidth.VisibleNumberOfDays(5)
    }
    
    /// Return the height of the week view (scrollable height, not frame height)
    func heightForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->CollectionViewCalendarWeekLayoutHeight {
        return CollectionViewCalendarWeekLayoutHeight.Fit
    }
    
    /// Return the height of the day header
    func dayColumnHeaderHeightForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Float {
        return 50.0
    }
    
    /// Return the width of the time header
    func timeRowHeaderWidthForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Float {
        return 80.0
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

protocol ScheduleEvent {
    var title: String { get }
    var days: [Day] { get }
    var startTime: NSDateComponents { get }
    var endTime: NSDateComponents { get }
}