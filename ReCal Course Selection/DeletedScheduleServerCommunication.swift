//
//  DeletedScheduleServerCommunication.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 4/3/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class DeletedScheduleServerCommunication : ServerCommunicator.ServerCommunication {
    private let scheduleId: Int
    private let managedObjectContext: NSManagedObjectContext
    private let managedObject: CDSchedule
    override var request: NSURLRequest {
        // get actual url
        let urlString = Urls.scheduleWithId(scheduleId: self.scheduleId)
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "DELETE"
        request.HTTPShouldHandleCookies = true
        request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: Urls.base)!)!)
        let csrfToken = tryGetCsrfToken(NSHTTPCookieStorage.sharedHTTPCookieStorage()) ?? ""
        request.addValue(csrfToken, forHTTPHeaderField: "X_CSRFTOKEN")
        return request
    }
    override var idleInterval: Int {
        return 1
    }
    init(managedObject: CDSchedule, scheduleId:Int, managedObjectContext: NSManagedObjectContext) {
        self.managedObject = managedObject
        self.managedObjectContext = managedObjectContext
        self.scheduleId = scheduleId
        super.init(identifier: "SyncSchedule\(scheduleId)")
    }
    
    override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
        switch result {
        case .Success(let response, let data):
            println("Successfully uploaded one deleted schedule with id \(self.scheduleId)")
            if let scheduleObject = tryGetManagedObjectObject(managedObjectContext: self.managedObjectContext, entityName: "CDSchedule", attributeName: "serverId", attributeValue: "\(self.scheduleId)") as? CDSchedule {
                var errorOpt: NSError?
                self.managedObjectContext.performBlockAndWait {
                    self.managedObjectContext.deleteObject(self.managedObject)
                    self.managedObjectContext.persistentStoreCoordinator!.lock()
                    self.managedObjectContext.save(&errorOpt)
                    self.managedObjectContext.persistentStoreCoordinator!.unlock()
                }
                if let error = errorOpt {
                    println("Error saving modified schedule. Error: \(error)")
                }
                
            }
            return .Remove
        case .Failure(let error):
            println("Error uploading schedule. Error: \(error)")
            return .Remove
        }
    }
    override func shouldSendRequest() -> ServerCommunicator.ShouldSend {
        return .Send
    }
}