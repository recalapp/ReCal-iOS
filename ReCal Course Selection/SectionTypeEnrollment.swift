//
//  SectionTypeEnrollment.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/24/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
private let hashPrimeMultiplier = 131071
//struct SectionTypeEnrollment: Hashable {
//    let course: Course
//    let sectionType: SectionType
//    var enrollment: SectionEnrollment
//    
//    var hashValue: Int {
//        var hash = course.hashValue
//        hash = hash * hashPrimeMultiplier + sectionType.hashValue
//        switch enrollment {
//        case .Enrolled(let section):
//            hash = hash * hashPrimeMultiplier + section.hashValue
//        case .Unenrolled:
//            hash = hash * hashPrimeMultiplier + 1
//        }
//        return hash
//    }
//}

enum SectionEnrollment: Hashable {
    case Enrolled(Section), Unenrolled
    var hashValue: Int {
        var hash = 1
        switch self {
        case .Enrolled(let section):
            hash = hash * hashPrimeMultiplier + 1
            hash = hash * hashPrimeMultiplier + section.hashValue
        case .Unenrolled:
            hash = hash * hashPrimeMultiplier + 2
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

//func == (lhs: SectionTypeEnrollment, rhs: SectionTypeEnrollment) -> Bool {
//    if lhs.course != rhs.course {
//        return false
//    }
//    if lhs.sectionType != rhs.sectionType {
//        return false
//    }
//    if lhs.enrollment != rhs.enrollment {
//        return false
//    }
//    return true
//}