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
    private let temporaryDirectory = "core_data_importer_temp"
    
    private var temporaryDirectoryPath: String? {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last?.stringByAppendingPathComponent(temporaryDirectory)
    }
    
    public var temporaryFileNames: [String] {
        return []
    }
    
    private var notificationObservers = [AnyObject]()
    
    public init(persistentStoreCoordinator: NSPersistentStoreCoordinator) {
        self.persistentStoreCoordinator = persistentStoreCoordinator
        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { (notification) -> Void in
            self.backgroundManagedObjectContext.performBlockAndWait {
                self.backgroundManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            }
        }
        self.notificationObservers.append(observer1)
    }
    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    public let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    lazy public var backgroundManagedObjectContext: NSManagedObjectContext = {
//        assert(self.persistentStoreCoordinator != nil, "Persistent store coordinator must be set before Core Data Importer can be used")
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
        }()
    
    public final func writeJSONDataToPendingItemsDirectory(data: NSData, withTemporaryFileName fileName: String) -> Bool {
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
            let temporaryFilePath = temporaryDirectoryPath.stringByAppendingPathComponent(fileName)
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
        for fileName in self.temporaryFileNames {
            if let temporaryFilePath = self.temporaryDirectoryPath?.stringByAppendingPathComponent(fileName) {
                let fileManager = NSFileManager.defaultManager()
                if fileManager.fileExistsAtPath(temporaryFilePath) {
                    let dataOpt = NSData(contentsOfFile: temporaryFilePath)
                    var errorOpt: NSError?
                    
                    if let data = dataOpt {
                        switch self.processData(data, fromTemporaryFileName: fileName) {
                        case .Success:
                            fileManager.removeItemAtPath(temporaryFilePath, error: &errorOpt)
                            if let error = errorOpt {
                                println("Error deleting old temporary file. Aborting save. Error: \(error)")
                            }
                        case .ShouldRetry:
                            break // don't delete temp file. TODO change break to continue if this becomes a loop
                        case .Failure:
                            fileManager.removeItemAtPath(temporaryFilePath, error: &errorOpt)
                            if let error = errorOpt {
                                println("Error deleting old temporary file. Aborting save. Error: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func processData(data: NSData, fromTemporaryFileName fileName: String) -> ImportResult {
        return .Success
    }
    public enum ImportResult {
        /// Import successful. Delete temporary file
        case Success
        
        /// Recoverable error. Do not delete temporary file, so it will get imported on next import
        case ShouldRetry
        
        /// Unrecoverable error. Delete temporary file
        case Failure
    }
}