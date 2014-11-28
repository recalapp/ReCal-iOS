//
//  AvailableColorsServerCommunication.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/25/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

class AvailableColorsServerCommunication: ServerCommunicator.ServerCommunication {
    override var request: NSURLRequest {
        // get actual url
        let urlString = Urls.availableColors
        return NSURLRequest(URL: NSURL(string: urlString)!)
    }
    override var idleInterval: Int {
        return 100
    }
    
    init() {
        super.init(identifier: "availableColors")
    }
    
    override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
        switch result {
        case .Success(_, let data):
            println("Successfully downloaded available colors")
            var errorOpt: NSError?
            let dictOpt = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &errorOpt) as? Dictionary<String, AnyObject>
            if let error = errorOpt {
                println("Error parsing json for available colors. Error: \(error)")
                return .NoAction
            }
            if let dict = dictOpt {
                if let colorDictArray = dict["objects"] as? [Dictionary<String, AnyObject>] {
                    let courseColors = colorDictArray.map { CourseColor(normalColorHexString: $0["light"] as String, highlightedColorHexString: $0["dark"] as String) }
                    Settings.currentSettings.availableColors = courseColors
                }
            }
            return .NoAction
        case .Failure(let error):
            println("Error downloading active semesters. Error: \(error)")
            return .NoAction
        }
    }
}