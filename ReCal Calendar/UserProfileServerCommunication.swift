//
//  UserProfileServerCommunication.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/16/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class UserProfileServerCommunicator : ServerCommunicator.ServerCommunication {
    
    override var request: NSURLRequest {
        let request = NSURLRequest(URL: NSURL(string: Urls.userProfileUrl)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 100)
        return request
    }
    
    init(){
        super.init(identifier: "userProfile")
    }
    
    override var idleInterval: Int {
        return 20
    }
    
    override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
        switch result {
        case .Success(_, let data):
            println("Successfully downloaded user profile data")
            Settings.currentSettings.coreDataImporter.performBlockAndWait {
                let _ = Settings.currentSettings.coreDataImporter.writeJSONDataToPendingItemsDirectory(data, withTemporaryFileName: CalendarCoreDataImporter.TemporaryFileNames.userProfile)
            }
            return .NoAction
        case .Failure(let error):
            println("Error downloading user profile data. Error: \(error)")
            return .NoAction
        }
    }
    override func shouldSendRequest() -> ServerCommunicator.ShouldSend {
        switch Settings.currentSettings.authenticator.state {
        case .Authenticated(_):
            return .Send
        case .Unauthenticated:
            return .NextInterrupt
        case .Cached(_), .PreviouslyAuthenticated(_), .Demo(_):
            Settings.currentSettings.authenticator.authenticate()
            return .NextInterrupt
        }
    }
}