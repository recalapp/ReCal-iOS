//
//  ActiveSemesterServerCommunication.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/19/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class ActiveSemesterServerCommunication: ServerCommunicator.ServerCommunication {
    override var request: NSURLRequest {
        // get actual url
        let urlString = Urls.activeSemesters
        return NSURLRequest(URL: NSURL(string: urlString)!)
    }
    override var idleInterval: Int {
        return 5
    }
    
    init() {
        super.init(identifier: "activeSemesters")
    }
    
    override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
        switch result {
        case .Success(_, let data):
            println("Successfully downloaded active semesters")
            Settings.currentSettings.coreDataImporter.writeJSONDataToPendingItemsDirectory(data, withTemporaryFileName: CourseSelectionCoreDataImporter.TemporaryFileNames.activeSemesters)
            return .NoAction
        case .Failure(let error):
            println("Error downloading active semesters. Error: \(error)")
            return .NoAction
        }
    }
}
