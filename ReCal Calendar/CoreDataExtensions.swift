//
//  CoreDataExtensions.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/11/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData

extension CDCourse {
    var primaryListing: CDCourseListing {
        return self.courseListings.filteredSetUsingPredicate(NSPredicate(block: { (item, _) -> Bool in
            if let courseListing = item as? CDCourseListing {
                return courseListing.isPrimary.boolValue
            }
            return false
        })).anyObject()! as CDCourseListing
    }
    var displayText: String {
        return self.primaryListing.displayText
    }
}

extension CDCourseListing {
    var displayText: String {
        return "\(self.departmentCode) \(self.courseNumber)"
    }
}

extension CDSection {
    var sectionType: SectionType {
        return SectionType(rawValue: self.sectionTypeCode)!
    }
}

extension CDEvent {
    var eventType: EventType {
        return EventType(rawValue: self.eventTypeCode)!
    }
}
extension CDUser {
    var enrolledSections: [CDSection] {
        var sections: [CDSection] = []
        for enrollment in self.enrollments {
            sections.append(enrollment.section)
        }
        return sections
    }
    var enrolledCourses: [CDCourse] {
        return Set(initialItems: self.enrolledSections.map { $0.course }).toArray()
    }
    func colorForSection(section: CDSection) -> UIColor {
        for enrollment in self.enrollments {
            if enrollment.section.isEqual(section) {
                return enrollment.color as UIColor
            }
        }
        assertionFailure("Could not find section")
        return UIColor.redColor()
    }
}