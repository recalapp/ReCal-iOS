//
//  CollectionViewCalendarWeekLayout.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

/// A subclass of UICollectionViewLayout that provides a week view-like interface. Each section shuold correspond to a day, and each item an event. Does not support multi-day events right now.
public class CollectionViewCalendarWeekLayout: UICollectionViewLayout {
    
    /// MARK: Properties
    public var dataSource: CollectionViewDataSourceCalendarWeekLayout?
    
    private var daySectionWidth: CGFloat {
        var finalWidth: Float = 300.0 // TODO default value?
        if let sectionWidth = self.dataSource?.daySectionWidthForCollectionView(self.collectionView!, layout: self) {
            switch sectionWidth {
            case .Exact(let width):
                finalWidth = width
            case .VisibleNumberOfDays(let days):
                finalWidth = floor(Float(self.collectionView!.frame.size.width) / Float(days))
            }
        }
        return CGFloat(finalWidth)
    }
    private var layoutHeight: CGFloat {
        var finalHeight: Float = 300.0 // TODO default value?
        if let layoutHeight = self.dataSource?.heightForCollectionView(self.collectionView!, layout: self) {
            switch layoutHeight {
            case .Exact(let height):
                finalHeight = height
            case .Fit:
                finalHeight = Float(self.collectionView!.frame.size.height)
            }
        }
        return CGFloat(finalHeight)
    }
    private var dayHeaderHeight: CGFloat {
        var finalHeight: Float = 300.0 // TODO default value?
        if let height = self.dataSource?.dayHeaderHeightForCollectionView(self.collectionView!, layout: self) {
            finalHeight = height
        }
        return CGFloat(finalHeight)
    }
    /// MARK: Caches
    private let eventsLayoutAttributes = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
    private let dayColumnHeaderBackgroundLayoutAttributes = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
    private let dayColumnHeaderLayoutAttributes = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
    private var shouldRecalculateEventsLayoutAttributes: Bool {
        return self.eventsLayoutAttributes.isEmpty
    }
    private var shouldRecalculateDayColumnHeaderBackgroundLayoutAttributes: Bool {
        return self.dayColumnHeaderBackgroundLayoutAttributes.isEmpty
    }
    private var shouldRecalculateDayColumnHeaderLayoutAttributes: Bool {
        return self.dayColumnHeaderLayoutAttributes.isEmpty
    }
    
