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
    
    var availableColors: [CourseColor] {
        return self.frequencyCount.keys.array
    }
    
    subscript(color: CourseColor)->Int? {
        return frequencyCount[color]
    }
    
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
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        self.frequencyCount = aDecoder.decodeObjectForKey(frequencyCountKey) as! Dictionary<CourseColor, Int>
        super.init()
        println(self.frequencyCount)
        assert(self.checkInvariants())
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.frequencyCount, forKey: frequencyCountKey)
        println("encoding \(self.frequencyCount)")
        assert(self.checkInvariants())
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
        var frequencyCount = self.frequencyCount // protects against swift bug
        frequencyCount[color] = count + 1
        self.frequencyCount = frequencyCount
        assert(self.checkInvariants())
        return color
    }
    
    func decrementColorOccurrence(color: CourseColor) {
        assert(self.frequencyCount[color] != nil)
        let dec = 1
        var frequencyCount = self.frequencyCount // protects against swift bug
        frequencyCount[color] = frequencyCount[color]! - dec
        self.frequencyCount = frequencyCount
        assert(self.checkInvariants())
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
    
    private func checkInvariants() -> Bool {
        for (_, count) in self.frequencyCount {
            if count < 0 {
                return false
            }
        }
        return true
    }
}