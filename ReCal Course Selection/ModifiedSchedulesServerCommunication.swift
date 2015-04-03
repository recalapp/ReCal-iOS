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
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: Urls.scheduleWithId(scheduleId: self.scheduleId))!)
        request.HTTPMethod = "POST"
        let body = UrlEncoding.encodeParameters(parameters: self.scheduleDictionary, encoding: NSUTF8StringEncoding)
        request.HTTPBody = body
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
        case .Success(_, let data):
            println("Successfully uploaded one modified schedule with id \(self.scheduleId)")
            // TODO mark as not modified
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            if let scheduleObject = tryGetManagedObjectObject(managedObjectContext: self.managedObjectContext, entityName: "CDSchedule", attributeName: "serverId", attributeValue: "\(self.scheduleId)") as? CDSchedule {
                var errorOpt: NSError?
                self.managedObjectContext.performBlockAndWait {
                    scheduleObject.modified = false
                    self.managedObjectContext.save(&errorOpt)
                }
                if let error = errorOpt {
                    println("Error saving modified schedule. Error: \(error)")
                }
            }
            return .Remove
        case .Failure(let error):
            println("Error uploading schedule. Error: \(error)")
            return .NoAction
        }
    }
    override func shouldSendRequest() -> ServerCommunicator.ShouldSend {
        return .Send
    }
}