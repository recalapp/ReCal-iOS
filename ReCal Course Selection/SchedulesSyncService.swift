//
//  SchedulesSyncService.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 3/30/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class SchedulesSyncService {
    let serverCommunicator: ServerCommunicator
    
    lazy private var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as AppDelegate).persistentStoreCoordinator
        return managedObjectContext
        }()
    
    private let modifiedScheduleFetchRequest: NSFetchRequest = {
        let fetchRequest = NSFetchRequest(entityName: "CDSchedule")
        fetchRequest.predicate = NSPredicate(format: "modified = 1")
        return fetchRequest
    }()
    
    private var notificationObservers: [AnyObject] = []
    
    init(serverCommunicator: ServerCommunicator) {
        self.serverCommunicator = serverCommunicator
        self.serverCommunicator.performBlockAndWait {
            self.serverCommunicator.registerServerCommunication(AllSchedulesServerCommunication())
        }
        let observer = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            if self.managedObjectContext.isEqual(notification.object) {
                return
            }
            self.managedObjectContext.performBlockAndWait {
                self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            }
            self.pushModifiedSchedules()
        }
        self.notificationObservers.append(observer)
    }
    
    deinit {
        self.notificationObservers.map { NSNotificationCenter.defaultCenter().removeObserver($0) }
    }
    
    private func pushModifiedSchedules() {
        let fetched = self.fetchModifiedSchedules()
        let modifiedSchedules = fetched.filter { !$0.isNew.boolValue }
        let newSchedules = fetched.filter { $0.isNew.boolValue }
        let modifiedScheduleServerCommunications = modifiedSchedules.map { ScheduleDeserializer(schedule: $0).deserialize() }.filter {
            (dict: [String:String]?) in if let _ = dict { return true } else { return false }
            }.map { $0! }.map { (dict: [String:String]) in ModifiedSchedulesServerCommunication(scheduleDictionary: dict, scheduleId: dict["id"]?.toInt() ?? 0, managedObjectContext: self.managedObjectContext) }
        let newScheduleServerCommunications = newSchedules.map {
            if let dict = ScheduleDeserializer(schedule: $0).deserialize() {
                return NewScheduleServerCommunication(scheduleDictionary: dict, managedObject: $0, managedObjectContext: self.managedObjectContext)
            } else {
                return nil
            }
        }.filter { (comm: NewScheduleServerCommunication?) in if let _ = comm { return true } else { return false } }.map { $0! }
        
        fetched.map { (schedule) in
            schedule.modifiedLogicalValue = .Uploading
        }
        var errorOpt: NSError?
        self.managedObjectContext.performBlock {
            self.managedObjectContext.persistentStoreCoordinator!.lock()
            self.managedObjectContext.save(&errorOpt)
            self.managedObjectContext.persistentStoreCoordinator!.unlock()
        }
        if let error = errorOpt {
            println("Error marking item as uploading. Error: \(error)")
            return
        }
        
        for communication in modifiedScheduleServerCommunications {
            self.serverCommunicator.performBlockAndWait {
                self.serverCommunicator.registerServerCommunication(communication)
            }
        }
        for communication in newScheduleServerCommunications {
            self.serverCommunicator.performBlockAndWait {
                self.serverCommunicator.registerServerCommunication(communication)
            }
        }
    }
    private func pullSchedules() {
        self.serverCommunicator.performBlockAndWait {
            let _ = self.serverCommunicator.startServerCommunicationWithIdentifier(AllSchedulesServerCommunication.identifier())
        }
    }
    
    private func fetchModifiedSchedules() -> [CDSchedule] {
        var fetched: [CDSchedule]?
        var error: NSError?
        
        managedObjectContext.performBlockAndWait {
            fetched = self.managedObjectContext.executeFetchRequest(self.modifiedScheduleFetchRequest, error: &error) as? [CDSchedule]
        }
        return fetched ?? []
    }
    
    func sync() {
        self.pushModifiedSchedules()
        self.pullSchedules()
    }
    
    private class ScheduleDeserializer {
        private let schedule: CDSchedule
        private var managedObjectContext: NSManagedObjectContext {
            assert(schedule.managedObjectContext != nil)
            return schedule.managedObjectContext!
        }
        private var colorMap: [String: CourseColor] {
            return schedule.courseColorMap as [String:CourseColor]
        }
        private let sectionIds: Set<String>
        
        init(schedule: CDSchedule) {
            self.schedule = schedule
            self.sectionIds = Set(initialItems: self.schedule.enrolledSectionsIds as [String])
        }
        
        private func deserializeCourseColor(color: CourseColor)->[String:AnyObject] {
            return [
                "light": "#\(color.normalColorRepresentation.rgbHexString)",
                "dark": "#\(color.highlightedColorRepresentation.rgbHexString)",
                "id": color.serverId.toInt() ?? 0
            ]
        }
        
        private func deserializeCourse(courseId: String) -> [String:AnyObject]? {
            if let courseObject = tryGetManagedObjectObject(managedObjectContext: self.managedObjectContext, entityName: "CDCourse", attributeName: "serverId", attributeValue: courseId) as? CDCourse {
                let sections: [Int] = (courseObject.sections.allObjects as? [CDSection])?.map {$0.serverId}.filter { self.sectionIds.contains($0) }.map { $0.toInt() ?? 0 } ?? []
                if self.colorMap[courseId] == nil {
                    return nil
                }
                let color = self.deserializeCourseColor(self.colorMap[courseId]!)
                return [
                    "course_id": courseId.toInt() ?? 0,
                    "color": color,
                    "sections": sections
                ]
            } else {
                return nil
            }
        }
        
        func deserialize() -> [String:String]? {
            if let user = Settings.currentSettings.authenticator.user {
                let colors = (self.schedule.availableColors as? [CourseColor])?.map { self.deserializeCourseColor($0) }
                if colors == nil {
                    return nil
                }
                let colorsString = Json.serializeToString(colors!)
                if colorsString == nil {
                    return nil
                }
                let courseArray: [[String:AnyObject]]? = (self.schedule.enrolledCoursesIds as? [String])?.map(self.deserializeCourse).filter { $0 != nil }.map { $0! }
                if courseArray == nil {
                    return nil
                }
                let courseString = Json.serializeToString(courseArray!)
                if courseString == nil {
                    return nil
                }
                if self.schedule.isNew.boolValue {
                    return [
                        "title": self.schedule.name,
                        "semester": "/api/v1/semester/\(self.schedule.semester.serverId)/",
                        "available_colors": colorsString!,
                        "enrollments": courseString!,
                        "user": "/api/v1/user/\(user.userId)/"
                    ]
                } else {
                    return [
                        "title": self.schedule.name,
                        "id": self.schedule.serverId,
                        "semester": "/api/v1/semester/\(self.schedule.semester.serverId)/",
                        "available_colors": colorsString!,
                        "enrollments": courseString!,
                        "user": "/api/v1/user/\(user.userId)/"
                    ]
                }
            }
            return nil
        }
    }
}