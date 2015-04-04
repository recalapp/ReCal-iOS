//
//  Section.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData
import ReCalCommon

private let hashPrimeMultiplier = 65599
struct Section: Printable, ManagedObjectProxy, ServerObject {
    typealias ManagedObject = CDSection
    let type: SectionType
    let sectionName: String
    let sectionMeetings: [SectionMeeting]
    let serverId: String
    
    let managedObjectProxyId: ManagedObjectProxyId
    
    init(managedObject: CDSection) {
        self.sectionName = managedObject.name
        self.type = managedObject.sectionType
        self.sectionMeetings = managedObject.meetings.allObjects.map { SectionMeeting(managedObject: $0 as CDSectionMeeting) }.sorted { $0.hashValue < $1.hashValue }
        self.managedObjectProxyId = .Existing(managedObject.objectID)
        assert(managedObject.serverId != nil)
        self.serverId = managedObject.serverId
    }
    
    func commitToManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> ManagedObjectProxyCommitResult {
        // TODO proper implementation
        switch self.managedObjectProxyId {
        case .Existing(let objectId):
            return .Success(objectId)
        case .NewObject:
            return .Failure
        }
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
    
    func commitToManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> ManagedObjectProxyCommitResult {
        switch self.managedObjectProxyId {
        case .Existing(let objectId):
            var sectionMeetingOpt: CDSectionMeeting?
            var errorOpt: NSError?
            managedObjectContext.performBlockAndWait {
                sectionMeetingOpt = managedObjectContext.existingObjectWithID(objectId, error: &errorOpt) as? CDSectionMeeting
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
                return .Success(sectionMeeting.objectID)
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
    switch (lhs.managedObjectProxyId, rhs.managedObjectProxyId) {
    case let (.Existing(lhsId), .Existing(rhsId)):
        // shortcut, because sections are never modified
        return lhsId == rhsId
    default:
        break
    }
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