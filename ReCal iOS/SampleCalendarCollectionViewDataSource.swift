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

class SampleCalendarCollectionViewDataSource: NSObject, UICollectionViewDataSource, CollectionViewDataSourceCalendarWeekLayout {
    
    override init() {
        
    }
    // MARK: UICollectionViewDataSource
   
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 100

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        assert(false)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if let viewKind = CollectionViewCalendarWeekLayoutSupplementaryViewKind.fromRaw(kind) {
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
        return NSDate()
    }
    
    /// Return the end date in NSDate for the item at indexPath. nil if indexPath invalid
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate? {
        return NSDate()
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
        return CollectionViewCalendarWeekLayoutHeight.Exact(1000.0)
    }
    
    /// Return the height of the day header
    func dayColumnHeaderHeightForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Float {
        return 100.0
    }
    /// Return the width of the time header
    func timeRowHeaderWidthForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> Float {
        return 80.0
    }
}
