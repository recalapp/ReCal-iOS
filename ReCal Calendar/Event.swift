//
//  Event.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/10/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData
import ReCalCommon

private let hashPrimeMultipler = 32771

struct Event: Hashable {
    let eventType: EventType
    let eventTitle: String
    let eventStart: NSDate
    let eventEnd: NSDate
    let eventLocation: String
    let managedObjectProxyId: ManagedObjectProxyId
    
    init(eventTitle: String, eventStart: NSDate, eventEnd: NSDate, eventLocation: String, eventType: EventType) {
        self.eventTitle = eventTitle
        self.eventStart = eventStart
        self.eventEnd = eventEnd
        self.eventLocation = eventLocation
        self.eventType = eventType
        self.managedObjectProxyId = .NewObject
    }
    
    var hashValue: Int {
        var hash = self.eventTitle.hashValue
        hash = hash &* hashPrimeMultipler &+ self.eventStart.hashValue
        hash = hash &* hashPrimeMultipler &+ self.eventEnd.hashValue
        hash = hash &* hashPrimeMultipler &+ self.eventLocation.hashValue
        hash = hash &* hashPrimeMultipler &+ self.eventType.hashValue
        hash = hash &* hashPrimeMultipler &+ self.managedObjectProxyId.hashValue
        return hash
    }
}

func == (lhs: Event, rhs: Event) -> Bool {
    if lhs.eventTitle != rhs.eventTitle {
        return false
    }
    if !lhs.eventStart.isEqualToDate(rhs.eventStart) {
        return false
    }
    if !lhs.eventEnd.isEqualToDate(rhs.eventEnd) {
        return false
    }
    if lhs.eventLocation != rhs.eventLocation {
        return false
    }
    if lhs.eventType != rhs.eventType {
        return false
    }
    if lhs.managedObjectProxyId != rhs.managedObjectProxyId {
        return false
    }
    return true
}

enum EventType: String {
    case Assignment = "as"
    case Exam = "ex"
    case Lab = "la"
    case Lecture = "le"
    case OfficeHours = "oh"
    case Precept = "pr"
    case Studio = "st"
}