//
//  CoreDataImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

private struct Static {
    static var instance: CoreDataImporter?
    static var token: dispatch_once_t = 0
}

class CoreDataImporter {
    private let temporaryFileName = "temp"
    private let temporaryDirectory = "core_data_importer_temp"
    
    private var temporaryDirectoryPath: String? {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last?.stringByAppendingPathComponent(temporaryDirectory)
    }
    
    lazy private var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter
    }()
    
    lazy private var calendar: NSCalendar = {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    }()
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    lazy private var backgroundManagedObjectContext: NSManagedObjectContext = {
        assert(self.persistentStoreCoordinator != nil, "Persistent store coordinator must be set before Core Data Importer can be used")
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    class var defaultImporter: CoreDataImporter {
        // thread safe singleton implementation. Taken from http://code.martinrue.com/posts/the-singleton-pattern-in-swift
        
        dispatch_once(&Static.token, {
            Static.instance = CoreDataImporter()
        })
        return Static.instance!
    }
    
    func writeJSONDataToPendingItemsDirectory(data: NSData) -> Bool {
        var errorOpt: NSError?
        let parsed: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &errorOpt)
        if let error = errorOpt {
            println("Error parsing json data. Aborting write. Error: \(error)")
            return false
        }
        let parsedData = NSKeyedArchiver.archivedDataWithRootObject(parsed!)
        let fileManager = NSFileManager.defaultManager()
        if let temporaryDirectoryPath = self.temporaryDirectoryPath {
            if !fileManager.fileExistsAtPath(temporaryDirectoryPath) {
                fileManager.createDirectoryAtPath(temporaryDirectoryPath, withIntermediateDirectories: false, attributes: nil, error: &errorOpt)
                if let error = errorOpt {
                    println("Error creating temporary directory. Aborting. Error: \(error)")
                    return false
                }
            }
            let temporaryFilePath = temporaryDirectoryPath.stringByAppendingPathComponent(temporaryFileName)
            if fileManager.fileExistsAtPath(temporaryFilePath) {
                fileManager.removeItemAtPath(temporaryFilePath, error: &errorOpt)
                if let error = errorOpt {
                    println("Error deleting old temporary file. Aborting save. Error: \(error)")
                    return false
                }
            }
            return fileManager.createFileAtPath(temporaryFilePath, contents: parsedData, attributes: nil)
        } else {
            println("Error getting directory path. Aborting save.")
            return false
        }
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
    
    func importPendingItems() {
        
        let processData: (NSData)->Void = {(data) in
            let processSemesterDictionary: (Dictionary<String, AnyObject>)->CDSemester = {(semesterDict) in
                let semesterServerIdObject: AnyObject = semesterDict["id"]!
                let semesterServerId = "\(semesterServerIdObject)"
                let semester = self.fetchOrCreateEntityWithServerId(semesterServerId, entityName: "CDSemester") as CDSemester
                semester.termCode = semesterDict["term_code"]! as String
                return semester
            }
            let processSectionMeetingDictionary: (Dictionary<String, AnyObject>)->CDSectionMeeting = {(sectionMeetingDict) in
                let targetDays = (sectionMeetingDict["days"] as String).lowercaseString
                let getTimeComponents:(String)->NSDateComponents = {(timeString) in
                    let date = self.timeFormatter.dateFromString(timeString)!
                    let components = self.calendar.components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: date)
                    return components
                }
                let targetStartTime = getTimeComponents(sectionMeetingDict["start_time"] as String)
                let targetEndTime = getTimeComponents(sectionMeetingDict["end_time"] as String)
                let serverIdObject: AnyObject = sectionMeetingDict["id"]!
                let serverId = "\(serverIdObject)"
                let meeting = self.fetchOrCreateEntityWithServerId(serverId, entityName: "CDSectionMeeting") as CDSectionMeeting
                meeting.daysStorage = targetDays
                meeting.startHour = targetStartTime.hour
                meeting.startMinute = targetStartTime.minute
                meeting.endHour = targetEndTime.hour
                meeting.endMinute = targetEndTime.minute
                meeting.location = sectionMeetingDict["location"] as String
                return meeting
            }
            let processSectionDictionary: (Dictionary<String, AnyObject>)->CDSection = {(sectionDict) in
                let sectionServerIdObject: AnyObject = sectionDict["id"]!
                let sectionServerId = "\(sectionServerIdObject)"
                let section = self.fetchOrCreateEntityWithServerId(sectionServerId, entityName: "CDSection") as CDSection
                section.removeMeetings(section.meetings)
                for sectionMeetingDict in sectionDict["meetings"] as [Dictionary<String, AnyObject>] {
                    section.addMeetingsObject(processSectionMeetingDictionary(sectionMeetingDict))
                }
                section.name = sectionDict["name"] as String
                section.sectionTypeCode = (sectionDict["section_type"] as String).lowercaseString
                return section
            }
            let processCourseDictionary: (Dictionary<String, AnyObject>)->CDCourse = {(courseDict) in
                let courseServerIdObject: AnyObject = courseDict["id"]!
                let courseServerId = "\(courseServerIdObject)"
                let semester = processSemesterDictionary(courseDict["semester"] as Dictionary<String, AnyObject>)
                let course = self.fetchOrCreateEntityWithServerId(courseServerId, entityName: "CDCourse") as CDCourse
                
                // listings
                for oldListing in course.courseListings {
                    self.backgroundManagedObjectContext.performBlockAndWait {
                        self.backgroundManagedObjectContext.deleteObject(oldListing as NSManagedObject)
                    }
                }
                let processCourseListingDictionary: (Dictionary<String, AnyObject>)->CDCourseListing = {(courseListingDict) in
                    let targetCourseNumber = courseListingDict["number"] as String
                    let targetDepartmentCode = courseListingDict["dept"] as String
                    var listing: CDCourseListing?
                    self.backgroundManagedObjectContext.performBlockAndWait {
                        listing = NSEntityDescription.insertNewObjectForEntityForName("CDCourseListing", inManagedObjectContext: self.backgroundManagedObjectContext) as? CDCourseListing
                    }
                    listing?.isPrimary = courseListingDict["is_primary"] as NSNumber
                    listing?.departmentCode = targetDepartmentCode
                    listing?.courseNumber = targetCourseNumber
                    return listing!
                }
                for courseListingDict in courseDict["course_listings"] as [Dictionary<String, AnyObject>] {
                    course.addCourseListingsObject(processCourseListingDictionary(courseListingDict))
                }
                
                // sections
                course.removeSections(course.sections)
                for sectionDict in courseDict["sections"] as [Dictionary<String, AnyObject>] {
                    course.addSectionsObject(processSectionDictionary(sectionDict))
                }
                
                // other course info
                course.title = courseDict["title"] as String
                course.courseDescription = courseDict["description"] as String
                semester.addCoursesObject(course)
                return course
            }
            if let downloadedDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Dictionary<String, AnyObject> {
                for courseDict in downloadedDict["objects"] as [Dictionary<String, AnyObject>] {
                    processCourseDictionary(courseDict)
                    // TODO remove courses not found here
                }
            }
        }
        if let temporaryFilePath = self.temporaryDirectoryPath?.stringByAppendingPathComponent(temporaryFileName) {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(temporaryFilePath) {
                let dataOpt = NSData(contentsOfFile: temporaryFilePath)
                var errorOpt: NSError?
                fileManager.removeItemAtPath(temporaryFilePath, error: &errorOpt)
                if let error = errorOpt {
                    println("Error deleting old temporary file. Aborting save. Error: \(error)")
                    return
                }
                if let data = dataOpt {
                    processData(data)
                    println("Inserted \(self.backgroundManagedObjectContext.insertedObjects.count)")
                    println("Updated \(self.backgroundManagedObjectContext.updatedObjects.count)")
                    println("Deleted \(self.backgroundManagedObjectContext.deletedObjects.count)")
                    self.backgroundManagedObjectContext.performBlockAndWait {
                        self.backgroundManagedObjectContext.save(&errorOpt)
                        if let error = errorOpt {
                            println("Error saving. Aborting. Error: \(error)")
                        }
                    }
                }
            }
        }
    }
}