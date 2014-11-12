//
//  CalendarCoreDataImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/12/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData
import ReCalCommon

class CalendarCoreDataImporter: CoreDataImporter {
    override var temporaryFileNames: [String] {
        return [TemporaryFileNames.userProfile, TemporaryFileNames.events]
    }
    override func processData(data: NSData, fromTemporaryFileName fileName: String) -> CoreDataImporter.ImportResult {
        return .Success
    }
    struct TemporaryFileNames {
        static let userProfile = "userProfile"
        static let events = "events"
    }
}