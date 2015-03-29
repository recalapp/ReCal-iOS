//
//  ScheduleAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 2/28/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let lightDictionaryKey = "light"
private let darkDictionaryKey = "dark"

class ScheduleAttributeImporter: CompositeManagedObjectAttributeImporter {
    private let enrollmentsDictionaryKey = "enrollments"
    /*
    {
        title: "Name"
        lastModified: 123456
        id: 10
        semester: (semester object)
        available_colors (must decode json): [
            {
                light: "FFFFFF"
                dark: "FFFFFF"
            },
        ]
        enrollments (must decode json): {
            "course_id": 4434,
            "color": {
                "dark": "#954962",
                "light": "#ebd2db",
                "id": 3,
                "resource_uri": "/course_selection/api/v1/color_palette/3/"
            },
            "sections": [
            10231
            ]
            }
        ]
    }
    */
    init() {
        let nameImporter = StringManagedObjectAttributeImporter(dictionaryKey: "title", attributeKey: "name")
        // let lastModifiedImporter = DateManagedObjectAttributeImporter(dictionaryKey: "last_modified", attributeKey: "lastModified")
        let semesterImporter = ToOneChildManagedObjectAttributeImporter(dictionaryKey: "semester", attributeKey: "semester", childEntityName: "CDSemester", childAttributeImporter: SemesterAttributeImporter(), childSearchPattern: .SearchStringEqual("id", "serverId"), deleteMode: .NoDelete)
        
        // use this if given only semester id
        //let semesterImporter = ToOneChildLookUpManagedObjectAttributeImporter(dictionaryKey: "semester", attributeKey: "semester", childEntityName: "CDSemester", childAttributeKey: "serverId", childAttributeLookUpType: .String)
        let availableColorsImporter = AvailableColorAttributeImporter(dictionaryKey: "available_colors", attributeKey: "availableColors")
        // need: courses, sections, course-color map
        super.init(attributeImporters: [nameImporter, semesterImporter, availableColorsImporter])
    }
    private func parseEnrollments(json:String)->[Dictionary<String, AnyObject>]? {
        var errorOpt: NSError?
        let jsonData = json.dataUsingEncoding(NSUTF8StringEncoding)
        if jsonData == nil {
            return nil
        }
        let arrayOpt = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.allZeros, error: &errorOpt) as? [Dictionary<String, AnyObject>]
        if let error = errorOpt {
            return nil
        }
        return arrayOpt
    }
    private func importEnrollment(enrollmentDict: Dictionary<String, AnyObject>, scheduleManagedObject: CDSchedule, managedObjectContext: NSManagedObjectContext) -> EnrollmentImportResult {
        // CAREFUL managedobjectid changes if this is a new object. but we never save a new course object here, so it's fine
        func tryFetch(#entityName: String, #serverId: AnyObject, #managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
            var errorOpt: NSError?
            let fetchRequest = NSFetchRequest(entityName: entityName)
            fetchRequest.predicate = NSPredicate(format: "serverId = %@", "\(serverId)")
            fetchRequest.fetchLimit = 1
            var fetched: [NSManagedObject]?
            managedObjectContext.performBlockAndWait {
                fetched = managedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt) as? [NSManagedObject]
            }
            if let error = errorOpt {
                println("Error fetching in schedule enrollment import. Error: \(error)")
                return nil
            }
            return fetched?.first
        }
        func tryParseColor(#dictionary: [String: AnyObject]?) -> CourseColor? {
            if let lightHex = dictionary?[lightDictionaryKey] as? String {
                if let darkHex = dictionary?[darkDictionaryKey] as? String {
                    return CourseColor(normalColorHexString: lightHex, highlightedColorHexString: darkHex)
                }
            }
            return nil
        }
        let courseIdOpt: AnyObject? = enrollmentDict["course_id"]
        if courseIdOpt == nil {
            return .Failure
        }
        let courseId: AnyObject = courseIdOpt!
        let sectionIdsOpt = enrollmentDict["sections"] as? [AnyObject]
        if sectionIdsOpt == nil {
            return .Failure
        }
        let sectionIds: [AnyObject] = sectionIdsOpt!
        if let courseManagedObject = tryFetch(entityName: "CDCourse", serverId: "\(courseId)", managedObjectContext: managedObjectContext) as? CDCourse {
            managedObjectContext.performBlockAndWait {
                let coursesSet = scheduleManagedObject.mutableSetValueForKey("enrolledCourses")
                coursesSet.addObject(courseManagedObject)
            }
            for id in sectionIds {
                if let section = tryFetch(entityName: "CDSection", serverId: id, managedObjectContext: managedObjectContext) as? CDSection {
                    if section.course != courseManagedObject {
                        return .Failure
                    }
                    managedObjectContext.performBlockAndWait {
                        let sectionsSet = scheduleManagedObject.mutableSetValueForKey("enrolledSections")
                        sectionsSet.addObject(section)
                    }
                } else {
                    return .Failure
                }
            }
            if let color = tryParseColor(dictionary: enrollmentDict["color"] as? [String:AnyObject]) {
                return .Success(courseManagedObject.objectID, color)
            }
            return .Failure
        } else {
            return .Failure
        }
    }
    
    override func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> ManagedObjectAttributeImporter.ImportResult {
        let superResult = super.importAttributeFromDictionary(dict, intoManagedObject: managedObject, inManagedObjectContext: managedObjectContext)
        switch superResult {
        case .Error(_):
            return superResult
        case .Success:
            if let scheduleManagedObject = managedObject as? CDSchedule {
                let enrollmentsJson = dict[self.enrollmentsDictionaryKey] as? String
                if enrollmentsJson == nil {
                    return .Error(.InvalidDictionary)
                }
                if let enrollments = self.parseEnrollments(enrollmentsJson!) {
                    scheduleManagedObject.removeEnrolledCourses(scheduleManagedObject.enrolledCourses)
                    scheduleManagedObject.removeEnrolledSections(scheduleManagedObject.enrolledSections)
                    let colorMapOpt = enrollments.map { self.importEnrollment($0, scheduleManagedObject: scheduleManagedObject, managedObjectContext: managedObjectContext) }.reduce([NSURL: CourseColor]()) { (colorMap: [NSURL: CourseColor]?, result) -> [NSURL:CourseColor]? in
                        if colorMap == nil {
                            return nil
                        }
                        switch result {
                        case .Failure:
                            return nil
                        case .Success(let id, let color):
                            if var map = colorMap {
                                let key = id.URIRepresentation()
                                map[key] = color
                                return map
                            }
                            return nil
                        }
                    }
                    if let colorMap = colorMapOpt {
                        managedObjectContext.performBlockAndWait {
                            scheduleManagedObject.courseColorMap = colorMap
                            scheduleManagedObject.lastModified = NSDate()
                        }
                        return .Success
                    }
                    return .Error(.InvalidDictionary)
                } else {
                    return .Error(.InvalidDictionary)
                }
            } else {
                return .Error(.InvalidManagedObject)
            }
        }
    }
    
    private enum EnrollmentImportResult {
        case Failure
        case Success(NSManagedObjectID, CourseColor)
    }
}

