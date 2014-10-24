//
//  Section.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

struct Section: Equatable, ScheduleEvent {
    let type: SectionType
    let sectionNumber: Int
    let startTime: NSDateComponents
    let endTime: NSDateComponents
    let days: [Day]
    var displayText: String {
        return "\(self.type.sectionPrefix)\(self.sectionNumber)"
    }
    var title: String {
        return displayText
    }
}


func == (lhs: Section, rhs: Section) -> Bool {
    if lhs.type != rhs.type {
        return false
    }
    if lhs.sectionNumber != rhs.sectionNumber {
        return false
    }
    if !lhs.startTime.isEqual(rhs.startTime) {
        return false
    }
    if !lhs.endTime.isEqual(rhs.endTime) {
        return false
    }
    if !arraysContainSameElements(lhs.days, rhs.days) {
        return false
    }
    return true
}

enum SectionType: String {
    case Precept = "Pre"
    
    var displayText: String {
        switch self {
        case .Precept:
            return "Precept"
        }
    }
    
    var sectionPrefix: String {
        switch self {
        case .Precept:
            return "P"
        }
    }
}

enum Day: Int {
    case Monday = 0, Tuesday = 1, Wednesday = 2, Thursday = 3, Friday = 4, Saturday, Sunday
}