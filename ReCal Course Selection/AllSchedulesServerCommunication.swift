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
        return 10
    }
    class func identifier() -> String {
        return "allSchedules"
    }
    init() {
        super.init(identifier: AllSchedulesServerCommunication.identifier())
    }
    
    override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
        switch result {
        case .Success(_, let data):
            println("Successfully downloaded all schedules")
            Settings.currentSettings.coreDataImporter.performBlock {
                let _ = Settings.currentSettings.coreDataImporter.writeJSONDataToPendingItemsDirectory(data, withTemporaryFileName: CourseSelectionCoreDataImporter.TemporaryFileNames.allSchedules)
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