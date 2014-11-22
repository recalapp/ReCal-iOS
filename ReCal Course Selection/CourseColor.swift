//
//  CourseColor.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

private let hashPrimeMultiplier = 131071

class CourseColor: NSObject, NSCoding, Hashable, NSCopying {
    private let normalColorKey = "CourseColorNormalColor"
    private let highlightedColorKey = "CourseColorHighlightedColor"
    let normalColor: UIColor
    let highlightedColor: UIColor
    init(normalColor: UIColor, highlightedColor: UIColor) {
        self.normalColor = normalColor
        self.highlightedColor = highlightedColor
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        self.normalColor = aDecoder.decodeObjectForKey(normalColorKey) as UIColor
        self.highlightedColor = aDecoder.decodeObjectForKey(highlightedColorKey) as UIColor
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.normalColor, forKey: normalColorKey)
        aCoder.encodeObject(self.highlightedColor, forKey: highlightedColorKey)
    }
    override var hashValue: Int {
        return self.normalColor.hashValue &* hashPrimeMultiplier &+ self.highlightedColor.hashValue
    }
    override func isEqual(object: AnyObject?) -> Bool {
        if let color = object as? CourseColor {
            return color == self
        } else {
            return super.isEqual(object)
        }
    }
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = CourseColor(normalColor: self.normalColor.copy() as UIColor, highlightedColor: self.highlightedColor.copy() as UIColor)
        return copy
    }
}

func == (lhs: CourseColor, rhs: CourseColor) -> Bool {
    return lhs.normalColor.isEqual(rhs.normalColor) && lhs.highlightedColor.isEqual(rhs.highlightedColor)
}