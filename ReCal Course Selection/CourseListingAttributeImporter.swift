//
//  CourseListingAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/19/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class CourseListingAttributeImporter: CompositeManagedObjectAttributeImporter {
    init() {
        let departmentCodeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "dept", attributeKey: "departmentCode")
        let courseNumberImporter = StringManagedObjectAttributeImporter(dictionaryKey: "number", attributeKey: "courseNumber")
        let isPrimaryImporter = NumberManagedObjectAttributeImporter(dictionaryKey: "is_primary", attributeKey: "isPrimary")
        super.init(attributeImporters: [departmentCodeImporter, courseNumberImporter, isPrimaryImporter])
    }
}
