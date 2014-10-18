//
//  CollectionViewCalendarWeekLayout.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

let debug = false

let gridLineWidth: CGFloat = 1.0
let gridLineZIndex = 1
let timeRowHeaderBackgroundZIndex = gridLineZIndex + 1
let timeRowHeaderZIndex = timeRowHeaderBackgroundZIndex + 1
let dayColumnHeaderBackgroundZIndex = timeRowHeaderZIndex + 1
let dayColumnHeaderZIndex = dayColumnHeaderBackgroundZIndex + 1


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
                finalWidth = floor(Float(self.collectionView!.frame.size.width - self.timeRowHeaderWidth) / Float(days))
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
    private var dayColumnHeaderHeight: CGFloat {
        var finalHeight: Float = 300.0 // TODO default value?
        if let height = self.dataSource?.dayColumnHeaderHeightForCollectionView(self.collectionView!, layout: self) {
            finalHeight = height
        }
        return CGFloat(finalHeight)
    }
    private var timeRowHeaderWidth: CGFloat {
        var finalWidth: CGFloat = 300.0
        if let width = self.dataSource?.timeRowHeaderWidthForCollectionView(self.collectionView!, layout: self) {
            finalWidth = CGFloat(width)
        }
        return finalWidth
    }
    private var hourSlotHeight: CGFloat {
        return floor((self.layoutHeight - self.dayColumnHeaderHeight) / 24.0)
    }
    private var visibleDaySections: [Int] {
        let leftMargin = self.timeRowHeaderWidth
        let contentOffset = self.collectionView!.contentOffset
        let bounds = self.collectionView!.bounds
        let sectionWidth = self.daySectionWidth
        let minSection = Int((contentOffset.x - leftMargin)/sectionWidth) // ok to cast down, we just want a section that's to the left of the left most visible section
        let sectionDelta = Int(ceil(bounds.width / sectionWidth))
        let maxSection = minSection + sectionDelta
        return (minSection...maxSection).map{ $0 }
    }
    
    /// MARK: Caches
    private var eventsLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
    private var dayColumnHeaderBackgroundLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
    private var dayColumnHeaderLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
    private var timeRowHeaderBackgroundLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
    private var timeRowHeaderLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
    private var verticalGridLineLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
    private var horizontalGridLineLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
    private var shouldRecalculateEventsLayoutAttributes: Bool {
        return self.eventsLayoutAttributesCache.isEmpty
    }
    private var shouldRecalculateDayColumnHeaderBackgroundLayoutAttributes: Bool {
        return self.dayColumnHeaderBackgroundLayoutAttributesCache.isEmpty
    }
    private var shouldRecalculateDayColumnHeaderLayoutAttributes: Bool {
        return self.dayColumnHeaderLayoutAttributesCache.isEmpty
    }
    private var shouldRecalculateTimeRowHeaderBackgroundLayoutAttributes: Bool {
        return self.timeRowHeaderBackgroundLayoutAttributesCache.isEmpty
    }
    private var shouldRecalculateTimeRowHeaderLayoutAttributes: Bool {
        return self.timeRowHeaderLayoutAttributesCache.isEmpty
    }
    private var shouldRecalculateVerticalGridLineLayoutAttributes: Bool {
        return self.verticalGridLineLayoutAttributesCache.isEmpty
    }
    private var shouldRecalculateHorizontalGridLineLayoutAttributes: Bool {
        return self.horizontalGridLineLayoutAttributesCache.isEmpty
    }
    
    /// MARK: Methods
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.eventsLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
            return UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        }
        
        self.dayColumnHeaderBackgroundLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
            return UICollectionViewLayoutAttributes(forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.DayColumnHeaderBackground.toRaw(), withIndexPath: indexPath)
        }
        
        self.dayColumnHeaderLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
            return UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CollectionViewCalendarWeekLayoutSupplementaryViewKind.DayColumnHeader.toRaw(), withIndexPath: indexPath)
        }
        self.timeRowHeaderBackgroundLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
            return UICollectionViewLayoutAttributes(forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.TimeRowHeaderBackground.toRaw(), withIndexPath: indexPath)
        }
        self.timeRowHeaderLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
            return UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CollectionViewCalendarWeekLayoutSupplementaryViewKind.TimeRowHeader.toRaw(), withIndexPath: indexPath)
        }
        self.verticalGridLineLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
            return UICollectionViewLayoutAttributes(forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.VerticalGridLine.toRaw(), withIndexPath: indexPath)
        }
        self.horizontalGridLineLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
            return UICollectionViewLayoutAttributes(forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.HorizontalGridLine.toRaw(), withIndexPath: indexPath)
        }
        
        if debug {
            self.eventsLayoutAttributesCache.willClear = {(_) in println("invalidating events cache") }
            self.dayColumnHeaderBackgroundLayoutAttributesCache.willClear = {(_) in println("invalidating day header background")}
            self.dayColumnHeaderLayoutAttributesCache.willClear = {(_) in println("invalidating day column header") }
            self.timeRowHeaderBackgroundLayoutAttributesCache.willClear = {(_) in println("invalidating time row header background") }
            self.timeRowHeaderLayoutAttributesCache.willClear = {(_) in println("invalidating time row header") }
            self.verticalGridLineLayoutAttributesCache.willClear = {(_) in println("invalidating vertical grid lines") }
            self.horizontalGridLineLayoutAttributesCache.willClear = {(_) in println("invalidating horizontal grid line")}
        }
    }
    
    override public func prepareLayout() {
        if self.dataSource == nil {
            return // cannot do anything without datasource
        }
        self.calculateLayoutAttributes()
    }
    
    /// MARK: Layout Attributes Calculation
    private func minXForSection(section: Int)->CGFloat {
        return CGFloat(section) * self.daySectionWidth + self.timeRowHeaderWidth
    }
    private func calculateEventsLayoutAttributesForSection(section: Int) {
    }
    private func calculateLayoutAttributes()
    {
        let numberOfSections = self.collectionView?.numberOfSections()
        if numberOfSections == nil {
            return; // cannot do anything
        }
        let totalSections = (1...numberOfSections!).map {$0 - 1}
        let visibleSections = self.visibleDaySections
        if self.shouldRecalculateDayColumnHeaderBackgroundLayoutAttributes {
            self.calculateDayColumnHeaderBackgroundLayoutAttributes()
        }
        if self.shouldRecalculateDayColumnHeaderLayoutAttributes {
            for section in totalSections {
                self.calculateDayColumnHeaderLayoutAttributesForSection(section)
            }
        } else {
            for section in visibleSections {
                self.calculateDayColumnHeaderLayoutAttributesForSection(section)
            }
        }
        if self.shouldRecalculateTimeRowHeaderBackgroundLayoutAttributes {
            self.calculateTimeRowHeaderBackgroundLayoutAttributes()
        }
        if self.shouldRecalculateTimeRowHeaderLayoutAttributes {
            self.calculateTimeRowHeaderLayoutAttributes()
        }
        if self.shouldRecalculateVerticalGridLineLayoutAttributes {
            for section in totalSections {
                self.calculateVerticalGridLineForSection(section)
            }
        } else {
            for section in visibleSections {
                self.calculateVerticalGridLineForSection(section)
            }
        }
        if self.shouldRecalculateHorizontalGridLineLayoutAttributes {
            self.calculateHorizontalGridLineLayoutAttributes()
        }
        if self.shouldRecalculateEventsLayoutAttributes {
            for section in totalSections {
                self.calculateEventsLayoutAttributesForSection(section)
            }
        }
        else {
            for section in visibleSections {
                self.calculateEventsLayoutAttributesForSection(section)
            }
        }
    }
    
    private func calculateDayColumnHeaderBackgroundLayoutAttributes() {
        var backgroundLayoutAttributes = self.dayColumnHeaderBackgroundLayoutAttributesCache[NSIndexPath(forItem: 0, inSection: 0)]
        
        backgroundLayoutAttributes.frame = CGRectMake(self.collectionView!.contentOffset.x, self.collectionView!.contentOffset.y, self.collectionView!.frame.size.width, self.dayColumnHeaderHeight)
        backgroundLayoutAttributes.zIndex = dayColumnHeaderBackgroundZIndex
    }
    private func calculateDayColumnHeaderLayoutAttributesForSection(section: Int) {
        let sectionMinX = self.minXForSection(section)
        let headerLayoutAttributes = self.dayColumnHeaderLayoutAttributesCache[NSIndexPath(index: section)]
        headerLayoutAttributes.frame = CGRectMake(sectionMinX, self.collectionView!.contentOffset.y, self.daySectionWidth, self.dayColumnHeaderHeight)
        headerLayoutAttributes.zIndex = dayColumnHeaderZIndex
    }
    
    private func calculateTimeRowHeaderBackgroundLayoutAttributes() {
        let timeBackgroundLayoutAttributes = self.timeRowHeaderBackgroundLayoutAttributesCache[NSIndexPath(forItem: 0, inSection: 0)]
        
        timeBackgroundLayoutAttributes.frame = CGRectMake(self.collectionView!.contentOffset.x, self.collectionView!.contentOffset.y, self.timeRowHeaderWidth, self.collectionView!.frame.size.height)
        timeBackgroundLayoutAttributes.zIndex = timeRowHeaderBackgroundZIndex
    }
    private func calculateTimeRowHeaderLayoutAttributes() {
        let minHour = 0
        let maxHour = 23
        let topMargin = self.dayColumnHeaderHeight
        let hourSlotHeight = self.hourSlotHeight
        let timeHeaderWidth = self.timeRowHeaderWidth
        let contentOffset = self.collectionView!.contentOffset
        for hour in minHour...maxHour {
            // this loops from minHour to maxHour, inclusive
            let timeLayoutAttributes = self.timeRowHeaderLayoutAttributesCache[NSIndexPath(index: hour)]
            timeLayoutAttributes.frame = CGRectMake(contentOffset.x, CGFloat(hour - minHour) * hourSlotHeight + topMargin, timeHeaderWidth, hourSlotHeight)
            timeLayoutAttributes.zIndex = timeRowHeaderZIndex
        }
    }
    
    private func calculateVerticalGridLineForSection(section: Int) {
        let sectionMinX = self.minXForSection(section)
        let verticalGridLineLayoutAttributes = self.verticalGridLineLayoutAttributesCache[NSIndexPath(index: section)]
        verticalGridLineLayoutAttributes.frame = CGRectMake(sectionMinX, self.collectionView!.contentOffset.y, gridLineWidth, self.collectionView!.bounds.size.height)
        verticalGridLineLayoutAttributes.zIndex = gridLineZIndex
    }
    private func calculateHorizontalGridLineLayoutAttributes() {
        let minHour = 0
        let maxHour = 23
        let topMargin = self.dayColumnHeaderHeight
        let hourSlotHeight = self.hourSlotHeight
        let timeHeaderWidth = self.timeRowHeaderWidth
        let contentOffset = self.collectionView!.contentOffset
        let bounds = self.collectionView!.bounds
        for hour in minHour...maxHour {
            // this loops from minHour to maxHour, inclusive
            let timeLayoutAttributes = self.horizontalGridLineLayoutAttributesCache[NSIndexPath(index: hour)]
            timeLayoutAttributes.frame = CGRectMake(contentOffset.x, CGFloat(hour - minHour) * hourSlotHeight + topMargin, bounds.size.width, gridLineWidth)
            timeLayoutAttributes.zIndex = gridLineZIndex
        }
    }
    
    /// MARK: Invalidation
    override public func invalidateLayout() {
        super.invalidateLayout()
    }
    override public func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        if debug {
            println("begin invalidation")
        }
        // TODO invalidate efficiently
        let invalidateRowHeaders: ()->Void = {
            self.timeRowHeaderBackgroundLayoutAttributesCache.clearCache()
            self.timeRowHeaderLayoutAttributesCache.clearCache()
        }
        let invalidateColumnHeaders: ()->Void = {
            self.dayColumnHeaderBackgroundLayoutAttributesCache.clearCache()
            self.dayColumnHeaderLayoutAttributesCache.clearCache()
        }
        let invalidateGridLines: ()->Void = {
            self.verticalGridLineLayoutAttributesCache.clearCache()
            self.horizontalGridLineLayoutAttributesCache.clearCache()
        }
        let invalidateAll: ()->Void = {
            invalidateColumnHeaders()
            invalidateRowHeaders()
            invalidateGridLines()
            self.eventsLayoutAttributesCache.clearCache()
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
            //invalidateColumnHeaders()
            self.dayColumnHeaderBackgroundLayoutAttributesCache.clearCache()
            self.timeRowHeaderBackgroundLayoutAttributesCache.clearCache()
            //self.verticalGridLineLayoutAttributesCache.clearCache()
            context.contentOffsetAdjustment.y = 0 // set back to zero, otherwise super does something with scrolling
        }
        if context.contentOffsetAdjustment.x != 0 {
            // scrolling in x direction
            invalidateRowHeaders()
            self.horizontalGridLineLayoutAttributesCache.clearCache()
            self.dayColumnHeaderBackgroundLayoutAttributesCache.clearCache()
            context.contentOffsetAdjustment.x = 0
        }
        // TODO specific items
        if debug {
            println("end invalidation")
            println("----------------------")
        }
        super.invalidateLayoutWithContext(context)
        
    }
    
    override public func invalidationContextForBoundsChange(newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        var context = super.invalidationContextForBoundsChange(newBounds)
        context.contentOffsetAdjustment = CGPointMake(newBounds.origin.x, newBounds.origin.y)
        context.contentSizeAdjustment = CGSizeMake(newBounds.size.width - self.collectionView!.bounds.size.width, newBounds.size.height - self.collectionView!.bounds.size.height)
        return context
    }
    
    /// MARK: UICollectionViewLayout Methods
    override public func collectionViewContentSize() -> CGSize {
        let numberOfSections: Int = self.collectionView!.numberOfSections()
        let finalWidth = self.daySectionWidth * CGFloat(numberOfSections) + self.timeRowHeaderWidth
        return CGSizeMake(finalWidth, self.layoutHeight)
    }
    
    override public func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        if let kind = CollectionViewCalendarWeekLayoutDecorationViewKind.fromRaw(elementKind) {
            switch kind {
            case .DayColumnHeaderBackground:
                return self.dayColumnHeaderBackgroundLayoutAttributesCache[indexPath]
            case .VerticalGridLine:
                return self.verticalGridLineLayoutAttributesCache[indexPath]
            case .TimeRowHeaderBackground:
                return self.timeRowHeaderBackgroundLayoutAttributesCache[indexPath]
            case .HorizontalGridLine:
                return self.horizontalGridLineLayoutAttributesCache[indexPath]
            }
        }
        assert(false, "Invalid Decoration View Kind \(elementKind)")
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return self.eventsLayoutAttributesCache[indexPath]
    }
    
    override public func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        if let kind = CollectionViewCalendarWeekLayoutSupplementaryViewKind.fromRaw(elementKind) {
            switch kind {
            case .DayColumnHeader:
                return self.dayColumnHeaderLayoutAttributesCache[indexPath]
            case .TimeRowHeader:
                return self.timeRowHeaderLayoutAttributesCache[indexPath]
            }
        }
        assert(false, "Invalid Supplementary View Kind \(elementKind)")
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var visibleAttributes: [UICollectionViewLayoutAttributes] = []
        let visibleFilter:(NSIndexPath, UICollectionViewLayoutAttributes)->Bool = {(_, layoutAttributes) in
            return CGRectIntersectsRect(rect, layoutAttributes.frame)
        }
        visibleAttributes += self.eventsLayoutAttributesCache.filter(visibleFilter)
        visibleAttributes += self.dayColumnHeaderBackgroundLayoutAttributesCache.filter(visibleFilter)
        visibleAttributes += self.dayColumnHeaderLayoutAttributesCache.filter(visibleFilter)
        visibleAttributes += self.verticalGridLineLayoutAttributesCache.filter(visibleFilter)
        visibleAttributes += self.timeRowHeaderBackgroundLayoutAttributesCache.filter(visibleFilter)
        visibleAttributes += self.timeRowHeaderLayoutAttributesCache.filter(visibleFilter)
        visibleAttributes += self.horizontalGridLineLayoutAttributesCache.filter(visibleFilter)
        return visibleAttributes
    }
    
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
public enum CollectionViewCalendarWeekLayoutSupplementaryViewKind: String {
    case DayColumnHeader = "DayColumnHeader"
    case TimeRowHeader = "TimeRowHeader"
}
public enum CollectionViewCalendarWeekLayoutDecorationViewKind: String {
    case DayColumnHeaderBackground = "DayColumnHeaderBackground"
    case TimeRowHeaderBackground = "TimeRowHeaderBackground"
    case VerticalGridLine = "VerticalGridLine"
    case HorizontalGridLine = "HorizontalGridLine"
}