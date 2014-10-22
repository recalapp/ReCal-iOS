//
//  Util.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

func ASSERT_MAIN_THREAD() {
    assert(NSThread.isMainThread(), "This method must be called on the main thread");
}

extension Array {
    func find(isIncludedElement: T -> Bool) -> NSIndexSet {
        var indexes = NSMutableIndexSet()
        for (i, element) in enumerate(self) {
            if isIncludedElement(element) {
                indexes.addIndex(i)
            }
        }
        return indexes
    }
}

public extension NSLayoutConstraint {
    public class func layoutConstraintsForChildView(childView: UIView, inParentView parentView: UIView, withInsets insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        let leadingConstraint = NSLayoutConstraint(item: childView, attribute: .Leading, relatedBy: .Equal, toItem: parentView, attribute: .Left, multiplier: 1, constant: insets.left)
        let trailingConstraint = NSLayoutConstraint(item: childView, attribute: .Trailing, relatedBy: .Equal, toItem: parentView, attribute: .Right, multiplier: 1, constant: -insets.right)
        let topConstraint = NSLayoutConstraint(item: childView, attribute: .Top, relatedBy: .Equal, toItem: parentView, attribute: .Top, multiplier: 1, constant: insets.top)
        let bottomConstraint = NSLayoutConstraint(item: childView, attribute: .Bottom, relatedBy: .Equal, toItem: parentView, attribute: .Bottom, multiplier: 1, constant: -insets.bottom)
        return [leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]
    }
}