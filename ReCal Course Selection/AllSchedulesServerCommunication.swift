//
//  AllSchedulesServerCommunication.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 2/28/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class AllSchedulesServerCommunication : ServerCommunicator.ServerCommunication {
    override var request: NSURLRequest {
        // get actual url
        if let user = Settings.currentSettings.authenticator.user {
            let urlString = Urls.schedulesForUser(username: user.username)
            return NSURLRequest(URL: NSURL(string: urlString)!)
        }
        assert(false, "Trying to create a schedules request when the ServerCommunication object says not to do so.")
        return NSURLRequest()
    }
    override var idleInterval: Int {
        return 100
    }
    
    init() {
        super.init(identifier: "allSchedules")
    }
    
    override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
        switch result {
        case .Success(_, let data):
            println("Successfully downloaded all schedules")
            var errorOpt: NSError?
            let dictOpt = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &errorOpt) as? Dictionary<String, AnyObject>
            if let error = errorOpt {
                println("Error parsing json for all schedules. Error: \(error)")
                return .NoAction
            }
            if let dict = dictOpt {
                // call schedule importer
                println(dict)
            }
            return .NoAction
        case .Failure(let error):
            println("Error downloading schedules. Error: \(error)")
            return .NoAction
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