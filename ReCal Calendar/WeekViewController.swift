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

    private let eventCellIdentifier = "EventsCell"
    private let dayColumnHeaderViewIdentifier = "DayHeader"
    private let timeRowHeaderViewIdentifier = "TimeHeader"
    private let minimumHour = 6
    private let maximumHour = 23
    private let hourStep = 2
    
    lazy private var calendar: NSCalendar = {
        let calendarOpt = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        assert(calendarOpt != nil, "Calendar cannot be nil")
        return calendarOpt!
    }()
    
    lazy private var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h a"
        return formatter
    }()
    
    private var notificationObservers: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = self.collectionViewLayout as CollectionViewCalendarWeekLayout
        layout.dataSource = self
        self.collectionView.registerNib(UINib(nibName: "EventCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: eventCellIdentifier)
        self.collectionView.registerNib(UINib(nibName: "TimeRowHeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: CollectionViewCalendarWeekLayoutSupplementaryViewKind.TimeRowHeader.rawValue, withReuseIdentifier: timeRowHeaderViewIdentifier)
        self.collectionView.registerNib(UINib(nibName: "DayColumnHeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: CollectionViewCalendarWeekLayoutSupplementaryViewKind.DayColumnHeader.rawValue, withReuseIdentifier: dayColumnHeaderViewIdentifier)
        layout.registerClass(TimeRowHeaderBackgroundView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.TimeRowHeaderBackground.rawValue)
        layout.registerClass(DayColumnHeaderBackgroundView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.DayColumnHeaderBackground.rawValue)
        layout.registerClass(GridLineView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.HorizontalGridLine.rawValue)
        layout.registerClass(GridLineView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.VerticalGridLine.rawValue)
        let updateColorScheme: Void -> Void = {
            self.collectionView.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 100
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(eventCellIdentifier, forIndexPath: indexPath) as EventCollectionViewCell
//        let event = self.eventForIndexPath(indexPath)
//        cell.event = event
//        if let color = self.courseColorMap[event.course] {
//            cell.color = color
//        }
//        if event.enrolled {
//            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
//            cell.selected = true
//        }
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
//                let day = Day(rawValue: indexPath.indexAtPosition(0))!
                let dayColumnHeaderView = supplementaryView as DayColumnHeaderView
                dayColumnHeaderView.weekDayLabel.text = "Day"
                dayColumnHeaderView.dateLabel.text = "Date"
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

    // MARK: UICollectionViewDelegate

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
        return nil
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate? {
        return nil
    }

    /// Return the width for a day
    func daySectionWidthForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->CollectionViewCalendarWeekLayoutDaySectionWidth {
        return CollectionViewCalendarWeekLayoutDaySectionWidth.VisibleNumberOfDays(6)
    }
    
    /// Return the height of the week view (scrollable height, not frame height)
    func heightForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->CollectionViewCalendarWeekLayoutHeight {
        let height: Float = Float(collectionView.bounds.height) * 1.5
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
