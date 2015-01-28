//
//  Schedule.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

private let hashPrimeMultiplier = 524287

struct Schedule : ManagedObjectProxy {
    typealias ManagedObject = CDSchedule
    private typealias SectionTypeEnrollmentDictionary = Dictionary<SectionType, SectionEnrollmentStatus>
    private(set) internal var managedObjectProxyId: ManagedObjectProxyId
    let name: String
    let termCode: String
    var enrolledCourses: Set<Course>
    var courseSectionTypeEnrollments: Dictionary<Course, SectionTypeEnrollment>
    var courseColorMap: Dictionary<Course, CourseColor>
    private let colorManager: CourseColorManager
    
    var enrolledSections: [Section] {
        let sectionTypeEnrollments = self.courseSectionTypeEnrollments.values.array
        let nested = sectionTypeEnrollments.map { (sectionTypeEnrollment: SectionTypeEnrollment) -> [Section?] in
            sectionTypeEnrollment.values.array.map { (status: SectionEnrollmentStatus) -> Section? in
                switch status {
                case .Unenrolled:
                    return nil
                case .Enrolled(let section):
                    return section
                }
            }
        }
        return arrayFlatten(nested).reduce([], combine: {(list, sectionOpt) in
            if let section = sectionOpt {
                return list + [section]
            } else {
                return list
            }
        })
    }
    init(managedObject: CDSchedule) {
        self.managedObjectProxyId = .Existing(managedObject.objectID)
        self.name = managedObject.name
        self.termCode = managedObject.semester.termCode
        let enrolledCourses: [Course] = managedObject.enrolledCourses.allObjects.map { $0 as CDCourse }.map { Course(managedObject: $0) }
        self.enrolledCourses = Set(initialItems: enrolledCourses)
        self.courseSectionTypeEnrollments = Dictionary<Course, SectionTypeEnrollment>()
        for course in self.enrolledCourses {
            var sectionTypeEnrollment = SectionTypeEnrollment()
            let courseId: NSManagedObjectID? = {
                switch course.managedObjectProxyId {
                case .Existing(let objectId):
                    return objectId
                case .NewObject:
                    return nil
                }
            }()
            for sectionType in course.allSectionTypes {
                var sectionOpt = (managedObject.enrolledSections.allObjects as [CDSection]).filter { $0.course.objectID == courseId && $0.sectionType == sectionType }.last
                if let section = sectionOpt {
                    sectionTypeEnrollment[sectionType] = .Enrolled(Section(managedObject: section))
                } else {
                    sectionTypeEnrollment[sectionType] = .Unenrolled
                }
            }
            self.courseSectionTypeEnrollments[course] = sectionTypeEnrollment
        }
        let colorMapRepresentation = managedObject.courseColorMap as Dictionary<NSURL,CourseColor>
        self.courseColorMap = Dictionary()
        for (idUrl, color) in colorMapRepresentation {
            let courseOpt = self.enrolledCourses.toArray().filter { (course) in
                switch course.managedObjectProxyId {
                case .NewObject:
                    return false
                case .Existing(let id):
                    return id.URIRepresentation().isEqual(idUrl)
                }
            }.last
            if let course = courseOpt {
                self.courseColorMap[course] = color
            }
        }
        let courseColorMap = self.courseColorMap
        let availableColors: [CourseColor] = (managedObject.availableColors as? [CourseColor]) ?? {
            var colors = Set<CourseColor>()
            for (_, color) in courseColorMap {
                colors.add(color)
            }
            return colors.toArray()
        }()
        self.colorManager = CourseColorManager(availableColors: availableColors, occurrences: self.courseColorMap.values.array)
        self.updateCourseColorMap()
        assert(self.checkInvariants())
    }
    init(name: String, termCode: String) {
        self.managedObjectProxyId = .NewObject
        self.name = name
        self.termCode = termCode
        self.enrolledCourses = Set()
        self.courseSectionTypeEnrollments = Dictionary<Course, SectionTypeEnrollment>()
        self.courseColorMap = Dictionary()
        self.colorManager = CourseColorManager(availableColors: Settings.currentSettings.availableColors)
        assert(self.checkInvariants())
    }
    
    mutating func updateCourseSectionTypeEnrollments() {
        for course in self.courseSectionTypeEnrollments.keys {
            if !self.enrolledCourses.contains(course) {
                self.courseSectionTypeEnrollments.removeValueForKey(course)
            }
        }
        for course in self.enrolledCourses {
            if self.courseSectionTypeEnrollments[course] == nil {
                var sectionTypeEnrollment = SectionTypeEnrollment()
                for sectionType in course.allSectionTypes {
                    let sectionsForType = course.sections.filter { $0.type == sectionType }
                    if sectionsForType.count == 1 {
                        sectionTypeEnrollment[sectionType] = .Enrolled(sectionsForType[0])
                    } else {
                        sectionTypeEnrollment[sectionType] = .Unenrolled
                    }
                }
                self.courseSectionTypeEnrollments[course] = sectionTypeEnrollment
            }
        }
        assert(self.checkInvariants())
    }
    
    mutating func updateCourseColorMap() {
        for course in self.enrolledCourses {
            if self.courseColorMap[course] == nil {
                self.courseColorMap[course] = self.colorManager.getNextColor()
            }
        }
        assert(self.checkInvariants())
    }
    
    mutating func updateColorUsageForDeletedCourse(course: Course) {
        assert(self.courseColorMap[course] != nil)
        let color = self.courseColorMap[course]!
        self.courseColorMap.removeValueForKey(course)
        self.colorManager.decrementColorOccurrence(color)
        assert(self.checkInvariants())
    }
    
