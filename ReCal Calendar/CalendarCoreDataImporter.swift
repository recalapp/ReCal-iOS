//
//  CalendarCoreDataImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/12/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData
import ReCalCommon

class CalendarCoreDataImporter: CoreDataImporter {
    override var temporaryFileNames: [String] {
        return [TemporaryFileNames.userProfile, TemporaryFileNames.events]
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
    private func fetchOrCreateUserEntityWithUsername(username: String) -> CDUser {
        var errorOpt: NSError?
        let fetchRequest = NSFetchRequest(entityName: "CDUser")
        let usernamePredicate = NSPredicate(format: "username LIKE[c] %@", argumentArray: [username])
        fetchRequest.predicate = usernamePredicate
        fetchRequest.fetchLimit = 1
        var managedObject: CDUser?
        self.backgroundManagedObjectContext.performBlockAndWait {
            let fetched = self.backgroundManagedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt)
            if let error = errorOpt {
                println("Error fetching for user with username: \(username). Error: \(error)")
                abort()
            }
            if let last = fetched?.last as? CDUser {
                managedObject = last
            }
        }
        if managedObject == nil {
            // must create, as it does not exist
            self.backgroundManagedObjectContext.performBlockAndWait{
                managedObject = NSEntityDescription.insertNewObjectForEntityForName("CDUser", inManagedObjectContext: self.backgroundManagedObjectContext) as? CDUser
                if managedObject == nil {
                    println("Error creating for user with username: \(username).")
                    abort()
                }
                managedObject!.username = username
            }
        }
        return managedObject!
    }
    override func processData(data: NSData, fromTemporaryFileName fileName: String, withProgress: NSProgress) -> CoreDataImporter.ImportResult {
        switch fileName {
        case TemporaryFileNames.userProfile:
            return self.processUserProfileData(data)
        case TemporaryFileNames.events:
            return self.processEventsData(data)
        default:
            assertionFailure("Unsupported file name: \(fileName)")
            return .Failure
        }
    }
    private func processUserProfileData(data: NSData) -> ImportResult {
        let revertChanges: ()->Void = {
            self.backgroundManagedObjectContext.performBlockAndWait {
                self.backgroundManagedObjectContext.reset()
            }
        }
        if let profileDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Dictionary<String, AnyObject> {
            if let username = profileDict["username"] as? String {
                println("Saving user profiles for username: \(username)")
                let user = self.fetchOrCreateUserEntityWithUsername(username)
                let courseAttributeImporter = CourseAttributeImporter(userObjectId: user.objectID)
                let processEnrolledCoursesDict: (Dictionary<String, AnyObject>)->ImportResult = { (courseDict) in
                    let serverIdValue = (courseDict["course_id"] as? NSNumber)?.integerValue
                    if serverIdValue == nil {
                        return .Failure
                    }
                    let course = self.fetchOrCreateEntityWithServerId("\(serverIdValue!)", entityName: "CDCourse")
                    switch courseAttributeImporter.importAttributeFromDictionary(courseDict, intoManagedObject: course, inManagedObjectContext: self.backgroundManagedObjectContext) {
                    case .Success:
                        return .Success
                    case .Error(.IncompleteLocalData):
                        return .ShouldRetry
                    case .Error(_):
                        return .Failure
                    }
                }
                let courseDictArray = profileDict["enrolled_courses"] as? [Dictionary<String, AnyObject>]
                let displayName = profileDict["display_name"] as? String
                if displayName == nil || courseDictArray == nil {
                    revertChanges()
                    return .Failure
                }
                user.displayName = displayName!
                user.removeEnrollments(user.enrollments)
                let result = courseDictArray!.map { processEnrolledCoursesDict($0) }.reduce(ImportResult.Success, combine: { (prevResult, result) in
                    switch prevResult {
                    case .Success:
                        return result
                    case .ShouldRetry:
                        if result == .Failure {
                            return .Failure
                        } else {
                            return .ShouldRetry
                        }
                    case .Failure:
                        return .Failure
                    }
                })
                switch result {
                case .Success:
                    var success = true
                    self.backgroundManagedObjectContext.performBlockAndWait {
                        var errorOpt: NSError?
                        println("Inserted item count: \(self.backgroundManagedObjectContext.insertedObjects.count)")
                        println("Updated item count: \(self.backgroundManagedObjectContext.updatedObjects.count)")
                        println("Deleted item count: \(self.backgroundManagedObjectContext.deletedObjects.count)")
                        self.backgroundManagedObjectContext.persistentStoreCoordinator!.lock()
                        success = self.backgroundManagedObjectContext.save(&errorOpt)
                        self.backgroundManagedObjectContext.persistentStoreCoordinator!.unlock()
                        if let error = errorOpt {
                            println("Error saving. Error: \(error)")
                        }
                    }
                    if success {
                        return .Success
                    } else {
                        return .Failure
                    }
                case .ShouldRetry:
                    revertChanges()
                    return .ShouldRetry
                case .Failure:
                    revertChanges()
                    return .Failure
                }
                
            } else {
                return .Failure
            }
        } else {
            return .Failure
        }
    }
    private func processEventsData(data: NSData) -> ImportResult {
        let revertChanges: ()->Void = {
            self.backgroundManagedObjectContext.performBlockAndWait {
                self.backgroundManagedObjectContext.reset()
            }
        }
        if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Dictionary<String, AnyObject> {
            if let eventsDictArray = dict["events"] as? [Dictionary<String, AnyObject>] {
                println("Importing events data")
                let eventImporter = EventAttributeImporter()
                let processEventDict: (Dictionary<String, AnyObject>)->ImportResult = { (eventDict) in
                    let serverIdValue = (eventDict["event_id"] as? NSNumber)?.integerValue
                    if serverIdValue == nil {
                        return .Failure
                    }
                    let event = self.fetchOrCreateEntityWithServerId("\(serverIdValue!)", entityName: "CDEvent")
                    switch eventImporter.importAttributeFromDictionary(eventDict, intoManagedObject: event, inManagedObjectContext: self.backgroundManagedObjectContext) {
                    case .Success:
                        return .Success
                    case .Error(.IncompleteLocalData):
                        return .ShouldRetry
                    case .Error(_):
                        return .Failure
                    }
                }
                
                let result = eventsDictArray.map(processEventDict).reduce(ImportResult.Success, combine: { (prevResult, result) in
                    switch prevResult {
                    case .Success:
                        return result
                    case .ShouldRetry:
                        if result == .Failure {
                            return .Failure
                        } else {
                            return .ShouldRetry
                        }
                    case .Failure:
                        return .Failure
                    }
                })
                switch result {
                case .Success:
                    var success = true
                    self.backgroundManagedObjectContext.performBlockAndWait {
                        var errorOpt: NSError?
                        println("Inserted item count: \(self.backgroundManagedObjectContext.insertedObjects.count)")
                        println("Updated item count: \(self.backgroundManagedObjectContext.updatedObjects.count)")
                        println("Deleted item count: \(self.backgroundManagedObjectContext.deletedObjects.count)")
                        success = self.backgroundManagedObjectContext.save(&errorOpt)
                        if let error = errorOpt {
                            println("Error saving. Error: \(error)")
                        }
                    }
                    if success {
                        return .Success
                    } else {
                        println("failure saving")
                        return .Failure
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
    struct TemporaryFileNames {
        static let userProfile = "userProfile"
        static let events = "events"
    }
}

