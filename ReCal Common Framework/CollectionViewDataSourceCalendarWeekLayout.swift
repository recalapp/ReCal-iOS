//
//  CollectionViewDataSourceCalendarWeekLayout.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public protocol CollectionViewDataSourceCalendarWeekLayout
{
    /// Return the start date in NSDate for the item at indexPath. nil if indexPath invalid
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate?
    
    /// Return the end date in NSDate for the item at indexPath. nil if indexPath invalid
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate?
    
    /// Return the date associated with the section. The time component is ignored.
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, dateForSection section: Int) -> NSDate?
    
    /// Return the width for a day
    func daySectionWidthForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->CollectionViewCalendarWeekLayoutDaySectionWidth
    
    /// Return the height of the week view (scrollable height, not frame height)
    func heightForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->CollectionViewCalendarWeekLayoutHeight
    
    /// Return the height of the day header
    func dayColumnHeaderHeightForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Float
    
    /// Return the width of the time header
    func timeRowHeaderWidthForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Float

}

public enum CollectionViewCalendarWeekLayoutDaySectionWidth {
    case Exact(Float)
    case VisibleNumberOfDays(Int)
}

public enum CollectionViewCalendarWeekLayoutHeight {
    case Fit
    case Exact(Float)
}