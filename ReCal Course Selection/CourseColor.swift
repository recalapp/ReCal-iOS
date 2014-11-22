//
//  CourseColor.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class CourseColor: NSObject, NSCoding {
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
}