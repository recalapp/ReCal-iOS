//
//  SummaryDayCollectionViewLayout.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

private let gridLineWidth: CGFloat = 0.5
private let gridLineZIndex = 1
private let eventsZIndex = gridLineZIndex + 1
private let timeRowHeaderBackgroundZIndex = eventsZIndex + 1
private let timeRowHeaderZIndex = timeRowHeaderBackgroundZIndex + 1
private let summarizedViewZIndex = timeRowHeaderZIndex + 1

public extension SummaryDayView {
    internal class SummaryDayCollectionViewSummarizedLayout: UICollectionViewLayout {
        /// MARK: Properties
        unowned let dataSource: SummaryDayCollectionViewDataSourceSummarizedLayout
        
        init(dataSource: SummaryDayCollectionViewDataSourceSummarizedLayout) {
            self.dataSource = dataSource
            super.init()
            self.initialize()
        }

        required init(coder aDecoder: NSCoder) {
            assertionFailure("not used")
            self.dataSource = NSObject() as! SummaryDayCollectionViewDataSourceSummarizedLayout // NOTE this will fail
            super.init(coder: aDecoder)
        }
        
        private let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        /// The padding for each event cell
        private let eventCellPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        
        /// The width of a day
        private var daySectionWidth: CGFloat {
            return (self.collectionView?.bounds.width ?? 0.0) - self.timeRowHeaderWidth // ok, will not be negative. if collectionview does not exist, time row header width also returns 0
        }
        
        /// The scrollable height
        private var layoutHeight: CGFloat {
            if let collectionView = self.collectionView {
                switch self.dataSource.heightForCollectionView(collectionView, layout: self) {
                case .Fill(oneHourHeight: let oneHourHeight):
                    let summarizedSteps = self.summarizedHourSteps
                    let summarizedHours = CGFloat(self.summarizedHourSteps.count) * CGFloat(self.hourStep) // how many steps are summarized * hours per step
                    var summarizedHeight: CGFloat
                    switch self.dataSource.summarizationFactorForCollectionView(collectionView, layout: self) {
                    case .Constant(let height):
                        summarizedHeight = CGFloat(self.summarizedHourIntervals.count) * height
                    case .Scale(let scale):
                        summarizedHeight = summarizedHours * oneHourHeight * CGFloat(scale)
                    }
                    return summarizedHeight + (CGFloat(self.totalHours) - summarizedHours) * oneHourHeight
                }
            }
            return 0
        }
        
        /// The height of one hour
        private var hourSlotHeight: CGFloat {
            if let collectionView = self.collectionView {
                switch self.dataSource.heightForCollectionView(collectionView, layout: self) {
                case .Fill(oneHourHeight: let height):
                    return height
                }
            }
            return 0
        }
        
        /// The width of the time row header
        private var timeRowHeaderWidth: CGFloat {
            if let collectionView = self.collectionView {
                let height = self.dataSource.timeRowHeaderWidthForCollectionView(collectionView, layout: self)
                return CGFloat(height)
            }
            return 0
        }
        
        /// The first hour in the collection view
        private var minimumHour: Int {
            if let collectionView = self.collectionView {
                let minimumHour = self.dataSource.minimumHourForCollectionView(collectionView, layout: self)
                assert(minimumHour >= 0 && minimumHour <= 23, "The minimum hour must be between 0 and 23, inclusive")
                return minimumHour
            }
            return 0
        }
        
        /// The first hour not seen in the collection view
        private var maximumHour: Int {
            if let collectionView = self.collectionView {
                let maximumHour = self.dataSource.maximumHourForCollectionView(collectionView, layout: self)
                assert(maximumHour >= 1 && maximumHour <= 24, "The minimum hour must be between 0 and 23, inclusive")
                return maximumHour
            }
            return 24
        }
        
        /// Total number of visible hours
        private var totalHours: Int {
            return self.maximumHour - self.minimumHour
        }
        
