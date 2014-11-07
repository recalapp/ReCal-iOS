//
//  Course.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData
import ReCalCommon

private let hashPrimeMultipler = 32771
struct Course: Printable, ManagedObjectProxy {
    typealias ManagedObject = CDCourse
    let courseListings: [CourseListing]
    let title: String
    let courseDescription: String
    let color: UIColor
    let sections: [Section]
    let managedObjectProxyId: ManagedObjectProxyId
    let allSectionTypes: [SectionType]
    
    init(managedObject: CDCourse) {
        self.title = managedObject.title
        self.courseDescription = managedObject.courseDescription
        self.color = UIColor.greenColor() // TODO get proper color
        self.courseListings = managedObject.courseListings.allObjects.map { CourseListing(managedObject: $0 as CDCourseListing) }
        self.sections = managedObject.sections.allObjects.map { Section(managedObject: $0 as CDSection) }.sorted { $0.sectionName < $1.sectionName }
        self.managedObjectProxyId = .Existing(managedObject.objectID)
        self.allSectionTypes = self.sections.map { $0.type }.reduce(Set<SectionType>(), combine: {(var set, type) in
            if !set.contains(type){
                set.add(type)
            }
            return set
        }).toArray()
    }
    
    func commitToManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> ManagedObjectProxyCommitResult<ManagedObject> {
        let updateManagedObject: ManagedObject -> ManagedObjectProxyCommitResult<ManagedObject> = { (course) in
            // TODO update course
            return .Success(course)
        }
        switch self.managedObjectProxyId {
        case .Existing(let objectId):
            let managedObject: CDCourse? = {
                var managedObject: CDCourse?
                managedObjectContext.performBlockAndWait {
                    managedObject = managedObjectContext.objectWithID(objectId) as? CDCourse
                }
                return managedObject
            }()
            if let course = managedObject {
                return updateManagedObject(course)
            } else {
                return .Failure
            }
        case .NewObject:
            assertionFailure("Not implemented")
            return .Failure
        }
    }
    
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
        hash = hash &* hashPrimeMultipler &+ self.courseDescription.hashValue
        for listing in self.courseListings {
            hash = hash &* hashPrimeMultipler &+ listing.hashValue
        }
        for section in self.sections {
            hash = hash &* hashPrimeMultipler &+ section.hashValue
        }
        return hash
    }
}

struct CourseListing: Printable, ManagedObjectProxy {
    typealias ManagedObject = CDCourseListing
    
    let courseNumber: String
    let departmentCode: String
    let isPrimary: Bool
    let managedObjectProxyId: ManagedObjectProxyId
    init(managedObject: CDCourseListing) {
        self.courseNumber = managedObject.courseNumber
        self.departmentCode = managedObject.departmentCode
        self.isPrimary = managedObject.isPrimary.boolValue
        self.managedObjectProxyId = .Existing(managedObject.objectID)
    }
    
    var description: String {
        return "\(self.departmentCode) \(self.courseNumber)"
    }
    
    var hashValue: Int {
        var hash = self.courseNumber.hashValue
        hash = hash &* hashPrimeMultipler &+ self.departmentCode.hashValue
        hash = hash &* hashPrimeMultipler &+ self.isPrimary.hashValue
        return hash
    }
    func commitToManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> ManagedObjectProxyCommitResult<ManagedObject> {
        switch self.managedObjectProxyId {
        case .Existing(let objectId):
            var courseListingOpt: CDCourseListing?
            managedObjectContext.performBlockAndWait {
                courseListingOpt = managedObjectContext.objectWithID(objectId) as? CDCourseListing
            }
            if let courseListing = courseListingOpt {
                courseListing.courseNumber = self.courseNumber
                courseListing.departmentCode = self.departmentCode
                courseListing.isPrimary = NSNumber(bool: self.isPrimary)
                return .Success(courseListing)
            }
            return .Failure
        case .NewObject:
            assertionFailure("Not implemented")
            return .Failure
        }
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
    if lhs.courseDescription != rhs.courseDescription {
        return false
    }
    if !arraysContainSameElements(lhs.courseListings, rhs.courseListings) {
        return false
    }
    return arraysContainSameElements(lhs.sections, rhs.sections)
}