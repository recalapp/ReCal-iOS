//
//  SummaryDayView.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

private let eventCellIdentifier = "eventCellIdentifier"
private let timeRowHeaderIdentifier = "timeRowHeaderIdentifier"
private let summarizedViewIdentifier = "summarizedViewIdentifier"

public class SummaryDayView: UIView, SummaryDayCollectionViewDataSourceSummarizedLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    public weak var delegate: SummaryDayViewDelegate?
    private var calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    private var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter.formatterWithUSLocale()
        formatter.dateFormat = "h a" // 9 AM
        return formatter
    }()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    public override init() {
        super.init()
        self.initialize()
    }
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    private var minimumHour: Int {
        return self.viewModel?.events.first?.time.startHour ?? 0
    }
    public var state: State = .Summarized
    public var viewModel: SummaryDayViewModel? {
        didSet {
            self.collectionView.reloadData()
            self.invalidateIntrinsicContentSize()
        }
    }
    public var layoutAttributes: SummaryDayViewLayoutAttributes = DefaultLayoutAttributes()
    
    lazy private var summarizedLayout: SummaryDayCollectionViewSummarizedLayout = {
        let layout = SummaryDayCollectionViewSummarizedLayout(dataSource: self)
        layout.registerClass(SummaryDayGridView.self,
            forDecorationViewOfKind: SummaryDayCollectionViewSummarizedLayout.DecorationViewKind.HorizontalGridLine.rawValue)
        layout.registerClass(SummaryDayGridView.self,
            forDecorationViewOfKind: SummaryDayCollectionViewSummarizedLayout.DecorationViewKind.VerticalGridLine.rawValue)
        layout.registerClass(SummaryDayTimeRowHeaderBackgroundView.self,
            forDecorationViewOfKind: SummaryDayCollectionViewSummarizedLayout.DecorationViewKind.TimeRowHeaderBackground.rawValue)
        return layout
    }()
    lazy private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.summarizedLayout)
        collectionView.scrollEnabled = false
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerNib(UINib(nibName: "SummaryDayEventCollectionViewCell", bundle: NSBundle.commonBundle()), forCellWithReuseIdentifier: eventCellIdentifier)
        collectionView.registerNib(UINib(nibName: "SummaryDayTimeRowHeaderView", bundle: NSBundle.commonBundle()), forSupplementaryViewOfKind: SummaryDayCollectionViewSummarizedLayout.SupplementaryViewKind.TimeRowHeader.rawValue, withReuseIdentifier: timeRowHeaderIdentifier)
        collectionView.registerNib(UINib(nibName: "SummaryDaySummarizedView", bundle: NSBundle.commonBundle()), forSupplementaryViewOfKind: SummaryDayCollectionViewSummarizedLayout.SupplementaryViewKind.SummarizedView.rawValue, withReuseIdentifier: summarizedViewIdentifier)
        return collectionView
    }()
    
    private var notificationObservers: [AnyObject] = []
    
    private func initialize() {
        let collectionView = self.collectionView
        let updateColorScheme: Void->Void = {
            self.collectionView.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
        }
        updateColorScheme()
        self.addSubview(collectionView)
        self.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(collectionView, inParentView: self, withInsets: UIEdgeInsetsZero))
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
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    public override func intrinsicContentSize() -> CGSize {
        return self.summarizedLayout.collectionViewContentSize()
    }
    
    /// MARK: - Collection View Data Source
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(eventCellIdentifier, forIndexPath: indexPath) as SummaryDayEventCollectionViewCell
        cell.viewModel = self.viewModel?.events[indexPath.item]
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if let kind = SummaryDayCollectionViewSummarizedLayout.SupplementaryViewKind(rawValue: kind) {
            switch kind {
            case .SummarizedView:
                let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind.rawValue, withReuseIdentifier: summarizedViewIdentifier, forIndexPath: indexPath) as UICollectionReusableView
                return view
            case .TimeRowHeader:
                let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind.rawValue, withReuseIdentifier: timeRowHeaderIdentifier, forIndexPath: indexPath) as SummaryDayTimeRowHeaderView
                let component = NSDateComponents()
                component.hour = indexPath.section + self.minimumHour
                let date = self.calendar.dateFromComponents(component)!
                view.timeLabel.text = self.timeFormatter.stringFromDate(date)
                return view
            }
        }
        assertionFailure("unsupported supplementary view kind \(kind)")
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.events.count ?? 0
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /// MARK: Collection View Delegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        if let event = self.viewModel?.events[indexPath.item] {
            self.delegate?.summaryDayView(self, didSelectEvent: event)
        }
    }
    
    /// MARK: - Summarized Layout DataSource
    /// Return the event time for the item at indexPath. nil if indexPath invalid
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, eventTimeForItemAtIndexPath indexPath: NSIndexPath) -> SummaryDayView.EventTime {
        return self.viewModel?.events[indexPath.row].time ?? EventTime(startHour: 0, startMinute: 0, endHour: 0, endMinute: 0)
    }
    
    /// Return the height of the week view (scrollable height, not frame height)
    func heightForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> SummaryDayView.Height {
        return self.layoutAttributes.summarizedHeight
    }
    
    /// The factor to summarize by
    func summarizationFactorForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> SummaryDayView.SummarizationFactor {
        return self.layoutAttributes.summarizationFactor
    }
    
    /// Return the width of the time header
    func timeRowHeaderWidthForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> Double {
        return 60.0
    }
    
    /// Return the minimum hour, from 0 to 23
    func minimumHourForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> Int {
        return self.minimumHour
    }
    
    /// Return the maximum hour, from 1 to 24. This is the first hour not seen. For example, setting this to 10 means that you will see the hour 9-10, but not 10-11
    func maximumHourForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout) -> Int {
        return (self.viewModel?.events.last?.time.endHour ?? 23) + 1
    }
    
    /// Return how many hours (can be fractional) each vertical slot represent
    func hourStepForCollectionView(collectionView: UICollectionView, layout: UICollectionViewLayout)-> Double {
        return 1
    }
    
    /// MARK: - declarations
    public enum State {
        case Summarized
        case Expanded
    }
    public struct DefaultLayoutAttributes: SummaryDayViewLayoutAttributes {
        public let expandedHeight: Height = .Fill(oneHourHeight:50)
        public let summarizedHeight: Height = .Fill(oneHourHeight:50)
        public let summarizationFactor: SummarizationFactor = .Constant(20)
    }
}
public protocol SummaryDayViewDelegate: class {
    func summaryDayView(summaryDayView: SummaryDayView, didSelectEvent event: SummaryDayViewEvent)
}