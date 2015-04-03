//
//  CoreDataUtil.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 4/3/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import CoreData

public func tryGetManagedObjectObject(#managedObjectContext: NSManagedObjectContext, #entityName: String, #attributeName: String, #attributeValue: String) -> NSManagedObject? {
    let fetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.predicate = NSPredicate(format: "\(attributeName) = %@", attributeValue)
    fetchRequest.fetchLimit = 1
    var fetched: [NSManagedObject]?
    var errorOpt: NSError?
    managedObjectContext.performBlockAndWait {
        fetched = managedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt) as? [NSManagedObject]
    }
    if let error = errorOpt {
        println("Error fetching. Error: \(error)")
    }
    return fetched?.last
}