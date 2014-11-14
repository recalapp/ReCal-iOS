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
    override func processData(data: NSData, fromTemporaryFileName fileName: String) -> ImportResult {
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
                let processEnrolledCoursesDict: (Dictionary<String, AnyObject>)->(CDCourse?, ImportResult) = { (courseDict) in
                    let processSectionDict: (Dictionary<String, AnyObject>)->(CDSection?, ImportResult) = { (sectionDict) in
                        let sectionIdNumber: Int? = (sectionDict["section_id"] as? NSNumber)?.integerValue
                        if sectionIdNumber == nil {
                            return (nil, .Failure)
                        }
                        let getOrCreateEnrollment: (CDSection)->CDSectionEnrollment = { (section) in
                            for enrollment in user.enrollments {
                                if section.isEqual(enrollment.section) {
                                    return enrollment as CDSectionEnrollment
                                }
                            }
                            var enrollment: CDSectionEnrollment?
                            self.backgroundManagedObjectContext.performBlockAndWait{
                                enrollment = NSEntityDescription.insertNewObjectForEntityForName("CDSectionEnrollment", inManagedObjectContext: self.backgroundManagedObjectContext) as? CDSectionEnrollment
                                enrollment!.user = user
                                enrollment!.section = section
                            }
                            return enrollment!
                        }
                        let section = self.fetchOrCreateEntityWithServerId("\(sectionIdNumber)", entityName: "CDSection") as CDSection
                        let name = sectionDict["section_name"] as? String
                        let typeCode = (sectionDict["section_type_code"] as? String)?.lowercaseString
                        let colorCode = sectionDict["section_color"] as? String
                        if name == nil || typeCode == nil || colorCode == nil {
                            return (nil, .Failure)
                        }
                        let enrollment = getOrCreateEnrollment(section)
                        self.backgroundManagedObjectContext.performBlockAndWait {
                            section.sectionTitle = name!
                            section.sectionTypeCode = typeCode!
                            enrollment.color = UIColor.fromHexString(colorCode!)!
                        }
                        return (section, .Success)
                    }
                    let courseListingFromString: (String)->CDCourseListing = {(listingString) in
                        let components = listingString.componentsSeparatedByString(" ").filter { countElements($0) > 0 }
                        assert(components.count == 2)
                        var listing: CDCourseListing?
                        self.backgroundManagedObjectContext.performBlockAndWait {
                            listing = NSEntityDescription.insertNewObjectForEntityForName("CDCourseListing", inManagedObjectContext: self.backgroundManagedObjectContext) as? CDCourseListing
                            listing!.departmentCode = components[0]
                            listing!.courseNumber = components[1]
                        }
                        return listing!
                    }
                    let courseIdNumber: Int? = (courseDict["course_id"] as? NSNumber)?.integerValue
                    if courseIdNumber == nil {
                        return (nil, .Failure)
                    }
                    let course = self.fetchOrCreateEntityWithServerId("\(courseIdNumber)", entityName: "CDCourse") as CDCourse
                    let description = courseDict["course_description"] as? String
                    let title = courseDict["course_title"] as? String
                    let listings = (courseDict["course_listings"] as? String)?.componentsSeparatedByString("/")
                    let primaryListingString = courseDict["course_primary_listing"] as? String
                    let sectionDictArray = courseDict["sections"] as? [Dictionary<String, AnyObject>]
                    if description == nil || title == nil || listings == nil || primaryListingString == nil || sectionDictArray == nil {
                        return (nil, .Failure)
                    }
                    course.removeSections(course.sections) // TODO actually delete the sections, otherwise we might not pass validation (sections have no courses)
                    for sectionDict in sectionDictArray! {
                        switch processSectionDict(sectionDict) {
                        case (.Some(let section), .Success):
                            course.addSectionsObject(section)
                        default:
                            return (nil, .Failure)
                        }
                    }
                    course.courseTitle = title!
                    course.courseDescription = description!
                    for listing in course.courseListings {
                        self.backgroundManagedObjectContext.performBlockAndWait {
                            self.backgroundManagedObjectContext.deleteObject(listing as NSManagedObject)
                        }
                    }
                    course.addCourseListings(NSSet(array: listings!.map{ courseListingFromString($0) }))
                    let primaryListing = courseListingFromString(primaryListingString!)
                    primaryListing.isPrimary = NSNumber(bool: true)
                    course.addCourseListingsObject(primaryListing)
                    return (course, .Success)
                }
                let courseDictArray = profileDict["enrolled_courses"] as? [Dictionary<String, AnyObject>]
                let displayName = profileDict["display_name"] as? String
                if displayName == nil || courseDictArray == nil {
                    revertChanges()
                    return .Failure
                }
                user.displayName = displayName!
                user.removeEnrollments(user.enrollments)
                for courseDict in courseDictArray! {
                    switch processEnrolledCoursesDict(courseDict) {
                    case (_, .Success):
                        break
                    case (_, .Failure):
                        revertChanges()
                        return .Failure
                    case (_, .ShouldRetry):
                        revertChanges()
                        return .ShouldRetry
                    }
                }
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
        return .Success
    }
    struct TemporaryFileNames {
        static let userProfile = "userProfile"
        static let events = "events"
    }
}