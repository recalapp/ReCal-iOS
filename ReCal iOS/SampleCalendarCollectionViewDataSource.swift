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

class SampleCalendarCollectionViewDataSource: NSObject, UICollectionViewDataSource, CollectionViewDataSourceCalendarWeekLayout {
    
    override init() {
        
    }
    // MARK: UICollectionViewDataSource
   
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        assert(false)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        /*let supplementaryViewKind = kind as CollectionViewCalendarWeekLayoutSupplementaryViewKind
        if let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseIdentifier, forIndexPath: indexPath) as? UICollectionReusableView {
            return reusableView
        }*/
        assert(false, "collection view should return a reusable view")
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, dateForSection section: Int) -> NSDate? {
        return nil
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate? {
        return nil
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startDateForItemAtIndexPath indexPath: NSIndexPath) -> NSDate? {
        return nil
    }
}
