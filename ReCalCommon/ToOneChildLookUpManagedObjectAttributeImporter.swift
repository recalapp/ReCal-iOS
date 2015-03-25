//
//  ToOneChildLookUpManagedObjectAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 3/25/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import Foundation

import CoreData

public class ToOneChildLookUpManagedObjectAttributeImporter: ManagedObjectAttributeImporter {
    
    public let dictionaryKey: String
    public let attributeKey: String
    public let childEntityName: String
    public let childAttributeKey: String
    public let lookUpType: LookUpType
    
    public init(dictionaryKey: String, attributeKey: String, childEntityName: String, childAttributeKey: String, childAttributeLookUpType: LookUpType) {
        self.dictionaryKey = dictionaryKey
        self.attributeKey = attributeKey
        self.childEntityName = childEntityName
        self.childAttributeKey = childAttributeKey
        self.lookUpType = childAttributeLookUpType
        super.init()
    }
    
    public override func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> ManagedObjectAttributeImporter.ImportResult {
        if managedObject.entity.propertiesByName[self.attributeKey] == nil {
            println("Invalid managed object. Does not contain specified key: \(self.attributeKey)")
            return .Error(.InvalidManagedObject)
        }
        var childManagedObjectOpt: NSManagedObject?
        switch self.lookUpType {
        case .String:
            if let childLookUpValue: AnyObject = dict[self.dictionaryKey] {
                let fetchRequest = NSFetchRequest(entityName: self.childEntityName)
                let lookUpPredicate = NSPredicate(format: "\(self.childAttributeKey) = %@", argumentArray: ["\(childLookUpValue)"])
                fetchRequest.predicate = lookUpPredicate
                fetchRequest.fetchLimit = 1
                var fetched: [NSManagedObject]?
                var errorOpt: NSError?
                managedObjectContext.performBlockAndWait {
                    fetched = managedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt) as? [NSManagedObject]
                }
                if let error = errorOpt {
                    println("Error looking up child in importer. Error: \(error)")
                    return .Error(.InvalidManagedObject)
                }
                if let child = fetched?.first {
                    childManagedObjectOpt = child
                }
            } else {
                println("Dict does not have the specified key \(self.dictionaryKey)")
                return .Error(.InvalidDictionary)
            }
        }
        if let childManagedObject = childManagedObjectOpt {
            managedObjectContext.performBlockAndWait {
                managedObject.setValue(childManagedObject, forKey: self.childAttributeKey)
            }
        }
        return .Success
    }
    
    public enum LookUpType {
        case String
    }
}