    /// MARK: Methods
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.eventsLayoutAttributes.itemConstructor = {(indexPath: NSIndexPath) in
            return UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        }
        self.dayColumnHeaderBackgroundLayoutAttributes.itemConstructor = {(indexPath: NSIndexPath) in
            return UICollectionViewLayoutAttributes(forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.DayColumnHeaderBackground.toRaw(), withIndexPath: indexPath)
        }
        self.dayColumnHeaderLayoutAttributes.itemConstructor = {(indexPath: NSIndexPath) in
            return UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CollectionViewCalendarWeekLayoutSupplementaryViewKind.DayColumnHeader.toRaw(), withIndexPath: indexPath)
        }
        
    }
    
    override public func prepareLayout() {
        if self.dataSource == nil {
            return // cannot do anything without datasource
        }
        if self.shouldRecalculateEventsLayoutAttributes {
            if let collectionView = self.collectionView {
                if let numberOfSections = collectionView.dataSource?.numberOfSectionsInCollectionView?(collectionView) {
                    self.calculateLayoutAttributesForSections((0...numberOfSections).map { $0 })
                }
            }
        }
    }
    
    /// MARK: Layout Attributes Calculation
    private func calculateEventsLayoutAttributesForSection(section: Int) {
    }
    private func calculateLayoutAttributesForSections(sections: [Int])
    {
        if self.shouldRecalculateDayColumnHeaderBackgroundLayoutAttributes {
            self.calculateDayColumnHeaderBackgroundLayoutAttributes()
        }
        if self.shouldRecalculateDayColumnHeaderLayoutAttributes {
            for section in sections {
                self.calculateDayColumnHeaderLayoutAttributesForSection(section)
            }
        }
        if self.shouldRecalculateEventsLayoutAttributes {
            for section in sections {
                self.calculateEventsLayoutAttributesForSection(section)
            }
        }
    }
    
    private func calculateDayColumnHeaderBackgroundLayoutAttributes() {
        var backgroundLayoutAttributes = self.dayColumnHeaderBackgroundLayoutAttributes[NSIndexPath(forItem: 0, inSection: 0)]
        
        backgroundLayoutAttributes.frame = CGRectMake(self.collectionView!.contentOffset.x, self.collectionView!.contentOffset.y, self.collectionView!.frame.size.width, self.dayHeaderHeight)
    }
    private func calculateDayColumnHeaderLayoutAttributesForSection(section: Int) {
        let sectionMinX = self.daySectionWidth * CGFloat(section)
        var headerLayoutAttributes = self.dayColumnHeaderLayoutAttributes[NSIndexPath(index: section)]
        headerLayoutAttributes.frame = CGRectMake(sectionMinX, self.collectionView!.contentOffset.y, self.daySectionWidth, self.dayHeaderHeight)
        headerLayoutAttributes.zIndex = 100
    }
    
    /// MARK: Invalidation
    override public func invalidateLayout() {
        super.invalidateLayout()
        self.eventsLayoutAttributes.clearCache()
        self.dayColumnHeaderBackgroundLayoutAttributes.clearCache()
        self.dayColumnHeaderLayoutAttributes.clearCache()
    }
    override public func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        // TODO invalidate efficiently
        
        let invalidateHeaders: ()->Void = {
            self.dayColumnHeaderBackgroundLayoutAttributes.clearCache()
            self.dayColumnHeaderLayoutAttributes.clearCache()
        }
        let invalidateAll: ()->Void = {
            invalidateHeaders()
            self.eventsLayoutAttributes.clearCache()
        }
        if context.invalidateEverything {
            invalidateAll()
        }
        if context.invalidateDataSourceCounts {
            invalidateAll()
        }
        if context.contentSizeAdjustment != CGSizeZero {
            invalidateAll()
            context.contentSizeAdjustment = CGSizeZero
        }
        if context.contentOffsetAdjustment.y != 0 {
            // scrolling in y direction
            invalidateHeaders()
            context.contentOffsetAdjustment.y = 0 // set back to zero, otherwise super does something with scrolling
        }
        if context.contentOffsetAdjustment.x != 0 {
            // scrolling in x direction
            self.dayColumnHeaderBackgroundLayoutAttributes.clearCache()
            context.contentOffsetAdjustment.x = 0
        }
        // TODO specific items
        super.invalidateLayoutWithContext(context)
    }
    
    override public func invalidationContextForBoundsChange(newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        var context = super.invalidationContextForBoundsChange(newBounds)
        context.contentOffsetAdjustment = CGPointMake(newBounds.origin.x, newBounds.origin.y)
        return context
    }
    
    /// MARK: UICollectionViewLayout Methods
    override public func collectionViewContentSize() -> CGSize {
        let numberOfSections: Int = self.collectionView!.numberOfSections()
        let finalWidth = self.daySectionWidth * CGFloat(numberOfSections)
        return CGSizeMake(finalWidth, self.layoutHeight)
    }
    
    override public func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        if let kind = CollectionViewCalendarWeekLayoutDecorationViewKind.fromRaw(elementKind) {
            switch kind {
            case .DayColumnHeaderBackground:
                return self.dayColumnHeaderBackgroundLayoutAttributes[indexPath]
            }
        }
        assert(false, "Invalid Decoration View Kind \(elementKind)")
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return self.eventsLayoutAttributes[indexPath]
    }
    
    override public func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        if let kind = CollectionViewCalendarWeekLayoutSupplementaryViewKind.fromRaw(elementKind) {
            switch kind {
            case .DayColumnHeader:
                return self.dayColumnHeaderLayoutAttributes[indexPath]
            }
        }
        assert(false, "Invalid Supplementary View Kind \(elementKind)")
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var visibleAttributes: [UICollectionViewLayoutAttributes] = []
        let visibleFilter:(NSIndexPath, UICollectionViewLayoutAttributes)->Bool = {(_, layoutAttributes) in
            return CGRectIntersectsRect(rect, layoutAttributes.frame)
        }
        visibleAttributes += self.eventsLayoutAttributes.filter(visibleFilter)
        visibleAttributes += self.dayColumnHeaderBackgroundLayoutAttributes.filter(visibleFilter)
        visibleAttributes += self.dayColumnHeaderLayoutAttributes.filter(visibleFilter)
        return visibleAttributes
    }
    
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
public enum CollectionViewCalendarWeekLayoutSupplementaryViewKind: String {
    case DayColumnHeader = "DayColumnHeader"
}
public enum CollectionViewCalendarWeekLayoutDecorationViewKind: String {
    case DayColumnHeaderBackground = "DayColumnHeaderBackground"
}