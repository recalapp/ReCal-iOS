//
//  EventsServerCommunication.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/16/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class EventsServerCommunication : ServerCommunicator.ServerCommunication {
    
    override var request: NSURLRequest {
        let request = NSURLRequest(URL: NSURL(string: "\(eventsPullUrl)/0")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        return request
    }
    
    override var idleInterval: Int {
        return 10
    }
    
    init(){
        super.init(identifier: "events")
    }
    
    override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
        switch result {
        case .Success(_, let data):
            println("Successfully downloaded event data")
            Settings.currentSettings.coreDataImporter.writeJSONDataToPendingItemsDirectory(data, withTemporaryFileName: CalendarCoreDataImporter.TemporaryFileNames.events)
            return .NoAction
        case .Failure(let error):
            println("Error downloading event data. Error: \(error)")
            return .NoAction
        }
    }
    override func shouldSendRequest() -> ServerCommunicator.ShouldSend {
        Settings.currentSettings.authenticator.authenticate()
        switch Settings.currentSettings.authenticator.state {
        case .Authenticated(_):
            return .Send
        case .Unauthenticated, .Cached(_), .PreviouslyAuthenticated(_), .Demo(_):
            return .NextInterrupt
        }
    }
}