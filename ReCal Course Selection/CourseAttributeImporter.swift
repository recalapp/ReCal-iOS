//
//  CourseAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/19/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class CourseAttributeImporter: CompositeManagedObjectAttributeImporter {
    init() {
        let titleImporter = StringManagedObjectAttributeImporter(dictionaryKey: "title", attributeKey: "title")
        let descriptionImporter = StringManagedObjectAttributeImporter(dictionaryKey: "description", attributeKey: "courseDescription")
        let listingImporter = CourseListingAttributeImporter()
        let listingToManyImporter = ToManyChildManagedObjectAttributeImporter(dictionaryKey: "course_listings", attributeKey: "courseListings", childEntityName: "CDCourseListing", childAttributeImporter: listingImporter, childSearchPattern: .NoSearch, deleteMode: .Delete)
        let sectionImporter = SectionAttributeImporter()
        let sectionToManyImporter = ToManyChildManagedObjectAttributeImporter(dictionaryKey: "sections", attributeKey: "sections", childEntityName: "CDSection", childAttributeImporter: sectionImporter, childSearchPattern: .SearchStringEqual("id", "serverId"), deleteMode: .Delete)
        let semesterImporter = SemesterAttributeImporter()
        let semesterToOneImporter = ToOneChildManagedObjectAttributeImporter(dictionaryKey: "semester", attributeKey: "semester", childEntityName: "CDSemester", childAttributeImporter: semesterImporter, childSearchPattern: .SearchStringEqual("id", "serverId"), deleteMode: .NoDelete)
        super.init(attributeImporters: [titleImporter, descriptionImporter, listingToManyImporter, semesterToOneImporter, sectionToManyImporter])
    }
}
