//
//  CoreDataAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/14/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData

public class ManagedObjectAttributeImporter {
    
    public init() {
        
    }
    
    public func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext)->ImportResult {
        assertionFailure("Abstract Method")
        return .Error(.NotImplemented)
    }
    
    public enum ImportResult {
        case Success
        case Error(ImportErrorType)
    }
    public enum ImportErrorType {
        case InvalidDictionary
        case InvalidManagedObject
        case NotImplemented
        case IncompleteLocalData
    }
}

