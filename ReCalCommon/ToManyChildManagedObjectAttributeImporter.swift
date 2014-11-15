//
//  ToManyChildManagedObjectAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/14/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData

public class ToManyChildManagedObjectAttributeImporter: ManagedObjectAttributeImporter {
    
    public let dictionaryKey: String
    public let attributeKey: String
    public let childEntityName: String
    public let childAttributeImporter: ManagedObjectAttributeImporter
    public let childSearchPattern: ChildManagedObjectSearchPattern
    public let deleteMode: ChildManagedObjectDeleteMode
    
    public init(dictionaryKey: String, attributeKey: String, childEntityName: String, childAttributeImporter: ManagedObjectAttributeImporter, childSearchPattern: ChildManagedObjectSearchPattern, deleteMode: ChildManagedObjectDeleteMode = .Delete) {
        self.dictionaryKey = dictionaryKey
        self.attributeKey = attributeKey
        self.childEntityName = childEntityName
        self.childAttributeImporter = childAttributeImporter
        self.childSearchPattern = childSearchPattern
        self.deleteMode = deleteMode
        super.init()
    }
    
    public override func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> ManagedObjectAttributeImporter.ImportResult {
        let value = (dict[self.dictionaryKey] as? [Dictionary<String, AnyObject>])
        if value == nil {
            println("Invalid dictionary. Does not contain specified key: \(self.dictionaryKey)")
            return .Error(.InvalidDictionary)
        }
        if managedObject.entity.propertiesByName[self.attributeKey] == nil {
            println("Invalid managed object. Does not contain specified key: \(self.attributeKey)")
            return .Error(.InvalidManagedObject)
        }

        let childrenSet = managedObject.mutableSetValueForKey(self.attributeKey)
        switch self.childSearchPattern {
        case .NoSearch:
            switch self.deleteMode {
            case .Delete:
                childrenSet.removeAllObjects()
            case .NoDelete:
                break
            }
            for childDict in value! {
                var childManagedObject: NSManagedObject!
                managedObjectContext.performBlockAndWait {
                    childManagedObject = NSEntityDescription.insertNewObjectForEntityForName(self.childEntityName, inManagedObjectContext: managedObjectContext) as? NSManagedObject
                }
                if childManagedObject == nil {
                    return .Error(.InvalidManagedObject)
                }
                self.childAttributeImporter.importAttributeFromDictionary(childDict, intoManagedObject: childManagedObject, inManagedObjectContext: managedObjectContext)
                childrenSet.addObject(childManagedObject)
            }
        case .SearchStringEqual(let childDictionaryKey, let childAttributeKey):
            let deleteSet = NSMutableSet(set: childrenSet)
            for childDict in value! {
                var childManagedObject: NSManagedObject!
                let childValue: AnyObject! = childDict[childDictionaryKey]
                if childValue == nil {
                    println("Invalid child dictionary. Does not contain specified key: \(childDictionaryKey)")
                    return .Error(.InvalidDictionary)
                }
                let fetchRequest = NSFetchRequest(entityName: self.childEntityName)
                fetchRequest.predicate = NSPredicate(format: "\(childAttributeKey) == %@", "\(childValue)")
                var ret: ImportResult = .Success
                managedObjectContext.performBlockAndWait {
                    var error: NSError?
                    childManagedObject = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)?.last as? NSManagedObject
                    if childManagedObject == nil {
                        childManagedObject = NSEntityDescription.insertNewObjectForEntityForName(self.childEntityName, inManagedObjectContext: managedObjectContext) as? NSManagedObject
                        if childManagedObject.entity.propertiesByName[childAttributeKey] == nil {
                            ret = .Error(.InvalidManagedObject)
                            return
                        }
                        childManagedObject.setValue("\(childValue)", forKey: childAttributeKey)
                    }
                }
                
                switch ret {
                case .Success:
                    self.childAttributeImporter.importAttributeFromDictionary(childDict, intoManagedObject: childManagedObject, inManagedObjectContext: managedObjectContext)
                    childrenSet.addObject(childManagedObject)
                    
                    if deleteSet.containsObject(childManagedObject) {
                        deleteSet.removeObject(childManagedObject)
                    }
                case .Error(_):
                    return ret
                }
            }
            switch self.deleteMode {
            case .Delete:
                for toBeDeleted in deleteSet {
                    managedObjectContext.performBlockAndWait {
                        managedObjectContext.deleteObject(toBeDeleted as NSManagedObject)
                    }
                }
            case .NoDelete:
                break
            }
            
        }
        return .Success
    }
    
    public enum ChildManagedObjectSearchPattern {
        case NoSearch
        /// dictionaryKey, attributeKey
        case SearchStringEqual(String, String)
    }
    public enum ChildManagedObjectDeleteMode {
        case Delete
        case NoDelete
    }
}