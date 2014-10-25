//
//  Course.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon
private let hashPrimeMultipler = 32771
struct Course: Equatable, Printable, Hashable {
    
    let departmentCode: String
    let courseNumber: Int
    let color: UIColor
    let sections: [Section]
    
    var displayText: String {
        return "\(self.departmentCode) \(self.courseNumber)"
    }
    var description: String {
        return self.displayText
    }
    
    var hashValue: Int {
        var hash = self.departmentCode.hashValue
        hash = hash &* hashPrimeMultipler &+ courseNumber.hashValue
        for section in self.sections {
            hash = hash &* hashPrimeMultipler &+ section.hashValue
        }
        return hash
    }
}

func == (lhs: Course, rhs: Course)-> Bool {
    if lhs.departmentCode != rhs.departmentCode {
        return false
    }
    if lhs.courseNumber != rhs.courseNumber {
        return false
    }
    if lhs.sections.count != rhs.sections.count {
        return false
    }
    return arraysContainSameElements(lhs.sections, rhs.sections)
}