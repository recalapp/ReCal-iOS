//
//  CoreDataImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData
import ReCalCommon

class CourseSelectionCoreDataImporter : CoreDataImporter {
    
    lazy private var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter
    }()
    
    lazy private var calendar: NSCalendar = {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    }()
    
    override var temporaryFileNames: [String] {
        return [TemporaryFileNames.activeSemesters, TemporaryFileNames.courses]
    }
    
    private func fetchOrCreateEntityWithServerId(serverId: String, entityName: String) -> CDServerObject {
        var errorOpt: NSError?
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let serverIdPredicate = NSPredicate(format: "serverId = %@", argumentArray: [serverId])
        fetchRequest.predicate = serverIdPredicate
        fetchRequest.fetchLimit = 1
        var managedObject: CDServerObject?
        self.backgroundManagedObjectContext.performBlockAndWait {
            let fetched = self.backgroundManagedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt)
            if let error = errorOpt {
                println("Error fetching for entity name: \(entityName), with server id: \(serverId). Error: \(error)")
                abort()
            }
            //println("\(entityName) fetched \(fetched) for server id \(serverId)")
            if let last = fetched?.last as? CDServerObject {
                managedObject = last
            }
        }
        if managedObject == nil {
            // must create, as it does not exist
            self.backgroundManagedObjectContext.performBlockAndWait{
                managedObject = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self.backgroundManagedObjectContext) as? CDServerObject
                if managedObject == nil {
                    println("Error creating for entity name: \(entityName), with server id: \(serverId).")
                    abort()
                }
                managedObject!.serverId = serverId
            }
        }
        return managedObject!
    }
    
    private func processCoursesData(data: NSData) -> ImportResult {
        let revertChanges: ()->Void = {
            self.backgroundManagedObjectContext.performBlockAndWait {
                self.backgroundManagedObjectContext.reset()
            }
        }
        if let downloadedDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Dictionary<String, AnyObject> {
            if let courseDictArray = downloadedDict["objects"] as? [Dictionary<String, AnyObject>] {
                let courseImportOperationQueue = NSOperationQueue()
                courseImportOperationQueue.name = "Course Import"
                courseImportOperationQueue.qualityOfService = .UserInitiated
                courseImportOperationQueue.maxConcurrentOperationCount = 2
                let curQueue = NSOperationQueue.currentQueue()
                var result: ImportResult = .Success
                let courseImporter = CourseAttributeImporter()
                for courseDict in courseDictArray {
                    let courseImportOperation = CourseImportOperation(courseDictionary: courseDict, courseImporter: courseImporter, managedObjectContext: self.backgroundManagedObjectContext) { (newResult) -> Void in
                        let _ = curQueue?.addOperationWithBlock {
                            switch (result, newResult) {
                            case (.Success, .Success):
                                result = .Success
                            default:
                                result = .Failure
                                courseImportOperationQueue.cancelAllOperations()
                            }
                        }
                    }
                    courseImportOperationQueue.addOperation(courseImportOperation)
                }
                println("total: \(courseDictArray.count)")
                courseImportOperationQueue.waitUntilAllOperationsAreFinished()
                println("finished waiting")
                switch result {
                case .Success:
                    var errorOpt: NSError?
                    println("Inserted item count: \(self.backgroundManagedObjectContext.insertedObjects.count)")
                    println("Updated item count: \(self.backgroundManagedObjectContext.updatedObjects.count)")
                    println("Deleted item count: \(self.backgroundManagedObjectContext.deletedObjects.count)")
                    self.backgroundManagedObjectContext.performBlockAndWait {
                        let _ = self.backgroundManagedObjectContext.save(&errorOpt)
                    }
                    if let error = errorOpt {
                        println("Error saving. Aborting. Error: \(error)")
                        return .ShouldRetry
                    } else {
                        return .Success
                    }
                case .Failure, .ShouldRetry:
                    revertChanges()
                    return result
                }
            } else {
                return .Failure
            }
        } else {
            return .Failure
        }
    }
    
    private func processActiveSemestersData(data: NSData)->ImportResult {
        let revertChanges: ()->Void = {
            self.backgroundManagedObjectContext.performBlockAndWait {
                self.backgroundManagedObjectContext.reset()
            }
        }
        if let outerDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Dictionary<String, AnyObject> {
            let processSemesterDict: Dictionary<String, AnyObject> -> (CDSemester?, ImportResult) = { (dict) in
                let serverId: AnyObject? = dict["id"]
                if serverId == nil {
                    return (nil, .Failure)
                }
                let semester = self.fetchOrCreateEntityWithServerId("\(serverId)", entityName: "CDSemester") as CDSemester
                let termCode = dict["term_code"] as? String
                if termCode == nil {
                    return (nil, .Failure)
                }
                
                self.backgroundManagedObjectContext.performBlockAndWait {
                    semester.termCode = termCode!
                    semester.active = NSNumber(bool: true)
                }
                return (semester, .Success)
            }
            if let activeSemesterDictArray = outerDict["objects"] as? [Dictionary<String, AnyObject>] {
                println("Importing active semesters")
                let (result, semesters) = activeSemesterDictArray.map(processSemesterDict).reduce((.Success, []), combine: { (cumulativePair, currentPair) -> (ImportResult, [CDSemester]) in
                    let (cumulativeResult, semesters) = cumulativePair
                    let (semesterOpt, result) = currentPair
                    switch (cumulativeResult, result) {
                    case (.Success, .Success):
                        return (.Success, semesters + [semesterOpt!])
                    default:
                        return (.Failure, [])
                    }
                })
                let semestersSet = NSSet(array: semesters)
                switch result {
                case .Success:
                    var errorOpt: NSError?
                    let fetchRequest: NSFetchRequest = {
                        let fetchRequest = NSFetchRequest(entityName: "CDSemester")
                        fetchRequest.predicate = NSPredicate(format: "active = 1")
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "termCode", ascending: false)]
                        return fetchRequest
                    }()
                    var oldActive: [CDSemester]?
                    self.backgroundManagedObjectContext.performBlockAndWait {
                        oldActive = self.backgroundManagedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt) as? [CDSemester]
                    }
                    if let error = errorOpt {
                        println("Error getting old active semesters. Error: \(error)")
                        return .ShouldRetry
                    }
                    oldActive = oldActive?.filter { !semestersSet.containsObject($0) }
                    for toChange in oldActive! {
                        self.backgroundManagedObjectContext.performBlockAndWait {
                            toChange.active = NSNumber(bool: false)
                        }
                    }
                    println("Inserted item count: \(self.backgroundManagedObjectContext.insertedObjects.count)")
                    println("Updated item count: \(self.backgroundManagedObjectContext.updatedObjects.count)")
                    println("Deleted item count: \(self.backgroundManagedObjectContext.deletedObjects.count)")
                    self.backgroundManagedObjectContext.performBlockAndWait {
                        let _ = self.backgroundManagedObjectContext.save(&errorOpt)
                    }
                    if let error = errorOpt {
                        println("Could not save active semesters. Error: \(error)")
                        return .ShouldRetry
                    } else {
                        return .Success
                    }
                case .Failure, .ShouldRetry:
                    revertChanges()
                    println("failure importing")
                    return result
                }
            } else {
                return .Failure
            }
        } else {
            return .Failure
        }
    }
    
    override func processData(data: NSData, fromTemporaryFileName fileName: String) -> ImportResult {
        switch fileName {
        case TemporaryFileNames.courses:
            return self.processCoursesData(data)
        case TemporaryFileNames.activeSemesters:
            return self.processActiveSemestersData(data)
        default:
            assertionFailure("Unsupported file")
            return .Failure
        }
    }
    struct TemporaryFileNames {
        static let activeSemesters = "activeSemesters"
        static let courses = "courses"
    }
}