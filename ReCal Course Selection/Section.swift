//
//  Section.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

private let hashPrimeMultiplier = 65599
struct Section: Printable, ManagedObjectProxy {
    typealias ManagedObject = CDSection
    let type: SectionType
    let sectionName: String
    let sectionMeetings: [SectionMeeting]
    
    let managedObjectProxyId: ManagedObjectProxyId
    
    init(managedObject: CDSection) {
        self.sectionName = managedObject.name
        self.type = managedObject.sectionType
        self.sectionMeetings = managedObject.meetings.allObjects.map { SectionMeeting(managedObject: $0 as CDSectionMeeting) }
        self.managedObjectProxyId = .Existing(managedObject.objectID)
    }
    
    func commitToManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> ManagedObjectProxyCommitResult<ManagedObject> {
        assertionFailure("Not implemented")
    }
    
    var displayText: String {
        return self.sectionName
    }
    var description: String {
        return self.displayText
    }
    var hashValue: Int {
        var hash = self.type.hashValue
        hash = hash &* hashPrimeMultiplier &+ self.sectionName.hashValue
        for meeting in self.sectionMeetings {
            hash = hash &* hashPrimeMultiplier &+ meeting.hashValue
        }
        return hash
    }
}

struct SectionMeeting: Hashable, ManagedObjectProxy {
    typealias ManagedObject = CDSectionMeeting
    let startTime: NSDateComponents
    let endTime: NSDateComponents
    let location: String
    let days: [Day]
    
    let managedObjectProxyId: ManagedObjectProxyId
    
    init(managedObject: CDSectionMeeting) {
        self.startTime = managedObject.startTime
        self.endTime = managedObject.endTime
        self.location = managedObject.location
        self.days = managedObject.days
        self.managedObjectProxyId = .Existing(managedObject.objectID)
    }
    
    func commitToManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> ManagedObjectProxyCommitResult<ManagedObject> {
        switch self.managedObjectProxyId {
        case .Existing(let objectId):
            var sectionMeetingOpt: CDSectionMeeting?
            managedObjectContext.performBlockAndWait {
                sectionMeetingOpt = managedObjectContext.objectWithID(objectId) as? CDSectionMeeting
            }
            if let sectionMeeting = sectionMeetingOpt {
                sectionMeeting.startHour = self.startTime.hour
                sectionMeeting.startMinute = self.startTime.minute
                sectionMeeting.endHour = self.endTime.hour
                sectionMeeting.endMinute = self.endTime.minute
                sectionMeeting.location = self.location
                sectionMeeting.daysStorage = self.days.reduce("", combine: { (dayString, day) in
                    dayString + " \(day.shortDayString)"
                })
                return .Success(sectionMeeting)
            }
            return .Failure
        case .NewObject:
            assertionFailure("Not implemented")
            return .Failure
        }
    }
    
    var hashValue: Int {
        var hash = self.location.hashValue
        hash = hash &* hashPrimeMultiplier &+ self.startTime.hashValue
        hash = hash &* hashPrimeMultiplier &+ self.endTime.hashValue
        for day in self.days {
            hash = hash &* hashPrimeMultiplier &+ day.hashValue
        }
        return hash
    }
}

func == (lhs: SectionMeeting, rhs: SectionMeeting) -> Bool {
    if !lhs.startTime.isEqual(rhs.startTime) {
        return false
    }
    if !lhs.endTime.isEqual(rhs.endTime) {
        return false
    }
    if !arraysContainSameElements(lhs.days, rhs.days) {
        return false
    }
    return true
}

func == (lhs: Section, rhs: Section) -> Bool {
    if lhs.type != rhs.type {
        return false
    }
    if lhs.sectionName != rhs.sectionName {
        return false
    }
    if !arraysContainSameElements(lhs.sectionMeetings, rhs.sectionMeetings) {
        return false
    }
    return true
}

enum SectionType: String {
    case Precept = "pre", Lecture = "lec", Drill = "dri", Class = "cla", Seminar = "sem", Studio = "stu", Film = "fil", Ear = "ear", Lab = "lab"
    
    var displayText: String {
        switch self {
        case .Precept:
            return "Precept"
        case .Lecture:
            return "Lecture"
        case .Drill:
            return "Drill"
        case .Class:
            return "Class"
        case .Seminar:
            return "Seminar"
        case .Studio:
            return "Studio"
        case .Film:
            return "Film"
        case .Ear:
            return "Ear Training"
        case .Lab:
            return "Lab"
        }
    }
}

enum Day: Int, Printable {
    init?(rawValue: Int) {
        switch rawValue {
        case Day.Monday.rawValue:
            self = .Monday
        case Day.Tuesday.rawValue:
            self = .Tuesday
        case Day.Wednesday.rawValue:
            self = .Wednesday
        case Day.Thursday.rawValue:
            self = .Thursday
        case Day.Friday.rawValue:
            self = .Friday
        case Day.Saturday.rawValue:
            self = .Saturday
        case Day.Sunday.rawValue:
            self = .Sunday
        default:
            return nil
        }
    }
    init?(dayString: String) {
        switch dayString.lowercaseString {
        case "monday", "mon", "mo", "m":
            self = .Monday
        case "tuesday", "tue", "tu", "t":
            self = .Tuesday
        case "wednesday", "wed", "w":
            self = .Wednesday
        case "thursday", "th":
            self = .Thursday
        case "friday", "fri", "fr", "f":
            self = .Friday
        case "saturday", "sat", "sa":
            self = .Saturday
        case "sunday", "sun", "su":
            self = .Sunday
        default:
            return nil
        }
    }
    case Monday = 0, Tuesday = 1, Wednesday = 2, Thursday = 3, Friday = 4, Saturday, Sunday
    var description: String {
        switch self {
        case .Monday:
            return "Monday"
        case .Tuesday:
            return "Tuesday"
        case .Wednesday:
            return "Wednesday"
        case .Thursday:
            return "Thursday"
        case .Friday:
            return "Friday"
        case .Saturday:
            return "Saturday"
        case .Sunday:
            return "Sunday"
        }
    }
    var shortDayString: String {
        switch self {
        case .Monday:
            return "m"
        case .Tuesday:
            return "t"
        case .Wednesday:
            return "w"
        case .Thursday:
            return "th"
        case .Friday:
            return "f"
        case .Saturday:
            return "sa"
        case .Sunday:
            return "su"
        }
    }
}