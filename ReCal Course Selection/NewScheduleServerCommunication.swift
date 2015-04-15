//
//  NewScheduleServerCommunication.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 4/3/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import Foundation

import ReCalCommon

class NewScheduleServerCommunication : ServerCommunicator.ServerCommunication {
    private let managedObjectContext: NSManagedObjectContext
    private let managedObject: CDSchedule
    private let scheduleDictionary: [String:String]
    override var request: NSURLRequest {
        // get actual url
        let urlString = Urls.newSchedule
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
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
    init(scheduleDictionary: [String:String], managedObject: CDSchedule, managedObjectContext: NSManagedObjectContext) {
        self.managedObject = managedObject
        self.scheduleDictionary = scheduleDictionary
        self.managedObjectContext = managedObjectContext
        super.init(identifier: "NewSchedule\(self.scheduleDictionary)")
    }
    
    override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
        switch result {
        case .Success(let response, let data):
            println("Successfully uploaded a new schedule")
            println(response)
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            // get new schedule id
            if let scheduleId: AnyObject = Json.parse(data)?["id"] {
                var errorOpt: NSError?
                self.managedObjectContext.performBlock {
                    self.managedObject.serverId = "\(scheduleId)"
                    self.managedObject.isNew = false
                    if self.managedObject.modifiedLogicalValue == .Uploading {
                        self.managedObject.modifiedLogicalValue = .NotModified
                    }
                    self.managedObjectContext.save(&errorOpt)
                    if let error = errorOpt {
                        println("Error saving modified schedule. Error: \(error)")
                    }
                }
                
            }
            return .Remove
        case .Failure(let error):
            println("Error uploading schedule. Error: \(error)")
            return .Remove
        }
    }
    override func shouldSendRequest() -> ServerCommunicator.ShouldSend {
        if let _ = Settings.currentSettings.authenticator.user {
            return .Send
        } else {
            return .NextInterrupt
        }
    }
}