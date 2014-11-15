//
//  SectionAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/14/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

import CoreData
import ReCalCommon

class SectionAttributeImporter : CompositeManagedObjectAttributeImporter {
    
    private let enrollmentAttributeImporter: SectionEnrollmentAttributeImporter
    
    init(userObjectId: NSManagedObjectID) {
        let titleAttributeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "section_name", attributeKey: "sectionTitle")
        let typeCodeAttributeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "section_type_code", attributeKey: "sectionTypeCode") { $0.lowercaseString }
        self.enrollmentAttributeImporter = SectionEnrollmentAttributeImporter(userObjectId: userObjectId)
        super.init(attributeImporters: [titleAttributeImporter, typeCodeAttributeImporter])
    }
    
    override func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> ManagedObjectAttributeImporter.ImportResult {
        let result = super.importAttributeFromDictionary(dict, intoManagedObject: managedObject, inManagedObjectContext: managedObjectContext)
        switch result {
        case .Success:
            var enrollment: CDSectionEnrollment!
            managedObjectContext.performBlockAndWait{
                enrollment = NSEntityDescription.insertNewObjectForEntityForName("CDSectionEnrollment", inManagedObjectContext: managedObjectContext) as? CDSectionEnrollment
            }
            if enrollment == nil {
                return .Error(.InvalidManagedObject)
            }
            if managedObject.entity.propertiesByName["enrollments"] == nil {
                return .Error(.InvalidManagedObject)
            }
            let enrollmentsSet = managedObject.mutableSetValueForKey("enrollments")
            for enrollment in enrollmentsSet {
                managedObjectContext.performBlockAndWait {
                    managedObjectContext.deleteObject(enrollment as NSManagedObject)
                }
            }
            self.enrollmentAttributeImporter.importAttributeFromDictionary(dict, intoManagedObject: enrollment, inManagedObjectContext: managedObjectContext)
            enrollmentsSet.addObject(enrollment)
            return .Success
        case .Error(_):
            return result
        }
    }
    
    private class SectionEnrollmentAttributeImporter: CompositeManagedObjectAttributeImporter {
        let userObjectId: NSManagedObjectID
        init(userObjectId: NSManagedObjectID) {
            self.userObjectId = userObjectId
            let colorAttributeImporter = ColorManagedObjectAttributeImporter(dictionaryKey: "section_color", attributeKey: "color")
            super.init(attributeImporters: [colorAttributeImporter])
        }
        
        private override func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> ManagedObjectAttributeImporter.ImportResult {
            let result = super.importAttributeFromDictionary(dict, intoManagedObject: managedObject, inManagedObjectContext: managedObjectContext)
            switch result {
            case .Success:
                if let enrollment = managedObject as? CDSectionEnrollment {
                    var ret: ImportResult = .Success
                    managedObjectContext.performBlockAndWait {
                        if let user = managedObjectContext.objectWithID(self.userObjectId) as? CDUser {
                            enrollment.user = user
                            ret = .Success
                        } else {
                            ret = .Error(.InvalidManagedObject)
                        }
                    }
                    return ret
                } else {
                    return .Error(.InvalidManagedObject)
                }
            case .Error(_):
                return result
            }
        }
    }
}