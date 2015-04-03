//
//  AppDelegate.swift
//  ReCal Course Selection
//
//  Created by Naphat Sanguansin on 10/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import CoreData
import ReCalCommon

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    private let userDefaultsKeyNotFirstLaunch = "not_first_launch"
    private let initialCoursesFileName = "courses"
    var window: UIWindow?

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        if let url = launchOptions?[UIApplicationLaunchOptionsURLKey] as? NSURL {
            if url.scheme == Urls.courseSelectionUrlScheme {
                return true
            }
            return false
        }
        return true
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let launch: ()->Void = {
            let rootViewController = self.window?.rootViewController
            Settings.currentSettings.theme = Theme(rawValue: Settings.currentSettings.sharedUserDefaults.integerForKey(Settings.UserDefaultsKeys.Theme)) ?? .Dark
            Settings.currentSettings.authenticator = Authenticator(rootViewController: rootViewController!, forAuthenticationUrlString: Urls.authentication, withLogOutUrlString: Urls.logOut)
            Settings.currentSettings.coreDataImporter = CourseSelectionCoreDataImporter(persistentStoreCoordinator: self.persistentStoreCoordinator!)
            if false && !NSUserDefaults.standardUserDefaults().boolForKey(self.userDefaultsKeyNotFirstLaunch) {
                println("saving")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: self.userDefaultsKeyNotFirstLaunch)
                let filePathOpt = NSBundle.mainBundle().pathForResource(self.initialCoursesFileName, ofType: "json")
                if let filePath = filePathOpt {
                    let initialDataOpt = NSData(contentsOfFile: filePath)
                    if let initialData = initialDataOpt {
                        let coreDataImporter = Settings.currentSettings.coreDataImporter
                        coreDataImporter.performBlockAndWait {
                            let _ = coreDataImporter.writeJSONDataToPendingItemsDirectory(initialData, withTemporaryFileName: CourseSelectionCoreDataImporter.TemporaryFileNames.courses)
                        }
                    }
                }
            }
            Settings.currentSettings.coreDataImporter.performBlockAndWait {
                let _ = Settings.currentSettings.coreDataImporter.importPendingItems()
            }
            Settings.currentSettings.serverCommunicator.performBlockAndWait {
                Settings.currentSettings.serverCommunicator.registerServerCommunication(ActiveSemesterServerCommunication())
                Settings.currentSettings.serverCommunicator.registerServerCommunication(AvailableColorsServerCommunication())
            }
            Settings.currentSettings.schedulesSyncService.performBlockAndWait {
                let _ = Settings.currentSettings.schedulesSyncService.sync()
            }
        }
        if let url = launchOptions?[UIApplicationLaunchOptionsURLKey] as? NSURL {
            if url.scheme == Urls.courseSelectionUrlScheme {
                launch()
                return true
            }
            return false
        }
        launch()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if url.scheme == Urls.courseSelectionUrlScheme {
            return true
        }
        return false
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Settings.currentSettings.theme = Theme(rawValue: Settings.currentSettings.sharedUserDefaults.integerForKey(Settings.UserDefaultsKeys.Theme)) ?? .Light
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "io.recal.ReCal_Course_Selection" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ReCal_Course_Selection", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ReCal_Course_Selection.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options:
            [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true]
            , error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()
}

