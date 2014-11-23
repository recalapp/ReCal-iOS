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
    var enrolledCourses: OrderedSet<Course>
    var courseSectionTypeEnrollments: Dictionary<Course, SectionTypeEnrollment>
    var courseColorMap: Dictionary<Course, CourseColor>
    private let colorManager: CourseColorManager
    // TODO if we get these valeus from the web, must deal with inaccuracy of float when comparing
    private let availableColors = [
        CourseColor(normalColor: UIColor(red: 0.745, green: 0.906, blue: 0.651, alpha: 1), highlightedColor: UIColor(red: 0.494, green: 0.812, blue: 0.318, alpha: 1)),
        CourseColor(normalColor: UIColor(red: 0.647, green: 0.769, blue: 0.945, alpha: 1), highlightedColor: UIColor(red: 0.298, green: 0.533, blue: 0.894, alpha: 1)),
        CourseColor(normalColor: UIColor.fromHexString("bdd7ed")!, highlightedColor: UIColor.fromHexString("a0c6e6")!),
        CourseColor(normalColor: UIColor.fromHexString("fec583")!, highlightedColor: UIColor.fromHexString("fdac51")!),
        CourseColor(normalColor: UIColor.fromHexString("f87668")!, highlightedColor: UIColor.fromHexString("f53c2e")!),
        CourseColor(normalColor: UIColor.fromHexString("cebafd")!, highlightedColor: UIColor.fromHexString("b99dfc")!)
    ]
    
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
        let enrolledCourses: [CDCourse] = managedObject.enrolledCourses.allObjects.map { $0 as CDCourse }
        let enrolledCoursesOrder = managedObject.enrolledCoursesOrder as [NSURL]
        self.enrolledCourses = OrderedSet()
        for courseId in enrolledCoursesOrder {
            if let course = enrolledCourses.filter({ $0.objectID.URIRepresentation().isEqual(courseId) }).last {
                let course = Course(managedObject: course)
                if !self.enrolledCourses.contains(course) {
                    self.enrolledCourses.append(course)
                }
            }
        }
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
        self.colorManager = managedObject.courseColorManager as CourseColorManager
        self.updateCourseColorMap()
    }
    init(name: String, termCode: String) {
        self.managedObjectProxyId = .NewObject
        self.name = name
        self.termCode = termCode
        self.enrolledCourses = OrderedSet()
        self.courseSectionTypeEnrollments = Dictionary<Course, SectionTypeEnrollment>()
        self.courseColorMap = Dictionary()
        self.colorManager = CourseColorManager(availableColors: self.availableColors)
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
    
    mutating func updateCourseColorMap() {
        for course in self.enrolledCourses {
            if self.courseColorMap[course] == nil {
                self.courseColorMap[course] = self.colorManager.getNextColor()
            }
        }
    }
    
    mutating func updateColorUsageForDeletedCourse(course: Course) {
        assert(self.courseColorMap[course] != nil)
        let color = self.courseColorMap[course]!
        self.courseColorMap.removeValueForKey(course)
        self.colorManager.decrementColorOccurrence(color)
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
            let courseIdsOrdered: [NSManagedObjectID?] = self.enrolledCourses.toArray().map { (course) -> NSManagedObjectID? in
                switch course.managedObjectProxyId {
                case .Existing(let objectId):
                    return objectId
                case .NewObject:
                    return nil
                }
            }
            schedule.enrolledCoursesOrder = courseIdsOrdered.map { $0!.URIRepresentation() as AnyObject }
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
            schedule.courseColorManager = self.colorManager
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
                return result
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
                var result = ManagedObjectProxyCommitResult.Failure
                managedObjectContext.performBlockAndWait {
                    schedule.name = self.name
                    schedule.semester = self.semesterWithTermCode(self.termCode, inManagedObjectContext: managedObjectContext)
                    result = updateManagedObject(schedule)
                }
                return result
            } else {
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