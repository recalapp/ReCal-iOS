//
//  SlidingSelectionControl.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/19/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public class SlidingSelectionControl: UIControl {
    
    /// MARK: Properties
    /// The preferred max layout width for intrinsic content size
    public var preferredMaxLayoutWidth: CGFloat = 0.0
    
    /// The default value for preferredMaxLayoutWidth
    private var defaultPreferredMaxLayoutWidth: CGFloat {
        let givenWidth = self.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).width
        if givenWidth <= 0.0 {
            return CGFloat.max
        }
        return givenWidth
    }
    
    /// Cache for intrinsic content size
    private var contentSize: CGSize?
    
    /// An array of all the SlidingSelectionControlItem
    private let slidingSelectionControlItems: [SlidingSelectionControlItem]
    
    /// A stack of all the constraints associated with slidingSelectionControlItems
    lazy private var slidingSelectionControlItemConstraints = Stack<NSLayoutConstraint>()
    
    /// The current selected index
    public var selectedIndex: Int = 0 {
        willSet {
            assert(newValue >= 0, "Selected index must be greater than or equal 0")
            assert(newValue < self.slidingSelectionControlItems.count, "Selected index must be smaller than the number of possible items")
        }
    }
    
    override public var tintColor: UIColor! {
        didSet {
            for item in self.slidingSelectionControlItems {
                item.tintColor = self.tintColor
            }
        }
    }
    
    public var defaultBackgroundColor: UIColor = UIColor.whiteColor() {
        didSet {
            for item in self.slidingSelectionControlItems {
                item.defaultBackgroundColor = self.defaultBackgroundColor
            }
        }
    }
    
    /// MARK: Constructors
    required public init(coder aDecoder: NSCoder) {
        self.slidingSelectionControlItems = []
        super.init(coder: aDecoder)
    }
    
    override public init(frame: CGRect) {
        self.slidingSelectionControlItems = []
        super.init(frame: frame)
    }
    
    public init(items: [String], initialSelection: Int = 0) {
        assert(initialSelection >= 0, "Initial selection must be an array index, so it cannot be negative")
        assert(initialSelection < items.count, "Initial selection must be an array index, so it must be in the bounds of the array")
        self.slidingSelectionControlItems = []
        super.init()
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        //self.setTranslatesAutoresizingMaskIntoConstraints(false)
        for item in items {
            // set up item
            let slidingSelectionControlItem = SlidingSelectionControlItem()
            slidingSelectionControlItem.text = item
            slidingSelectionControlItem.tintColor = self.tintColor
            slidingSelectionControlItem.defaultBackgroundColor = self.defaultBackgroundColor
            self.addSubview(slidingSelectionControlItem)
            
            // actions
            slidingSelectionControlItem.addTarget(self, action: "updateSelection:forEvent:", forControlEvents: UIControlEvents.AllTouchEvents)
            
            // add to array
            self.slidingSelectionControlItems.append(slidingSelectionControlItem)
        }
        self.slidingSelectionControlItems[initialSelection].selected = true
        self.selectedIndex = initialSelection
        self.updateConstraintToFitWidth(CGFloat.max)
        self.backgroundColor = UIColor.blueColor()
    }
    
    /// MARK: Methods
    /// Update selection based on event
    func updateSelection(sender: SlidingSelectionControlItem?, forEvent eventOpt: UIEvent?) {
        if let event = eventOpt {
            let touchOpt = event.allTouches()?.anyObject() as UITouch?
            if let touch = touchOpt {
                // check if touch is in any view, if not, we don't process it (keeping last selection)
                let touchInSomeView = self.slidingSelectionControlItems.reduce(false, combine: {(found, item) in
                    if found {
                        return true
                    }
                    return item.containsTouch(touch)
                })
                
                // process touch
                if touchInSomeView {
                    for (index, slidingSelectionControlItem) in enumerate(self.slidingSelectionControlItems) {
                        if slidingSelectionControlItem.containsTouch(touch) {
                            slidingSelectionControlItem.selected = true
                            let oldSelected = self.selectedIndex
                            self.selectedIndex = index
                            if oldSelected != self.selectedIndex {
                                self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
                            }
                        } else {
                            slidingSelectionControlItem.selected = false
                        }
                    }
                }
            }
        }
    }
    
    public override func layoutMarginsDidChange() {
        let givenWidth = self.preferredMaxLayoutWidth <= 0.0 ? self.defaultPreferredMaxLayoutWidth : self.preferredMaxLayoutWidth
        if givenWidth < self.intrinsicContentSize().width {
            self.updateConstraintToFitWidth(givenWidth)
            // safe to continue, because invalidation doesn't actually trigger an update on constraints.
        }
        super.layoutMarginsDidChange()
    }
    
    override public func intrinsicContentSize() -> CGSize {
        if let contentSize = self.contentSize {
            return contentSize
        }
        else {
            return super.intrinsicContentSize()
        }
    }
    
    override public func updateConstraints() {
        let givenWidth = self.preferredMaxLayoutWidth <= 0.0 ? self.defaultPreferredMaxLayoutWidth : self.preferredMaxLayoutWidth
        self.updateConstraintToFitWidth(givenWidth)
        super.updateConstraints()
    }
    
    /// Layout the slidingSelectionControlItems to fit maxWidth
    private func updateConstraintToFitWidth(maxWidth: CGFloat) {
        // remove old constraints
        while let oldConstraint = self.slidingSelectionControlItemConstraints.pop() {
            self.removeConstraint(oldConstraint)
        }
        let updateContentSizeWithRunningSize: (CGSize, CGSize)->CGSize = {(oldContentSize, runningContentSize) in
            let newContentSize = CGSize(width: max(oldContentSize.width, runningContentSize.width), height: oldContentSize.height + runningContentSize.height)
            return newContentSize
        }
        let addConstraintForLeadingItem: (SlidingSelectionControlItem?)->Void = {(prevItemOpt) in
            if let prevItem = prevItemOpt {
                let trailingConstraint = NSLayoutConstraint(item: prevItem, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0)
                self.addConstraint(trailingConstraint)
                self.slidingSelectionControlItemConstraints.push(trailingConstraint)
            }
        }
        var prevItemOpt: SlidingSelectionControlItem? = nil
        var contentSize = CGSizeZero
        var runningWidth: CGFloat = 0.0
        var runningHeight: CGFloat = 0.0
        for slidingSelectionControlItem in reverse(self.slidingSelectionControlItems) {
            // update content size
            let itemConstraints = slidingSelectionControlItem.constraints() as [NSLayoutConstraint]
            for constraint in itemConstraints {
                if constraint.firstAttribute == .Width {
                    slidingSelectionControlItem.removeConstraint(constraint)
                }
            }
            let itemSize = slidingSelectionControlItem.intrinsicContentSize()
            if runningWidth + itemSize.width > maxWidth {
                contentSize = updateContentSizeWithRunningSize(contentSize, CGSize(width: runningWidth, height: runningHeight))
                runningHeight = 0
                runningWidth = 0
                addConstraintForLeadingItem(prevItemOpt)
                prevItemOpt = nil
            }
            runningWidth += itemSize.width
            runningHeight = max(runningHeight, itemSize.height)
            
            // constraints
            let yConstraint = NSLayoutConstraint(item: slidingSelectionControlItem, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .BottomMargin, multiplier: 1.0, constant: -contentSize.height)
            if let prevItem = prevItemOpt {
                let xConstraint = NSLayoutConstraint(item: slidingSelectionControlItem, attribute: .Right, relatedBy: .Equal, toItem: prevItem, attribute: .Left, multiplier: 1.0, constant: 0.0)
                self.addConstraints([xConstraint, yConstraint])
                self.slidingSelectionControlItemConstraints.push(xConstraint)
                self.slidingSelectionControlItemConstraints.push(yConstraint)
            }
            else {
                let xConstraint = NSLayoutConstraint(item: slidingSelectionControlItem, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .RightMargin, multiplier: 1.0, constant: 0.0)
                self.addConstraints([xConstraint, yConstraint])
                self.slidingSelectionControlItemConstraints.push(xConstraint)
                self.slidingSelectionControlItemConstraints.push(yConstraint)
            }
            prevItemOpt = slidingSelectionControlItem
        }
        addConstraintForLeadingItem(prevItemOpt)
        contentSize.width = max(contentSize.width, runningWidth)
        contentSize.height += runningHeight
        contentSize.width += self.layoutMargins.left + self.layoutMargins.right
        contentSize.height += self.layoutMargins.top + self.layoutMargins.bottom
        self.contentSize = contentSize
        self.setNeedsUpdateConstraints()
        self.invalidateIntrinsicContentSize()
    }
}

