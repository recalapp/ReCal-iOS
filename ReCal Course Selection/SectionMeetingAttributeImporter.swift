//
//  SectionMeetingAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/19/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class SectionMeetingAttributeImporter: CompositeManagedObjectAttributeImporter {
    init() {
        let locationImporter = StringManagedObjectAttributeImporter(dictionaryKey: "location", attributeKey: "location")
        let daysImporter = StringManagedObjectAttributeImporter(dictionaryKey: "days", attributeKey: "daysStorage", stringProcessing: { $0.lowercaseString })
        let startTimeImporter = MeetingTimeAttributeImporter(dictionaryKey: "start_time", hourAttributeKey: "startHour", minuteAttributeKey: "startMinute")
        let endTimeImporter = MeetingTimeAttributeImporter(dictionaryKey: "end_time", hourAttributeKey: "endHour", minuteAttributeKey: "endMinute")
        super.init(attributeImporters: [locationImporter, daysImporter, startTimeImporter, endTimeImporter])
    }
    private class MeetingTimeAttributeImporter: ManagedObjectAttributeImporter {
        let dictionaryKey: String
        let hourAttributeKey: String
        let minuteAttributeKey: String
        init(dictionaryKey: String, hourAttributeKey: String, minuteAttributeKey: String) {
            self.dictionaryKey = dictionaryKey
            self.hourAttributeKey = hourAttributeKey
            self.minuteAttributeKey = minuteAttributeKey
        }
        
        private override func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> ManagedObjectAttributeImporter.ImportResult {
            let timeFormatter: NSDateFormatter = {
                let formatter = NSDateFormatter()
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
                return formatter
            }()
            let calendar: NSCalendar = {
                return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            }()
            let getTimeComponents:(String)->NSDateComponents = {(timeString) in
                let date = timeFormatter.dateFromString(timeString)!
                let components = calendar.components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: date)
                return components
            }
            if dict[self.dictionaryKey] == nil {
                return .Error(.InvalidDictionary)
            }
            let components = getTimeComponents(dict[self.dictionaryKey] as String)
            if managedObject.entity.attributesByName[self.hourAttributeKey] == nil || managedObject.entity.attributesByName[self.minuteAttributeKey] == nil {
                return .Error(.InvalidManagedObject)
            }
            managedObjectContext.performBlockAndWait {
                managedObject.setValue(components.hour, forKey: self.hourAttributeKey)
                managedObject.setValue(components.minute, forKey: self.minuteAttributeKey)
            }
            return .Success
        }
    }
}