    mutating func commitToManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> ManagedObjectProxyCommitResult {
        let updateManagedObject = { (schedule: CDSchedule) -> ManagedObjectProxyCommitResult in
            for course in schedule.enrolledCourses.allObjects {
                schedule.removeEnrolledCoursesObject(course as CDCourse)
            }
            for course in self.enrolledCourses {
                switch course.commitToManagedObjectContext(managedObjectContext) {
                case .Success(let objectId):
                    var courseOpt: CDCourse?
                    managedObjectContext.performBlockAndWait {
                        courseOpt = managedObjectContext.objectWithID(objectId) as? CDCourse
                    }
                    if let courseManagedObject: CDCourse = courseOpt {
                        schedule.addEnrolledCoursesObject(courseManagedObject)
                    } else {
                        return .Failure
                    }
                case .Failure:
                    return .Failure
                }
            }
            var colorMapRepresentation = Dictionary<NSURL, CourseColor>()
            for (course, color) in self.courseColorMap {
                switch course.managedObjectProxyId {
                case .NewObject:
                    break
                case .Existing(let id):
                    colorMapRepresentation[id.URIRepresentation()] = color
                }
            }
            schedule.courseColorMap = colorMapRepresentation
            schedule.availableColors = self.colorManager.availableColors
            schedule.removeEnrolledSections(schedule.enrolledSections)
            schedule.modified = true
            schedule.lastModified = NSDate()
            for section in self.enrolledSections {
                switch section.managedObjectProxyId {
                case .Existing(let objectId):
                    var sectionOpt: CDSection?
                    managedObjectContext.performBlockAndWait {
                        sectionOpt = managedObjectContext.objectWithID(objectId) as? CDSection
                    }
                    if let section = sectionOpt {
                        schedule.addEnrolledSectionsObject(section)
                    } else {
                        return .Failure
                    }
                case .NewObject:
                    return .Failure
                }
                switch section.commitToManagedObjectContext(managedObjectContext) {
                case .Success(let objectId):
                    managedObjectContext.performBlockAndWait {
                        schedule.addEnrolledSectionsObject(managedObjectContext.objectWithID(objectId) as CDSection)
                    }
                case .Failure:
                    return .Failure
                }
            }
            self.managedObjectProxyId = .Existing(schedule.objectID)
            return .Success(schedule.objectID)
        }
        switch self.managedObjectProxyId {
        case .Existing(let objectId):
            let managedObject: CDSchedule? = {
                var managedObject: CDSchedule?
                managedObjectContext.performBlockAndWait {
                    managedObject = managedObjectContext.objectWithID(objectId) as? CDSchedule
                }
                return managedObject
            }()
            if let schedule = managedObject {
                // NOTE assumes name and termcode doesn't change
                var result = ManagedObjectProxyCommitResult.Failure
                managedObjectContext.performBlockAndWait {
                    result = updateManagedObject(schedule)
                }
                assert(self.checkInvariants())
                return result
            } else {
                assert(self.checkInvariants())
                return .Failure
            }
        case .NewObject:
            let managedObject: CDSchedule? = {
                var managedObject: CDSchedule?
                managedObjectContext.performBlockAndWait {
                    managedObject = NSEntityDescription.insertNewObjectForEntityForName("CDSchedule", inManagedObjectContext: managedObjectContext) as? CDSchedule
                }
                return managedObject
            }()
            if let schedule = managedObject {
                // NOTE assumes name and termcode doesn't change
                var result = ManagedObjectProxyCommitResult.Failure
                managedObjectContext.performBlockAndWait {
                    schedule.name = self.name
                    schedule.semester = self.semesterWithTermCode(self.termCode, inManagedObjectContext: managedObjectContext)
                    result = updateManagedObject(schedule)
                }
                assert(self.checkInvariants())
                return result
            } else {
                assert(self.checkInvariants())
                return .Failure
            }
        }
    }
    
    private func semesterWithTermCode(termCode: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> CDSemester? {
        let fetchRequest = NSFetchRequest(entityName: "CDSemester")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "termCode LIKE[c] %@", termCode)
        var fetched: [CDSemester]?
        var error: NSError?
        managedObjectContext.performBlockAndWait {
            fetched = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [CDSemester]
        }
        return fetched?.last
    }
    
    var hashValue: Int {
        var hash = self.managedObjectProxyId.hashValue
        hash = hash &* hashPrimeMultiplier &+ self.name.hashValue
        hash = hash &* hashPrimeMultiplier &+ self.termCode.hashValue
        for course in self.enrolledCourses {
            hash = hash &* hashPrimeMultiplier &+ course.hashValue
        }
        return hash
    }
    
    private func checkInvariants() -> Bool {
        let availableColors = self.colorManager.availableColors
        var frequency = Dictionary<CourseColor, Int>()
        for (course, color) in self.courseColorMap {
            if !self.enrolledCourses.contains(course) {
                return false
            }
            if !arrayContainsElement(array: availableColors, element: color) {
                return false
            }
            frequency[color] = (frequency[color] ?? 0) + 1
        }
        for (color, count) in frequency {
            if self.colorManager[color] != count {
                return false
            }
        }
        return true
    }
}

func == (lhs: Schedule, rhs: Schedule) -> Bool {
    if lhs.managedObjectProxyId != rhs.managedObjectProxyId {
        return false
    }
    if lhs.name != rhs.name {
        return false
    }
    if lhs.termCode != rhs.termCode {
        return false
    }
    if lhs.enrolledCourses != rhs.enrolledCourses {
        return false
    }
    // TODO handle section enrollment
    return true
}