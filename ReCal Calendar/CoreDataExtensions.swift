//
//  CoreDataExtensions.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/11/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData
import ReCalCommon

extension CDServerObject {
    class func findServerObjectWithServerId(serverId: String, withEntityName entityName: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> CDServerObject? {
        var errorOpt: NSError?
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let serverIdPredicate = NSPredicate(format: "serverId = %@", argumentArray: [serverId])
        fetchRequest.predicate = serverIdPredicate
        fetchRequest.fetchLimit = 1
        var managedObject: CDServerObject?
        managedObjectContext.performBlockAndWait {
            let fetched = managedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt)
            if let error = errorOpt {
                println("Error fetching for entity name: \(entityName), with server id: \(serverId). Error: \(error)")
                abort()
            }
            //println("\(entityName) fetched \(fetched) for server id \(serverId)")
            managedObject = fetched?.last as? CDServerObject
        }
        return managedObject
    }
}

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
    var agendaSection: String? {
        return AgendaViewController.AgendaSection(date: self.eventStart)?.rawValue
    }
}
extension CDUser {
    var enrolledSections: Set<CDSection> {
        var sections: [CDSection] = []
        for enrollment in self.enrollments {
            sections.append(enrollment.section)
        }
        return Set(initialItems: sections)
    }
    var enrolledCourses: Set<CDCourse> {
        return self.enrolledSections.map { $0.course }
    }
    func colorForSection(section: CDSection) -> UIColor {
        for enrollment in self.enrollments {
            if section.isEqual(enrollment.section) {
                return enrollment.color as UIColor
            }
        }
        assertionFailure("Could not find section")
        return UIColor.redColor()
    }
}