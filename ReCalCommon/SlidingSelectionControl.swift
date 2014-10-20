//
//  SlidingSelectionControl.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/19/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public class SlidingSelectionControl: UIControl {
    
    private let contentSize: CGSize?
    private let slidingSelectionControlItems: [SlidingSelectionControlItem]
    
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
        var prevItemOpt: SlidingSelectionControlItem? = nil
        var contentSize = CGSizeZero
        for item in items {
            // set up item
            let slidingSelectionControlItem = SlidingSelectionControlItem()
            slidingSelectionControlItem.text = item
            self.addSubview(slidingSelectionControlItem)
            
            // update content size
            let itemSize = slidingSelectionControlItem.intrinsicContentSize()
            contentSize.width += itemSize.width
            contentSize.height = max(contentSize.height, itemSize.height)
            
            // constraints
            let yConstraint = NSLayoutConstraint(item: slidingSelectionControlItem, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
            if let prevItem = prevItemOpt {
                let xConstraint = NSLayoutConstraint(item: slidingSelectionControlItem, attribute: .Left, relatedBy: .Equal, toItem: prevItem, attribute: .Right, multiplier: 1.0, constant: 0.0)
                self.addConstraints([xConstraint, yConstraint])
            }
            else {
                let xConstraint = NSLayoutConstraint(item: slidingSelectionControlItem, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0.0)
                self.addConstraints([xConstraint, yConstraint])
            }
            prevItemOpt = slidingSelectionControlItem
            
            // actions
            slidingSelectionControlItem.addTarget(self, action: "updateSelection:forEvent:", forControlEvents: UIControlEvents.AllTouchEvents)
            
            // add to array
            self.slidingSelectionControlItems.append(slidingSelectionControlItem)
        }
        self.slidingSelectionControlItems[initialSelection].selected = true
        self.contentSize = contentSize
    }
    
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
                    for slidingSelectionControlItem in self.slidingSelectionControlItems {
                        if slidingSelectionControlItem.containsTouch(touch) {
                            slidingSelectionControlItem.selected = true
                        } else {
                            slidingSelectionControlItem.selected = false
                        }
                    }
                }
            }
        }
    }
    
    override public func intrinsicContentSize() -> CGSize {
        if let contentSize = self.contentSize {
            return contentSize
        }
        else {
            return super.intrinsicContentSize()
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}

class SlidingSelectionControlItem: UIControl {
    
    private let xMargin:CGFloat = 8.0
    private let yMargin:CGFloat = 8.0
    
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
        self.addSubview(self.label)
        
        let leadingConstraint = NSLayoutConstraint(item: self.label, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: self.xMargin)
        let trailingConstraint = NSLayoutConstraint(item: self.label, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -self.xMargin)
        let topConstraint = NSLayoutConstraint(item: self.label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: self.yMargin)
        let bottomConstraint = NSLayoutConstraint(item: self.label, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -self.yMargin)
        self.addConstraints([leadingConstraint, topConstraint, trailingConstraint, bottomConstraint])
    }
    
    private func updateAppearance() {
        if self.selected {
            self.backgroundColor = UIColor.greenColor()
        }
        else {
            self.backgroundColor = UIColor.clearColor()
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        var size = self.label.intrinsicContentSize()
        size.width += 2 * self.xMargin
        size.height += 2 * self.yMargin
        return size
    }
    
    func containsTouch(touch: UITouch)-> Bool {
        let location = touch.locationInView(self)
        return self.bounds.contains(location)
    }
}