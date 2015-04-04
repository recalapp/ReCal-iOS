//
//  CoursesServerCommunication.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 3/27/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class CoursesServerCommunication: ServerCommunicator.ServerCommunication {
    private let semesterTermCode: String
    override var request: NSURLRequest {
        // get actual url
        let urlString = Urls.courses(semesterTermCode: self.semesterTermCode)
        return NSURLRequest(URL: NSURL(string: urlString)!)
    }
    override var idleInterval: Int {
        return 100
    }
    
    init(semesterTermCode: String) {
        self.semesterTermCode = semesterTermCode
        super.init(identifier: "courses\(semesterTermCode)")
    }
    
    override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
        switch result {
        case .Success(_, let data):
            println("Successfully downloaded courses for semester \(self.semesterTermCode)")
            let coreDataImporter = Settings.currentSettings.coreDataImporter
            coreDataImporter.performBlock {
                let _ = coreDataImporter.writeJSONDataToPendingItemsDirectory(data, withTemporaryFileName: CourseSelectionCoreDataImporter.TemporaryFileNames.activeSemesters)
            }
            return .NoAction
        case .Failure(let error):
            println("Error downloading active semesters. Error: \(error)")
            return .NoAction
        }
    }
}
