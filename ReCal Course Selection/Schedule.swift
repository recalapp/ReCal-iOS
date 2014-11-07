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
    let managedObjectProxyId: ManagedObjectProxyId
    let name: String
    let termCode: String
    var enrolledCourses: OrderedSet<Course>
    var courseSectionTypeEnrollments: Dictionary<Course, SectionTypeEnrollment>
    
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
        self.enrolledCourses = OrderedSet(initialValues: managedObject.enrolledCourses.array.map { Course(managedObject: $0 as CDCourse) } )
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
    }
    init(name: String, termCode: String) {
        self.managedObjectProxyId = .NewObject
        self.name = name
        self.termCode = termCode
        self.enrolledCourses = OrderedSet()
        self.courseSectionTypeEnrollments = Dictionary<Course, SectionTypeEnrollment>()
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
    }
    
    func commitToManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> ManagedObjectProxyCommitResult<ManagedObject> {
        let updateManagedObject = { (schedule: CDSchedule) -> ManagedObjectProxyCommitResult<CDSchedule> in
            schedule.removeEnrolledCourses(schedule.enrolledCourses)
            
            for course in self.enrolledCourses {
                
                switch course.managedObjectProxyId {
                case .Existing(let objectId):
                    var courseOpt: CDCourse?
                    managedObjectContext.performBlockAndWait {
                        courseOpt = managedObjectContext.objectWithID(objectId) as? CDCourse
                    }
                    if let course = courseOpt {
                        schedule.addEnrolledCoursesObject(course)
                    } else {
                        return .Failure
                    }
                case .NewObject:
                    return .Failure
                }
                // TODO swift compiler has a bug with this piece of code. Try again later
//                switch course.commitToManagedObjectContext(managedObjectContext) {
//                case .Success(let courseManagedObject):
//                    schedule.addEnrolledCoursesObject(courseManagedObject)
//                case .Failure:
//                    return .Failure
//                }
            }
            schedule.removeEnrolledSections(schedule.enrolledSections)
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
//                switch section.commitToManagedObjectContext(managedObjectContext) {
//                case .Success(let sectionManagedObject):
//                    schedule.addEnrolledSectionsObject(sectionManagedObject)
//                case .Failure:
//                    return .Failure
//                }
            }
            return .Success(schedule)
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
                return updateManagedObject(schedule)
            } else {
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
                schedule.name = self.name
                schedule.semester = self.semesterWithTermCode(self.termCode, inManagedObjectContext: managedObjectContext)
                return updateManagedObject(schedule)
            } else {
                return .Failure
            }
        }
    }
    
    private func semesterWithTermCode(termCode: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> CDSemester? {
        let fetchRequest = NSFetchRequest(entityName: "CDSemester")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "termCode = %@", termCode)
        var result: CDSemester?
        var error: NSError?
        managedObjectContext.performBlockAndWait {
            result = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)?.last as? CDSemester
        }
        return result
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