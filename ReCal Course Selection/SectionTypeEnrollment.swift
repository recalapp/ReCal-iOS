//
//  SectionTypeEnrollment.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/24/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
private let hashPrimeMultiplier = 131071

enum SectionEnrollment: Hashable {
    case Enrolled(Section), Unenrolled
    var hashValue: Int {
        var hash = 1
        switch self {
        case .Enrolled(let section):
            hash = hash &* hashPrimeMultiplier &+ 1
            hash = hash &* hashPrimeMultiplier &+ section.hashValue
        case .Unenrolled:
            hash = hash &* hashPrimeMultiplier &+ 2
        }
        return hash
    }
}

func == (lhs: SectionEnrollment, rhs: SectionEnrollment) -> Bool {
    switch (lhs, rhs) {
    case (.Unenrolled, .Unenrolled):
        return true
    case (.Enrolled(let section1), .Enrolled(let section2)):
        return section1 == section2
    default:
        return false
    }
}