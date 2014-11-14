//
//  DateManagedObjectAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/14/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData

public class DateManagedObjectAttributeImporter: ManagedObjectAttributeImporter {
    
    public let dictionaryKey: String
    
    public let attributeKey: String
    
    public init(dictionaryKey: String, attributeKey: String) {
        self.dictionaryKey = dictionaryKey
        self.attributeKey = attributeKey
    }
    
    override public func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> ManagedObjectAttributeImporter.ImportResult {
        let value = (dict[self.dictionaryKey] as? String)?.toInt()
        if value == nil {
            println("Invalid dictionary. Does not contain specified key: \(self.dictionaryKey)")
            return .Error(.InvalidDictionary)
        }
        if managedObject.entity.attributesByName[self.attributeKey] == nil {
            println("Invalid managed object. Does not contain specified key: \(self.attributeKey)")
            return .Error(.InvalidManagedObject)
        }
        let processed = NSDate(timeIntervalSince1970: Double(value!))
        managedObjectContext.performBlockAndWait {
            managedObject.setValue(processed, forKey: self.attributeKey)
        }
        return .Success
    }
}