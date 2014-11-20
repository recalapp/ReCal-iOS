//
//  CourseServerCommunication.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/19/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class CourseServerCommunication: ServerCommunicator.ServerCommunication {
    let termCode: String
    override var request: NSURLRequest {
        // TODO get actual url
        let urlString = Urls.courses
        return NSURLRequest(URL: NSURL(string: urlString)!)
    }
    override var idleInterval: Int {
        return 100
    }
    
    init(termCode: String) {
        self.termCode = termCode
        super.init(identifier: "courses")
    }
    
    override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
        switch result {
        case .Success(_, let data):
            println("Successfully downloaded courses")
            Settings.currentSettings.coreDataImporter.writeJSONDataToPendingItemsDirectory(data, withTemporaryFileName: CourseSelectionCoreDataImporter.TemporaryFileNames.courses)
            Settings.currentSettings.coreDataImporter.importPendingItems()
            return .NoAction
        case .Failure(let error):
            println("Error downloading courses. Error: \(error)")
            return .NoAction
        }
    }
    
    
    override func shouldSendRequest()->ServerCommunicator.ShouldSend {
        Settings.currentSettings.authenticator.authenticate()
        switch Settings.currentSettings.authenticator.state {
        case .Authenticated(_), .Demo(_), .Cached(_), .PreviouslyAuthenticated(_):
            return .Send
        case .Unauthenticated:
            return .NextInterrupt
        }
    }
}
