//
//  CollectionViewDataSourceCalendarWeekLayout.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

@objc public protocol CollectionViewDataSourceCalendarWeekLayout
{
    /// Return the start date in NSDate for the item at indexPath. nil if indexPath invalid
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate?
    
    /// Return the end date in NSDate for the item at indexPath. nil if indexPath invalid
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate?
    
    /// Return the date associated with the section. The time component is ignored.
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, dateForSection section: Int) -> NSDate?
    
    /// Return the number of visible days 
    optional func numberOfVisibleDaysForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)->Int
    
    
}
