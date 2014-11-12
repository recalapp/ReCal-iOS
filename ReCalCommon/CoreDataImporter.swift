//
//  CoreDataImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/11/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataImporter {
    private let temporaryFileName = "temp"
    private let temporaryDirectory = "core_data_importer_temp"
    
    private var temporaryDirectoryPath: String? {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last?.stringByAppendingPathComponent(temporaryDirectory)
    }
    
    public init() {
        
    }
    
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    lazy public var backgroundManagedObjectContext: NSManagedObjectContext = {
        assert(self.persistentStoreCoordinator != nil, "Persistent store coordinator must be set before Core Data Importer can be used")
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
        }()
    
    public final func writeJSONDataToPendingItemsDirectory(data: NSData) -> Bool {
        var errorOpt: NSError?
        let parsed: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &errorOpt)
        if let error = errorOpt {
            println("Error parsing json data. Aborting write. Error: \(error)")
            return false
        }
        let parsedData = NSKeyedArchiver.archivedDataWithRootObject(parsed!)
        let fileManager = NSFileManager.defaultManager()
        if let temporaryDirectoryPath = self.temporaryDirectoryPath {
            if !fileManager.fileExistsAtPath(temporaryDirectoryPath) {
                fileManager.createDirectoryAtPath(temporaryDirectoryPath, withIntermediateDirectories: false, attributes: nil, error: &errorOpt)
                if let error = errorOpt {
                    println("Error creating temporary directory. Aborting. Error: \(error)")
                    return false
                }
            }
            let temporaryFilePath = temporaryDirectoryPath.stringByAppendingPathComponent(temporaryFileName)
            if fileManager.fileExistsAtPath(temporaryFilePath) {
                fileManager.removeItemAtPath(temporaryFilePath, error: &errorOpt)
                if let error = errorOpt {
                    println("Error deleting old temporary file. Aborting save. Error: \(error)")
                    return false
                }
            }
            return fileManager.createFileAtPath(temporaryFilePath, contents: parsedData, attributes: nil)
        } else {
            println("Error getting directory path. Aborting save.")
            return false
        }
    }
    public final func importPendingItems() {
        if let temporaryFilePath = self.temporaryDirectoryPath?.stringByAppendingPathComponent(temporaryFileName) {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(temporaryFilePath) {
                let dataOpt = NSData(contentsOfFile: temporaryFilePath)
                var errorOpt: NSError?
                fileManager.removeItemAtPath(temporaryFilePath, error: &errorOpt)
                if let error = errorOpt {
                    println("Error deleting old temporary file. Aborting save. Error: \(error)")
                    return
                }
                if let data = dataOpt {
                    self.processData(data)
                    self.backgroundManagedObjectContext.performBlockAndWait {
                        self.backgroundManagedObjectContext.save(&errorOpt)
                        if let error = errorOpt {
                            println("Error saving. Aborting. Error: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    public func processData(data: NSData) {
        
    }
}