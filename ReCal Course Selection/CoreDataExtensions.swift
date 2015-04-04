//
//  CoreDataExtensions.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

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

extension CDSectionMeeting {
    var days: [Day] {
        let daysStringArray = self.daysStorage.componentsSeparatedByString(" ")
        return daysStringArray.reduce([Day](), combine: { (days, dayString) in
            if let day = Day(dayString: dayString) {
                return days + [day]
            }
            return days
        }).sorted { $0.rawValue < $1.rawValue }
    }
    var startTime: NSDateComponents {
        var component = NSDateComponents()
        component.hour = self.startHour.integerValue
        component.minute = self.startMinute.integerValue
        return component
    }
    var endTime: NSDateComponents {
        var component = NSDateComponents()
        component.hour = self.endHour.integerValue
        component.minute = self.endMinute.integerValue
        return component
    }
}

enum ModificationLogicalValue {
    case NotModified, Modified, Uploading
}

extension CDSchedule {
    var modifiedLogicalValue: ModificationLogicalValue {
        get {
            if self.modified == 1 {
                return .Modified
            } else if self.modified == 2 {
                return .Uploading
            } else {
                return .NotModified
            }
        }
        set {
            switch newValue {
            case .NotModified:
                self.modified = 0
            case .Modified:
                self.modified = 1
            case .Uploading:
                self.modified = 2
            }
        }
    }
}