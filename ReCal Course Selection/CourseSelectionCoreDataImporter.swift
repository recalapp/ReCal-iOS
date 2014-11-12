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
        return [TemporaryFileNames.courses]
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
            var meetings = NSMutableSet()
            for sectionMeetingDict in sectionDict["meetings"] as [Dictionary<String, AnyObject>] {
                meetings.addObject(processSectionMeetingDictionary(sectionMeetingDict))
            }
            section.addMeetings(meetings)
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
            course.removeCourseListings(course.courseListings)
            let listings = NSMutableSet()
            for courseListingDict in courseDict["course_listings"] as [Dictionary<String, AnyObject>] {
                listings.addObject(processCourseListingDictionary(courseListingDict))
            }
            course.addCourseListings(listings)
            
            // sections
            course.removeSections(course.sections)
            let sections = NSMutableSet()
            for sectionDict in courseDict["sections"] as [Dictionary<String, AnyObject>] {
                sections.addObject(processSectionDictionary(sectionDict))
            }
            course.addSections(sections)
            
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
            var errorOpt: NSError?
            self.backgroundManagedObjectContext.performBlockAndWait {
                let _ = self.backgroundManagedObjectContext.save(&errorOpt)
            }
            if let error = errorOpt {
                println("Error saving. Aborting. Error: \(error)")
                return .ShouldRetry
            } else {
                return .Success
            }
        } else {
            return .Failure
        }
    }
    
    override func processData(data: NSData, fromTemporaryFileName fileName: String) -> ImportResult {
        switch fileName {
        case TemporaryFileNames.courses:
            return self.processCoursesData(data)
        default:
            assertionFailure("Unsupported file")
            return .Failure
        }
    }
    struct TemporaryFileNames {
        static let courses = "courses"
    }
}