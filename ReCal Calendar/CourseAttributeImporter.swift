//
//  CourseAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/14/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class CourseAttributeImporter : CompositeManagedObjectAttributeImporter {
    init(userObjectId: NSManagedObjectID) {
        let titleAttributeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "course_title", attributeKey: "courseTitle")
        let descriptionAttributeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "course_description", attributeKey: "courseDescription")
        let sectionAttributeImporter = SectionAttributeImporter(userObjectId: userObjectId)
        let sectionChildAttributeImporter = ToManyChildManagedObjectAttributeImporter(dictionaryKey: "sections", attributeKey: "sections", childEntityName: "CDSection", childAttributeImporter: sectionAttributeImporter, childSearchPattern: .SearchStringEqual("section_id", "serverId"))
        let listingAttributeImporter = CourseListingAttributeImporter()
        let listingChildAttributeImporter = ToManyChildManagedObjectAttributeImporter(dictionaryKey: "course_listings", attributeKey: "courseListings", childEntityName: "CDCourseListing", childAttributeImporter: listingAttributeImporter, childSearchPattern: .NoSearch, deleteMode: .NoDelete)
        let primaryListingChildAttributeImporter = ToManyChildManagedObjectAttributeImporter(dictionaryKey: "course_primary_listing", attributeKey: "courseListings", childEntityName: "CDCourseListing", childAttributeImporter: listingAttributeImporter, childSearchPattern: .NoSearch, deleteMode: .NoDelete)
        super.init(attributeImporters: [titleAttributeImporter, descriptionAttributeImporter, sectionChildAttributeImporter, listingChildAttributeImporter])
    }
    override func importAttributeFromDictionary(var dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> ManagedObjectAttributeImporter.ImportResult {
        if let listings = dict["course_listings"] as? String {
            dict["course_listings"] = listings.componentsSeparatedByString("/").map { (listing)->Dictionary<String, AnyObject> in
                let split = listing.componentsSeparatedByString(" ").filter { countElements($0) > 0 }
                return ["department_code":split[0], "course_number":split[1], "is_primary": NSNumber(bool: false)]
            }
        } else {
            return .Error(.InvalidDictionary)
        }
        if let primaryListing = dict["course_primary_listing"] as? String {
            let split = primaryListing.componentsSeparatedByString(" ").filter { countElements($0) > 0 }
            dict["course_primary_listing"] = ["department_code":split[0], "course_number":split[1], "is_primary": NSNumber(bool: true)]
        } else {
            return .Error(.InvalidDictionary)
        }
        if let course = managedObject as? CDCourse {
            for listing in course.courseListings {
                managedObjectContext.performBlockAndWait {
                    managedObjectContext.deleteObject(listing as NSManagedObject)
                }
            }
        } else {
            return .Error(.InvalidManagedObject)
        }
        return super.importAttributeFromDictionary(dict, intoManagedObject: managedObject, inManagedObjectContext: managedObjectContext)
    }
}

class CourseListingAttributeImporter : CompositeManagedObjectAttributeImporter {
    init() {
        let departmentCodeAttributeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "department_code", attributeKey: "departmentCode")
        let courseNumberAttributeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "course_number", attributeKey: "courseNumber")
        let isPrimaryAttributeImporter = NumberManagedObjectAttributeImporter(dictionaryKey: "is_primary", attributeKey: "isPrimary")
        super.init(attributeImporters: [departmentCodeAttributeImporter, courseNumberAttributeImporter, isPrimaryAttributeImporter])
    }
}