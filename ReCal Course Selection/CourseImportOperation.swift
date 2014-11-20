//
//  CourseImportOperation.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/20/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class CourseImportOperation: NSOperation {
    private let managedObjectContext: NSManagedObjectContext
    private let dict: Dictionary<String, AnyObject>
    private let courseImporter: CourseAttributeImporter
    private let completion:(CoreDataImporter.ImportResult)->Void
    init(courseDictionary: Dictionary<String, AnyObject>, courseImporter: CourseAttributeImporter, managedObjectContext: NSManagedObjectContext, completion: (CoreDataImporter.ImportResult)->Void) {
        self.managedObjectContext = managedObjectContext
        self.dict = courseDictionary
        self.courseImporter = courseImporter
        self.completion = completion
        super.init()
    }
    private func fetchOrCreateEntityWithServerId(serverId: String, entityName: String) -> CDServerObject {
        var errorOpt: NSError?
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let serverIdPredicate = NSPredicate(format: "serverId = %@", argumentArray: [serverId])
        fetchRequest.predicate = serverIdPredicate
        fetchRequest.fetchLimit = 1
        var managedObject: CDServerObject?
        self.managedObjectContext.performBlockAndWait {
            let fetched = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt)
            if let error = errorOpt {
                println("Error fetching for entity name: \(entityName), with server id: \(serverId). Error: \(error)")
                abort()
            }
            if let last = fetched?.last as? CDServerObject {
                managedObject = last
            }
        }
        if managedObject == nil {
            // must create, as it does not exist
            self.managedObjectContext.performBlockAndWait{
                managedObject = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self.managedObjectContext) as? CDServerObject
                if managedObject == nil {
                    println("Error creating for entity name: \(entityName), with server id: \(serverId).")
                    abort()
                }
                managedObject!.serverId = serverId
            }
        }
        return managedObject!
    }
    override func main() {
        let serverId: AnyObject? = dict["id"]
        if serverId == nil {
            self.completion(.Failure)
            return
        }
        let course = self.fetchOrCreateEntityWithServerId("\(serverId)", entityName: "CDCourse") as CDCourse
        let result = courseImporter.importAttributeFromDictionary(dict, intoManagedObject: course, inManagedObjectContext: self.managedObjectContext)
        switch result {
        case .Success:
            self.completion(.Success)
        case .Error(_):
            self.completion(.Failure)
        }
    }
}
