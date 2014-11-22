//
//  ToOneChildManagedObjectAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/14/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

import CoreData

public class ToOneChildManagedObjectAttributeImporter: ManagedObjectAttributeImporter {
    
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
        let value = (dict[self.dictionaryKey] as? Dictionary<String, AnyObject>)
        if value == nil {
            println("Invalid dictionary. Does not contain specified key: \(self.dictionaryKey)")
            return .Error(.InvalidDictionary)
        }
        if managedObject.entity.propertiesByName[self.attributeKey] == nil {
            println("Invalid managed object. Does not contain specified key: \(self.attributeKey)")
            return .Error(.InvalidManagedObject)
        }
        
        switch self.childSearchPattern {
        case .Reuse:
            var childManagedObjectOpt: NSManagedObject?
            managedObjectContext.performBlockAndWait {
                childManagedObjectOpt = managedObject.valueForKey(self.attributeKey) as? NSManagedObject
            }
            if let childManagedObject = childManagedObjectOpt {
                self.childAttributeImporter.importAttributeFromDictionary(value!, intoManagedObject: childManagedObject, inManagedObjectContext: managedObjectContext)
            } else {
                fallthrough
            }
        case .NoSearch:
            switch self.deleteMode {
            case .Delete:
                var childManagedObjectOpt: NSManagedObject?
                managedObjectContext.performBlockAndWait {
                    childManagedObjectOpt = managedObject.valueForKey(self.attributeKey) as? NSManagedObject
                }
                if let child = childManagedObjectOpt {
                    managedObjectContext.performBlockAndWait {
                        managedObjectContext.delete(child)
                    }
                }
            case .NoDelete:
                break
            }
            var childManagedObject: NSManagedObject!
            managedObjectContext.performBlockAndWait {
                childManagedObject = NSEntityDescription.insertNewObjectForEntityForName(self.childEntityName, inManagedObjectContext: managedObjectContext) as? NSManagedObject
            }
            if childManagedObject == nil {
                return .Error(.InvalidManagedObject)
            }
            self.childAttributeImporter.importAttributeFromDictionary(value!, intoManagedObject: childManagedObject, inManagedObjectContext: managedObjectContext)
            managedObjectContext.performBlockAndWait {
                managedObject.setValue(childManagedObject, forKey: self.attributeKey)
            }
        case .SearchStringEqual(let childDictionaryKey, let childAttributeKey):
            var childManagedObject: NSManagedObject!
            let childValue: AnyObject! = value![childDictionaryKey]
            if childValue == nil {
                println("Invalid child dictionary. Does not contain specified key: \(childDictionaryKey)")
                return .Error(.InvalidDictionary)
            }
            let fetchRequest = NSFetchRequest(entityName: self.childEntityName)
            fetchRequest.predicate = NSPredicate(format: "\(childAttributeKey) == %@", "\(childValue)")
            fetchRequest.fetchLimit = 1
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
                self.childAttributeImporter.importAttributeFromDictionary(value!, intoManagedObject: childManagedObject, inManagedObjectContext: managedObjectContext)
                managedObjectContext.performBlockAndWait {
                    if !childManagedObject.isEqual(managedObject.valueForKey(self.attributeKey)) {
                        switch self.deleteMode {
                        case .Delete:
                            managedObjectContext.deleteObject(managedObject.valueForKey(self.attributeKey) as NSManagedObject)
                        case .NoDelete:
                            break
                        }
                        managedObject.setValue(childManagedObject, forKey: self.attributeKey)
                    }
                }
            case .Error(_):
                return ret
            }
        }
        return .Success
    }
    
    public enum ChildManagedObjectSearchPattern {
        case NoSearch
        case Reuse
        /// dictionaryKey, attributeKey
        case SearchStringEqual(String, String)
    }
    public enum ChildManagedObjectDeleteMode {
        case Delete
        case NoDelete
    }
}