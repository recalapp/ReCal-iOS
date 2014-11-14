//
//  CompositeManagedObjectAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/14/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData

public class CompositeManagedObjectAttributeImporter : ManagedObjectAttributeImporter {
    
    public let attributeImporters: [ManagedObjectAttributeImporter]
    
    public init(attributeImporters: [ManagedObjectAttributeImporter]) {
        self.attributeImporters = attributeImporters
        super.init()
    }
    
    public override func importAttributeFromDictionary(dict: Dictionary<String, AnyObject>, intoManagedObject managedObject: NSManagedObject, inManagedObjectContext managedObjectContext: NSManagedObjectContext)->ImportResult {
        for attributeImporter in self.attributeImporters {
            let importResult = attributeImporter.importAttributeFromDictionary(dict, intoManagedObject: managedObject, inManagedObjectContext: managedObjectContext)
            switch importResult {
            case .Success:
                break
            case .Error(_):
                return importResult
            }
        }
        return .Success
    }
}