        /// The (fractional) number of hours each step represents
        private var hourStep: Double {
            if let collectionView = self.collectionView {
                let hourStep = self.dataSource.hourStepForCollectionView(collectionView, layout: self)
                assert(hourStep > 0.0, "The hour step must be positive")
                return hourStep
            }
            return 0
        }
        
        /// The total number of steps, rounded up
        private var hourStepCount: Int {
            return Int(ceil(Double(self.maximumHour - self.minimumHour)/self.hourStep))
        }
        
        /// All the index paths in this collection view
        private var allIndexPaths: [NSIndexPath] {
            if let collectionView = self.collectionView {
                var ret: [NSIndexPath] = []
                for section in 0..<collectionView.numberOfSections() {
                    for item in 0..<collectionView.numberOfItemsInSection(section) {
                        ret.append(NSIndexPath(forItem: item, inSection: section))
                    }
                }
                return ret
            }
            return []
        }
        
        /// The steps that have been summarized. hour: min + i * step is summarized
        private var summarizedHourStepsStorage: Set<Int>?
        private var summarizedHourSteps: Set<Int> {
            if summarizedHourStepsStorage == nil {
                self.calculateSummarizedHours()
            }
            return summarizedHourStepsStorage!
        }
        
        /// The intervals that have been summarized
        private var summarizedHourIntervalsStorage: [Interval<Double>]?
        private var summarizedHourIntervals: [Interval<Double>] {
            if summarizedHourIntervalsStorage == nil {
                self.calculateSummarizedHours()
            }
            return summarizedHourIntervalsStorage!
        }
        
