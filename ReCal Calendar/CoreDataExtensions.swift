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