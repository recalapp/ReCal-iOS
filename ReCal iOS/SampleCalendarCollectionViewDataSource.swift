//
//  SampleCalendarCollectionViewDataSource.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/16/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

let eventCellIdentifier = "Cell"
let dayHeaderViewIdentifier = "DayHeader"
let timeHeaderViewIdentifier = "TimeHeader"

struct TimeInterval {
    let start: NSDate
    let end: NSDate
}

class SampleCalendarCollectionViewDataSource: NSObject, UICollectionViewDataSource, CollectionViewDataSourceCalendarWeekLayout {
    let dummyData: [[TimeInterval]]
    override init() {
        let curDate = NSDate()
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let componentsFromDate:(NSDate)->NSDateComponents = {(date) in
            return calendar!.components((NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.SecondCalendarUnit), fromDate: date)
        }
        let dateFromComponents:(NSDateComponents)->NSDate = {(components) in calendar!.dateFromComponents(components)! }
        var components = componentsFromDate(curDate)
        components.hour = 8
        components.minute = 0
        components.second = 0
        var start = dateFromComponents(components)
        components.hour = 10
        var end = dateFromComponents(components)
        let event1 = TimeInterval(start: start, end: end)
        components.hour = 9
        start = dateFromComponents(components)
        components.hour = 12
        components.minute = 30
        end = dateFromComponents(components)
        let event2 = TimeInterval(start: start, end: end)
        components.hour = 13
        start = dateFromComponents(components)
        components.hour = 15
        components.minute = 0
        end = dateFromComponents(components)
        let event3 = TimeInterval(start: start, end: end)
        self.dummyData = [[event1, event2],[],[event3],[event1],[event2,event3],[],[event2],[event1, event2],[],[event3],[event1],[event2,event3],[],[event2],[event1, event2],[],[event3],[event1],[event2,event3],[],[event2],[event1, event2],[],[event3],[event1],[event2,event3],[],[event2],[event1, event2],[],[event3],[event1],[event2,event3],[],[event2],[event1, event2],[],[event3],[event1],[event2,event3],[],[event2],[event1, event2],[],[event3],[event1],[event2,event3],[],[event2]]
        self.dummyData += self.dummyData
        self.dummyData += self.dummyData
        self.dummyData += self.dummyData
    }
    // MARK: UICollectionViewDataSource
   
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.dummyData.count

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dummyData[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(eventCellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if let viewKind = CollectionViewCalendarWeekLayoutSupplementaryViewKind(rawValue: kind) {
            switch viewKind {
            case .DayColumnHeader:
                let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: dayHeaderViewIdentifier, forIndexPath: indexPath) as UICollectionReusableView
                return reusableView
            case .TimeRowHeader:
                let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: timeHeaderViewIdentifier, forIndexPath: indexPath) as UICollectionReusableView
                return reusableView
            }
        }
        assert(false, "Supplementary view kind \(kind) not implemented")
    }
    
    // MARK: CollectionViewDataSourceCalendarWeekLayout
    /// Return the start date in NSDate for the item at indexPath. nil if indexPath invalid
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate? {
        return self.dummyData[indexPath.section][indexPath.item].start
    }
    
    /// Return the end date in NSDate for the item at indexPath. nil if indexPath invalid
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate? {
        return self.dummyData[indexPath.section][indexPath.item].end
    }
    
    /// Return the date associated with the section. The time component is ignored.
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, dateForSection section: Int) -> NSDate? {
        return NSDate()
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
    func timeRowHeaderWidthForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> Float {
        return 80.0
    }
    
    /// Return the minimum hour, from 0 to 23
    func minimumHourForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Int {
        return 8
    }
    
    /// Return the maximum hour, from 0 to 23. This is the last hour seen (so you will see the hour from max to max + 1)
    func maximumHourForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Int {
        return 22
    }
    
    /// Return how many hours (can be fractional) each vertical slot represent
    func hourStepForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Float {
        return 2
    }
}
