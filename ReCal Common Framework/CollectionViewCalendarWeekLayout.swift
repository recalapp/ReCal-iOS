//
//  CollectionViewCalendarWeekLayout.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
/// A subclass of UICollectionViewLayout that provides a week view-like interface. Each section shuold correspond to a day, and each item an event. Does not support multi-day events right now.
class CollectionViewCalendarWeekLayout: UICollectionViewLayout {
    
    private let eventsLayoutAttributes = Cache<NSIndexPath, CalendarEventsWeekLayoutAttributes>()
    private var shouldRecalculateEventsLayoutAttributes: Bool {
        return self.eventsLayoutAttributes.isEmpty
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        weak var wSelf = self
        self.eventsLayoutAttributes.itemConstructor = {(indexPath: NSIndexPath) in
            return CalendarEventsWeekLayoutAttributes(forCellWithIndexPath: indexPath)
        }
    }
    
    var dataSource: CollectionViewDataSourceCalendarWeekLayout {
        if let dataSource = self.collectionView?.dataSource as? CollectionViewDataSourceCalendarWeekLayout {
            return dataSource;
        }
        assert(false, "Collection View DataSource must conform to CollectionViewDataSourceCalendarWeekLayout to be used with CollectionViewCalendarWeekLayout")
    }
    
    override func prepareLayout() {
        if self.shouldRecalculateEventsLayoutAttributes {
            if let collectionView = self.collectionView {
                if let numberOfSections = collectionView.dataSource?.numberOfSectionsInCollectionView?(collectionView) {
                    for var section = 0; section < numberOfSections; ++section {
                        self.calculateEventsLayoutForSection(section)
                    }
                }
            }
        }
    }
    
    private func calculateEventsLayoutForSection(section: Int){
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        self.eventsLayoutAttributes.clearCache()
    }
    override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        // TODO invalidate efficiently
        super.invalidateLayoutWithContext(context)
        self.eventsLayoutAttributes.clearCache()
    }
}