        /// calculate the values related to summarization
        private func calculateSummarizedHours() {
            if let collectionView = self.collectionView {
                let minHour = Double(self.minimumHour)
                let maxHour = Double(self.maximumHour)
                let hourStep = self.hourStep
                let eventTimes = self.allIndexPaths.map { self.dataSource.collectionView(collectionView, layout: self, eventTimeForItemAtIndexPath: $0) }
                var hourSteps = Set<Int>()
                var hourIntervals = [Interval<Double>]()
                var i = 0
                for var hour = minHour; hour < maxHour; hour += hourStep {
                    let interval = Interval(start: hour, end: hour + hourStep)
                    let intersected = eventTimes.reduce(false) { $0 || $1.interval.intersects(interval, inclusive: false) }
                    if !intersected {
                        hourSteps.insert(i)
                        hourIntervals.append(interval)
                    }
                    i++
                }
                self.summarizedHourIntervalsStorage = hourIntervals.reduce([], combine: {(var combined: [Interval<Double>], interval) in
                    if let prev = combined.last {
                        if let newInterval = prev +? interval {
                            combined.removeLast()
                            combined.append(newInterval)
                        } else {
                            combined.append(interval)
                        }
                    } else {
                        combined.append(interval)
                    }
                    return combined
                })
                self.summarizedHourStepsStorage = hourSteps
            } else {
                self.summarizedHourIntervalsStorage = []
                self.summarizedHourStepsStorage = Set()
            }
        }
        /// MARK: Caches
        private var eventsLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
        private var timeRowHeaderBackgroundLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
        private var timeRowHeaderLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
        private var verticalGridLineLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
        private var horizontalGridLineLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
        private var summarizedViewLayoutAttributesCache = Cache<NSIndexPath, UICollectionViewLayoutAttributes>()
        private var shouldRecalculateEventsLayoutAttributes: Bool {
            return self.eventsLayoutAttributesCache.isEmpty
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
        private var shouldRecalculateSummarizedViewLayoutAttributes: Bool {
            return self.summarizedViewLayoutAttributesCache.isEmpty
        }
        
        /// MARK: Methods
        private func initialize() {
            self.eventsLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
                return UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            }
            self.timeRowHeaderBackgroundLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
                return UICollectionViewLayoutAttributes(forDecorationViewOfKind: DecorationViewKind.TimeRowHeaderBackground.rawValue, withIndexPath: indexPath)
            }
            self.timeRowHeaderLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
                return UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SupplementaryViewKind.TimeRowHeader.rawValue, withIndexPath: indexPath)
            }
            self.verticalGridLineLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
                return UICollectionViewLayoutAttributes(forDecorationViewOfKind: DecorationViewKind.VerticalGridLine.rawValue, withIndexPath: indexPath)
            }
            self.horizontalGridLineLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
                return UICollectionViewLayoutAttributes(forDecorationViewOfKind: DecorationViewKind.HorizontalGridLine.rawValue, withIndexPath: indexPath)
            }
            self.summarizedViewLayoutAttributesCache.itemConstructor = {(indexPath: NSIndexPath) in
                return UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SupplementaryViewKind.SummarizedView.rawValue, withIndexPath: indexPath)
            }
        }
        
        private func minYOffsetForHourStep(step: Int) -> CGFloat {
            if let collectionView = self.collectionView {
                let topMargin: CGFloat = 0
                var runningHeight = topMargin
                let hourStep = CGFloat(self.hourStep)
                let hourSlotHeight = self.hourSlotHeight
                for i in 0..<step {
                    if self.summarizedHourSteps.contains(i) {
                        switch self.dataSource.summarizationFactorForCollectionView(collectionView, layout: self) {
                        case .Constant(let constant):
                            if i == 0 || !self.summarizedHourSteps.contains(i - 1) {
                                runningHeight += constant
                            }
                        case .Scale(let scale):
                            runningHeight += hourStep * hourSlotHeight * CGFloat(scale)
                        }
                    } else {
                        runningHeight += hourStep * hourSlotHeight
                    }
                }
                return runningHeight
            } else {
                return 0
            }
        }
        
        private func offsetYForFractionalHour(hour: Double)->CGFloat {
            if let collectionView = self.collectionView {
                let deltaHour: Double = hour - Double(self.minimumHour)
                let precedingSummarizedIntervals = self.summarizedHourIntervals.filter { (interval: Interval<Double>) in
                    assert(!interval.contains(hour, inclusive: false))
                    return interval.end <= hour
                }
                let totalSummarizedHours = precedingSummarizedIntervals.reduce(0.0) { $0 + $1.end - $1.start }
                assert(totalSummarizedHours <= deltaHour)
                var summarizedHeight: CGFloat
                switch self.dataSource.summarizationFactorForCollectionView(collectionView, layout: self) {
                case .Constant(let constant):
                    summarizedHeight = CGFloat(constant) * CGFloat(precedingSummarizedIntervals.count)
                case .Scale(let scale):
                    summarizedHeight = CGFloat(scale) * CGFloat(totalSummarizedHours) * self.hourSlotHeight
                }
                return summarizedHeight + CGFloat(deltaHour - totalSummarizedHours) * self.hourSlotHeight
            } else {
                return 0
            }
        }
        
        private func minXForSection(section: Int)->CGFloat {
            return CGFloat(section) * self.daySectionWidth + self.timeRowHeaderWidth
        }
        
        override func prepareLayout() {
            if let collectionView = self.collectionView {
                self.calculateSummarizedHours()
                if self.shouldRecalculateTimeRowHeaderBackgroundLayoutAttributes {
                    self.calculateTimeRowHeaderBackgroundLayoutAttributes()
                }
                if self.shouldRecalculateTimeRowHeaderLayoutAttributes {
                    self.calculateTimeRowHeaderLayoutAttributes()
                }
                if self.shouldRecalculateVerticalGridLineLayoutAttributes {
                    // there are only two vertical grid lines
                    for section in 0...1 {
                        self.calculateVerticalGridLineForSection(section)
                    }
                }
                if self.shouldRecalculateHorizontalGridLineLayoutAttributes {
                    self.calculateHorizontalGridLineLayoutAttributes()
                }
                if self.shouldRecalculateEventsLayoutAttributes {
                    self.calculateEventsLayoutAttributes()
                }
                if self.shouldRecalculateSummarizedViewLayoutAttributes {
                    self.calculateSummarizedViewLayoutAttributes()
                }
            }
        }
        
        private func calculateTimeRowHeaderBackgroundLayoutAttributes() {
            if let collectionView = self.collectionView {
                let timeBackgroundLayoutAttributes = self.timeRowHeaderBackgroundLayoutAttributesCache[NSIndexPath(forItem: 0, inSection: 0)]
                
                timeBackgroundLayoutAttributes.frame = CGRectMake(collectionView.contentOffset.x, collectionView.contentOffset.y, self.timeRowHeaderWidth, collectionView.frame.size.height)
                timeBackgroundLayoutAttributes.zIndex = timeRowHeaderBackgroundZIndex
            }
        }
        
        private func calculateTimeRowHeaderLayoutAttributes() {
            if let collectionView = self.collectionView {
                let timeHeaderWidth = self.timeRowHeaderWidth
                let contentOffset = collectionView.contentOffset
                for i in 0..<self.hourStepCount {
                    if !self.summarizedHourSteps.contains(i) {
                        let minY = self.minYOffsetForHourStep(i)
                        // this loops from minHour to maxHour, inclusive
                        let timeLayoutAttributes = self.timeRowHeaderLayoutAttributesCache[NSIndexPath(index: i)]
                        timeLayoutAttributes.frame = CGRectMake(contentOffset.x, minY, timeHeaderWidth, 50.0)
                        timeLayoutAttributes.zIndex = timeRowHeaderZIndex
                    }
                }
            }
        }
        
        private func calculateVerticalGridLineForSection(section: Int) {
            if let collectionView = self.collectionView {
                let sectionMinX = self.minXForSection(section)
                let verticalGridLineLayoutAttributes = self.verticalGridLineLayoutAttributesCache[NSIndexPath(index: section)]
                verticalGridLineLayoutAttributes.frame = CGRectMake(sectionMinX, collectionView.contentOffset.y, gridLineWidth, collectionView.bounds.size.height)
                verticalGridLineLayoutAttributes.zIndex = gridLineZIndex
            }
        }
        private func calculateHorizontalGridLineLayoutAttributes() {
            if let collectionView = self.collectionView {
                let timeHeaderWidth = self.timeRowHeaderWidth
                let bounds = collectionView.bounds
                let contentOffset = collectionView.contentOffset
                for i in 0..<self.hourStepCount {
                    let minY = self.minYOffsetForHourStep(i)
                    let timeLayoutAttributes = self.horizontalGridLineLayoutAttributesCache[NSIndexPath(index: i)]
                    timeLayoutAttributes.frame = CGRectMake(contentOffset.x, minY, bounds.size.width, gridLineWidth)
                    timeLayoutAttributes.zIndex = gridLineZIndex
                }
            }
        }
        
        private func calculateEventsLayoutAttributes() {
            if let collectionView = self.collectionView {
                let minSectionX = self.minXForSection(0)
                let sectionWidth = self.daySectionWidth
                let calculateFrameForItemAtIndexPath: (NSIndexPath)->CGRect? = {(indexPath) in
                    let eventTime = self.dataSource.collectionView(collectionView, layout: self, eventTimeForItemAtIndexPath: indexPath)
                    let minY = self.offsetYForFractionalHour(eventTime.startHourFractional)
                    let maxY = self.offsetYForFractionalHour(eventTime.endHourFractional)
                    
                    let height = maxY - minY
                    return CGRect(x: minSectionX + self.eventCellPadding.left, y: minY + self.eventCellPadding.top, width: sectionWidth - self.eventCellPadding.left - self.eventCellPadding.right, height: height - self.eventCellPadding.top - self.eventCellPadding.bottom)
                }
                var attributesStack = Stack<UICollectionViewLayoutAttributes>()
                for indexPath in self.allIndexPaths {
                    if let frame = calculateFrameForItemAtIndexPath(indexPath) {
                        var eventsLayoutAttributes = self.eventsLayoutAttributesCache[indexPath]
                        eventsLayoutAttributes.frame = frame
                        eventsLayoutAttributes.zIndex = eventsZIndex
                        attributesStack.push(eventsLayoutAttributes)
                    }
                }
                self.adjustEventsLayoutAttributesForOverlap(attributesStack.toArray())
            }
        }
        private func adjustEventsLayoutAttributesForOverlap(allAttributes: [UICollectionViewLayoutAttributes]) {
            var adjustedAttributesSet = Set<UICollectionViewLayoutAttributes>()
            let sectionWidth = self.daySectionWidth
            let adjustOverlap: [UICollectionViewLayoutAttributes]->Void = { (overlappingAttributes) in
                if overlappingAttributes.count == 0 {
                    return
                }
                // TODO better algorithm
                let adjustedWidth = sectionWidth / CGFloat(overlappingAttributes.count) // OK, will not be 0
                for (index, attributes) in enumerate(overlappingAttributes) {
                    var frame = attributes.frame
                    frame.origin.x += CGFloat(index) * adjustedWidth
                    frame.size.width = adjustedWidth - self.eventCellPadding.left - self.eventCellPadding.right
                    attributes.frame = frame
                }
            }
            for attributes in allAttributes {
                if adjustedAttributesSet.contains(attributes) {
                    // already adjusted
                    continue
                }
                
                // find overlapping events not already adjusted
                let frame = attributes.frame
                let toBeAdjusted = allAttributes.filter { !adjustedAttributesSet.contains($0) && CGRectIntersectsRect(frame, $0.frame) } // this will include the event itself by default
                adjustOverlap(toBeAdjusted)
                for adjusted in toBeAdjusted {
                    adjustedAttributesSet.insert(adjusted)
                }
            }
        }
        
        private func calculateSummarizedViewLayoutAttributes() {
            if let collectionView = self.collectionView {
                let width = collectionView.bounds.width
                for (index, interval) in enumerate(self.summarizedHourIntervals) {
                    let indexPath = NSIndexPath(index: index)
                    let layoutAttributes = self.summarizedViewLayoutAttributesCache[indexPath]
                    layoutAttributes.zIndex = summarizedViewZIndex
                    let minY = self.offsetYForFractionalHour(interval.start)
                    let maxY = self.offsetYForFractionalHour(interval.end)
                    layoutAttributes.frame = CGRect(origin: CGPoint(x: 0, y: minY), size: CGSize(width: width, height: maxY - minY))
                }
            }
        }
        
        /// MARK: Invalidation
        override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
            
            // invalidate efficiently
            let invalidateRowHeaders: ()->Void = {
                self.timeRowHeaderBackgroundLayoutAttributesCache.clearCache()
                self.timeRowHeaderLayoutAttributesCache.clearCache()
            }
            let invalidateGridLines: ()->Void = {
                self.verticalGridLineLayoutAttributesCache.clearCache()
                self.horizontalGridLineLayoutAttributesCache.clearCache()
            }
            let invalidateAll: ()->Void = {
                invalidateRowHeaders()
                invalidateGridLines()
                self.eventsLayoutAttributesCache.clearCache()
                self.summarizedViewLayoutAttributesCache.clearCache()
                self.summarizedHourStepsStorage = nil
                self.summarizedHourIntervalsStorage = nil
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
            if context.contentOffsetAdjustment != CGPointZero {
                invalidateAll()
                context.contentOffsetAdjustment = CGPointZero
            }
            // TODO specific items
            super.invalidateLayoutWithContext(context)
            
        }
        
        override func invalidationContextForBoundsChange(newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
            var context = super.invalidationContextForBoundsChange(newBounds)
            context.contentOffsetAdjustment = CGPointMake(newBounds.origin.x, newBounds.origin.y)
            context.contentSizeAdjustment = CGSizeMake(newBounds.size.width - self.collectionView!.bounds.size.width, newBounds.size.height - self.collectionView!.bounds.size.height)
            return context
        }
        
        /// MARK: UICollectionViewLayout Methods
        override func collectionViewContentSize() -> CGSize {
            if let collectionView = self.collectionView {
                return CGSizeMake(collectionView.bounds.width, self.layoutHeight)
            } else {
                return CGSizeZero
            }
        }
        
        override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
            if let kind = DecorationViewKind(rawValue: elementKind) {
                switch kind {
                case .VerticalGridLine:
                    return self.verticalGridLineLayoutAttributesCache[indexPath]
                case .TimeRowHeaderBackground:
                    return self.timeRowHeaderBackgroundLayoutAttributesCache[indexPath]
                case .HorizontalGridLine:
                    return self.horizontalGridLineLayoutAttributesCache[indexPath]
                }
            }
            assert(false, "Invalid Decoration View Kind \(elementKind)")
            return nil
        }
        
        override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
            return self.eventsLayoutAttributesCache[indexPath]
        }
        
        override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
            if let kind = SupplementaryViewKind(rawValue: elementKind) {
                switch kind {
                case .SummarizedView:
                    return self.summarizedViewLayoutAttributesCache[indexPath]
                case .TimeRowHeader:
                    return self.timeRowHeaderLayoutAttributesCache[indexPath]
                }
            }
            assert(false, "Invalid Supplementary View Kind \(elementKind)")
            return nil
        }
        
        override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
            var visibleAttributes: [UICollectionViewLayoutAttributes] = []
            let visibleFilter:(NSIndexPath, UICollectionViewLayoutAttributes)->Bool = {(_, layoutAttributes) in
                return CGRectIntersectsRect(rect, layoutAttributes.frame)
            }
            // only need to filter elements that do not move when scrolling vertically. horizontal scrolling is automatically taken care of because we use the visible sections to create the layout, and that only changes with horizontal scrolling
            visibleAttributes += self.eventsLayoutAttributesCache.filter(visibleFilter)
            visibleAttributes += self.verticalGridLineLayoutAttributesCache.values.array
            visibleAttributes += self.timeRowHeaderBackgroundLayoutAttributesCache.values.array
            visibleAttributes += self.timeRowHeaderLayoutAttributesCache.filter(visibleFilter)
            visibleAttributes += self.horizontalGridLineLayoutAttributesCache.filter(visibleFilter)
            visibleAttributes += self.summarizedViewLayoutAttributesCache.filter(visibleFilter)
            return visibleAttributes
        }
        
        override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
            return true
        }
        
        enum SupplementaryViewKind: String {
            case TimeRowHeader = "TimeRowHeader"
            case SummarizedView = "SummarizedView"
        }
        enum DecorationViewKind: String {
            case TimeRowHeaderBackground = "TimeRowHeaderBackground"
            case VerticalGridLine = "VerticalGridLine"
            case HorizontalGridLine = "HorizontalGridLine"
        }
    }
}
protocol SummaryDayCollectionViewDataSourceSummarizedLayout: class {
    /// Return the event time for the item at indexPath. nil if indexPath invalid
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, eventTimeForItemAtIndexPath indexPath: NSIndexPath) -> SummaryDayView.EventTime
    
    /// Return the height of the week view (scrollable height, not frame height)
    func heightForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> SummaryDayView.Height
    
    /// The factor to summarize by
    func summarizationFactorForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> SummaryDayView.SummarizationFactor
    
    /// Return the width of the time header
    func timeRowHeaderWidthForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> Double
    
    /// Return the minimum hour, from 0 to 23
    func minimumHourForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> Int
    
    /// Return the maximum hour, from 1 to 24. This is the first hour not seen. For example, setting this to 10 means that you will see the hour 9-10, but not 10-11
    func maximumHourForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> Int
    
    /// Return how many hours (can be fractional) each vertical slot represent
    func hourStepForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)-> Double
}