/// class for importing an array of CourseColor

private class AvailableColorAttributeImporter: ManagedObjectAttributeImporter {
    private let dictionaryKey: String
    private let attributeKey: String
    init(dictionaryKey: String, attributeKey: String) {
        self.dictionaryKey = dictionaryKey
        self.attributeKey = attributeKey
    }
    private func checkArray(array: [Dictionary<String, AnyObject>])->Bool {
        return array.map { dict in dict[lightDictionaryKey] as? String != nil && dict[darkDictionaryKey] as? String != nil}.reduce(true) {$0 && $1}
    }
    private func parseArray(json: String) -> [Dictionary<String, AnyObject>]? {
        var errorOpt: NSError?
        let jsonData = json.dataUsingEncoding(NSUTF8StringEncoding)
        if jsonData == nil {
            return nil
        }
        let arrayOpt = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.allZeros, error: &errorOpt) as? [Dictionary<String, AnyObject>]
        if let error = errorOpt {
            return nil
        }
        return arrayOpt
    }
    private override func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> ManagedObjectAttributeImporter.ImportResult {
        if let jsonString = dict[self.dictionaryKey] as? String {
            if let array = self.parseArray(jsonString) {
                if !self.checkArray(array) {
                    println("Error, invalid available color array in schedule")
                    return .Error(.InvalidDictionary)
                }
                let colors = array.map { CourseColor(normalColorHexString: $0[lightDictionaryKey]! as String, highlightedColorHexString: $0[darkDictionaryKey]! as String) }
                managedObjectContext.performBlockAndWait {
                    managedObject.setValue(colors, forKey: self.attributeKey)
                }
                return .Success
            } else {
                println("Error parsing available color when importing schedule")
                return .Error(.InvalidDictionary)
            }
        } else {
            println("Error, available color does not exist in schedule")
            return .Error(.InvalidDictionary)
        }
        
    }
}
