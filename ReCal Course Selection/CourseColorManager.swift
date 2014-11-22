//
//  CourseColorManager.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class CourseColorManager: NSObject, NSCoding, NSCopying {
    
    private let frequencyCountKey = "CourseColorManagerFrequencyCountKey"
    
    private var frequencyCount: Dictionary<CourseColor, Int> = Dictionary()
    
    convenience init(availableColors: [CourseColor]) {
        self.init(availableColors: availableColors, occurrences: [])
    }
    
    init(availableColors: [CourseColor], occurrences: [CourseColor]) {
        assert(availableColors.count > 0)
        for color in availableColors {
            self.frequencyCount[color] = 0
        }
        for color in occurrences {
            if self.frequencyCount[color] != nil {
                self.frequencyCount[color] = self.frequencyCount[color]! + 1
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        self.frequencyCount = aDecoder.decodeObjectForKey(frequencyCountKey) as Dictionary<CourseColor, Int>
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.frequencyCount, forKey: frequencyCountKey)
    }
    
    private var nextMinimum: (CourseColor, Int) {
        assert(self.frequencyCount.keys.array.count > 0)
        var min = Int.max
        var minColors: [CourseColor] = []
        for (color, freq) in self.frequencyCount {
            if freq < min {
                min = freq
                minColors = [color]
            } else if freq == min {
                minColors.append(color)
            }
        }
        return (randomElement(minColors), min)
    }
    
    func getNextColor() -> CourseColor {
        let (color, count) = self.nextMinimum
        self.frequencyCount[color] = count + 1
        return color
    }
    
    func decrementColorOccurrence(color: CourseColor) {
        assert(self.frequencyCount[color] != nil)
        let dec = 1
        self.frequencyCount[color] = self.frequencyCount[color]! - dec
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let availableColors = self.frequencyCount.keys.array
        var occurrence = [CourseColor]()
        for (color, count) in self.frequencyCount {
            for i in 0..<count {
                occurrence.append(color)
            }
        }
        return CourseColorManager(availableColors: availableColors, occurrences: occurrence)
    }
}