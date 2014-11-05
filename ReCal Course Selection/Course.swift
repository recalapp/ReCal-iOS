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
struct Course: Printable, Hashable {
    
    let courseListings: [CourseListing]
    let title: String
    let color: UIColor
    let sections: [Section]
    
    var primaryListing: CourseListing {
        return self.courseListings.filter { $0.isPrimary }.last!
    }
    
    var displayText: String {
        return "\(self.primaryListing)"
    }
    var description: String {
        return self.displayText
    }
    
    var hashValue: Int {
        var hash = self.title.hashValue
        for listing in self.courseListings {
            hash = hash &* hashPrimeMultipler &+ listing.hashValue
        }
        for section in self.sections {
            hash = hash &* hashPrimeMultipler &+ section.hashValue
        }
        return hash
    }
}

struct CourseListing: Hashable, Printable {
    let courseNumber: String
    let departmentCode: String
    let isPrimary: Bool
    
    var description: String {
        return "\(self.departmentCode) \(self.courseNumber)"
    }
    
    var hashValue: Int {
        var hash = self.courseNumber.hashValue
        hash = hash &* hashPrimeMultipler &+ self.departmentCode.hashValue
        hash = hash &* hashPrimeMultipler &+ self.isPrimary.hashValue
        return hash
    }
}

func == (lhs: CourseListing, rhs: CourseListing)-> Bool {
    if lhs.courseNumber != rhs.courseNumber {
        return false
    }
    if lhs.departmentCode != rhs.departmentCode {
        return false
    }
    if lhs.isPrimary != rhs.isPrimary {
        return false
    }
    return true
}

func == (lhs: Course, rhs: Course)-> Bool {
    if lhs.title != rhs.title {
        return false
    }
    if !arraysContainSameElements(lhs.courseListings, rhs.courseListings) {
        return false
    }
    return arraysContainSameElements(lhs.sections, rhs.sections)
}