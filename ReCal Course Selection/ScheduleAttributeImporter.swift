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
private let colorIdDictionaryKey = "id"

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
    private func processEnrollment(enrollmentDict: Dictionary<String, AnyObject>) -> EnrollmentProcessResult {
        // CAREFUL managedobjectid changes if this is a new object. but we never save a new course object here, so it's fine
        func tryParseColor(#dictionary: [String: AnyObject]?) -> CourseColor? {
            if let lightHex = dictionary?[lightDictionaryKey] as? String {
                if let darkHex = dictionary?[darkDictionaryKey] as? String {
                    if let id: AnyObject = dictionary?[colorIdDictionaryKey] {
                        return CourseColor(normalColorHexString: lightHex, highlightedColorHexString: darkHex, serverId: "\(id)")
                    }
                }
            }
            return nil
        }
        let courseIdOpt: AnyObject? = enrollmentDict["course_id"]
        if courseIdOpt == nil {
            return .Failure
        }
        let courseId = "\(courseIdOpt!)"
        let sectionIdsOpt = enrollmentDict["sections"] as? [AnyObject]
        if sectionIdsOpt == nil {
            return .Failure
        }
        let sectionIds: [String] = sectionIdsOpt!.map {"\($0)"}
        if let color = tryParseColor(dictionary: enrollmentDict["color"] as? [String:AnyObject]) {
            return .Success(courseId: courseId, sectionIds: sectionIds, color: color)
        }
        return .Failure
    }
    
    override func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> ManagedObjectAttributeImporter.ImportResult {
        if let scheduleManagedObject = managedObject as? CDSchedule {
            if scheduleManagedObject.modified.boolValue || scheduleManagedObject.markedDeleted.boolValue {
                return .Success // refuse to update if modified
            }
        } else {
            return .Error(.InvalidManagedObject)
        }
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
                    let (coursesIds, sectionsIds, colorMap) = enrollments.map(self.processEnrollment).reduce(([String](), [String](), [String:CourseColor]()), combine: { (finalResult, processResult) in
                        
                        switch processResult {
                        case .Failure:
                            return finalResult
                        case let .Success(courseId: processedCourseId, sectionIds: processedSectionIds, color: processedCourseColor):
                            var (courseIds, sectionsIds, colorMap) = finalResult
                            courseIds.append(processedCourseId)
                            sectionsIds += processedSectionIds
                            colorMap[processedCourseId] = processedCourseColor
                            return (courseIds, sectionsIds, colorMap)
                        }
                    })
                    managedObjectContext.performBlockAndWait {
                        scheduleManagedObject.courseColorMap = colorMap
                        scheduleManagedObject.lastModified = NSDate()
                        scheduleManagedObject.enrolledCoursesIds = coursesIds
                        scheduleManagedObject.enrolledSectionsIds = sectionsIds
                        scheduleManagedObject.courseColorMap = colorMap
                    }
                    return .Success
                } else {
                    return .Error(.InvalidDictionary)
                }
            } else {
                return .Error(.InvalidManagedObject)
            }
        }
    }
    
    private enum EnrollmentProcessResult {
        case Failure
        case Success(courseId: String, sectionIds: [String], color: CourseColor)
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
        return array.map { dict in dict[lightDictionaryKey] as? String != nil && dict[darkDictionaryKey] as? String != nil && dict[colorIdDictionaryKey] != nil}.reduce(true) {$0 && $1}
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
                let colors = array.map { CourseColor(normalColorHexString: $0[lightDictionaryKey]! as! String, highlightedColorHexString: $0[darkDictionaryKey]! as! String, serverId: "\($0[colorIdDictionaryKey])") }
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
