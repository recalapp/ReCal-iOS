//
//  SlidingSelectionControl.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/19/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public class SlidingSelectionControl: UIControl {
    
    private var contentSize: CGSize?
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(items: [String]) {
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
        }
        self.contentSize = contentSize
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
        
        let leadingConstraint = NSLayoutConstraint(item: self.label, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: self.label, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: self.label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: self.label, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.addConstraints([leadingConstraint, topConstraint, trailingConstraint, bottomConstraint])
    }
    
    override func intrinsicContentSize() -> CGSize {
        let size = self.label.intrinsicContentSize()
        return size
    }
}