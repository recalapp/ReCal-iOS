//
//  EventAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/14/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData
import ReCalCommon

class EventAttributeImporter : CompositeManagedObjectAttributeImporter {
    init() {
        let titleAttributeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "event_title", attributeKey: "eventTitle")
        let descriptionAttributeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "event_description", attributeKey: "eventDescription")
        let typeCodeAttributeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "event_type", attributeKey: "eventTypeCode") { $0.lowercaseString }
        let eventStartAttributeImporter = DateManagedObjectAttributeImporter(dictionaryKey: "event_start", attributeKey: "eventStart")
        let eventEndAttributeImporter = DateManagedObjectAttributeImporter(dictionaryKey: "event_end", attributeKey: "eventEnd")
        super.init(attributeImporters: [titleAttributeImporter, descriptionAttributeImporter, typeCodeAttributeImporter, eventStartAttributeImporter, eventEndAttributeImporter])
    }
    
    override func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> ManagedObjectAttributeImporter.ImportResult {
        let result = super.importAttributeFromDictionary(dict, intoManagedObject: managedObject, inManagedObjectContext: managedObjectContext)
        switch result {
        case .Success:
            let serverId = (dict["section_id"] as? NSNumber)?.integerValue
            if serverId == nil {
                return .Error(.InvalidDictionary)
            }
            let section = CDServerObject.findServerObjectWithServerId("\(serverId)", withEntityName: "CDSection", inManagedObjectContext: managedObjectContext) as? CDSection
            if section == nil {
                return .Error(.IncompleteLocalData)
            }
            if let event = managedObject as? CDEvent {
                event.section = section
                return .Success
            } else {
                return .Error(.InvalidManagedObject)
            }
        case .Error(_):
            return result
        }
    }
}