/// MARK: Helper class
class SlidingSelectionControlItem: UIControl {
    
    var defaultBackgroundColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.updateAppearance()
        }
    }
    override var tintColor: UIColor! {
        didSet {
            self.updateAppearance()
        }
    }
    private let xMargin:CGFloat = 0
    private let yMargin:CGFloat = 0
    
    override var selected: Bool {
        didSet {
            self.updateAppearance()
        }
    }
    
    var text: String {
        get {
            if let text = self.label.text {
                return text
            }
            return ""
        }
        set {
            self.label.text = newValue
            self.updateConstraints()
        }
    }
    
    private let label: UILabel
    override init() {
        self.label = UILabel()
        super.init()
        self.initialize()
    }
    required init(coder aDecoder: NSCoder) {
        self.label = UILabel()
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        self.label = UILabel()
        super.init(frame: frame)
        self.initialize()
    }
    
    private func initialize() {
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.label.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.label.textAlignment = .Center
        self.addSubview(self.label)
        
        let leadingConstraint = NSLayoutConstraint(item: self.label, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .LeftMargin, multiplier: 1.0, constant: self.xMargin)
        let trailingConstraint = NSLayoutConstraint(item: self.label, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .RightMargin, multiplier: 1.0, constant: -self.xMargin)
        let topConstraint = NSLayoutConstraint(item: self.label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .TopMargin, multiplier: 1.0, constant: self.yMargin)
        let bottomConstraint = NSLayoutConstraint(item: self.label, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .BottomMargin, multiplier: 1.0, constant: -self.yMargin)
        self.addConstraints([leadingConstraint, topConstraint, trailingConstraint, bottomConstraint])
    }
    
    private func updateAppearance() {
        if self.selected {
            self.backgroundColor = self.tintColor
            self.label.textColor = self.tintColor.darkerColor().darkerColor().darkerColor().darkerColor().darkerColor()
        }
        else {
            self.backgroundColor = self.defaultBackgroundColor
            self.label.textColor = self.defaultBackgroundColor.lighterColor().lighterColor().lighterColor().lighterColor()
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        var size = self.label.intrinsicContentSize()
        size.width += 2 * self.xMargin
        size.height += 2 * self.yMargin
        size.width += self.layoutMargins.right + self.layoutMargins.left
        size.height += self.layoutMargins.top + self.layoutMargins.bottom
        return size
    }
    
    func containsTouch(touch: UITouch)-> Bool {
        let location = touch.locationInView(self)
        return self.bounds.contains(location)
    }
}