//
//  ModifiedSchedulesServerCommunication.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 3/29/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import Foundation

import ReCalCommon

class ModifiedSchedulesServerCommunication : ServerCommunicator.ServerCommunication {
    private let scheduleId: Int
    private let managedObjectContext: NSManagedObjectContext
    private let scheduleDictionary: [String:String]
    override var request: NSURLRequest {
        // get actual url
        let urlString = Urls.scheduleWithId(scheduleId: self.scheduleId)
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPShouldHandleCookies = true
        request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: Urls.base)!)!)
        let body = Json.serializeToData(self.scheduleDictionary)
        request.HTTPBody = body
        let csrfToken = tryGetCsrfToken(NSHTTPCookieStorage.sharedHTTPCookieStorage()) ?? ""
        request.addValue(csrfToken, forHTTPHeaderField: "X_CSRFTOKEN")
        return request
    }
    override var idleInterval: Int {
        return 1
    }
    init(scheduleDictionary: [String:String], scheduleId:Int, managedObjectContext: NSManagedObjectContext) {
        self.scheduleDictionary = scheduleDictionary
        self.managedObjectContext = managedObjectContext
        self.scheduleId = scheduleId
        super.init(identifier: "SyncSchedule\(scheduleId)")
    }
    
    override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
        switch result {
        case .Success(let response, let data):
            println("Successfully uploaded one modified schedule with id \(self.scheduleId)")
            // TODO mark as not modified
            if let scheduleObject = tryGetManagedObjectObject(managedObjectContext: self.managedObjectContext, entityName: "CDSchedule", attributeName: "serverId", attributeValue: "\(self.scheduleId)") as? CDSchedule {
                // TODO why does this code freezes when we use performBlockAndWait ?
                var errorOpt: NSError?
                if scheduleObject.modifiedLogicalValue == .Uploading {
                    scheduleObject.modifiedLogicalValue = .NotModified
                }
                self.managedObjectContext.persistentStoreCoordinator!.lock()
                self.managedObjectContext.save(&errorOpt)
                self.managedObjectContext.persistentStoreCoordinator!.unlock()
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