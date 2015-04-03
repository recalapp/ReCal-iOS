//
//  Settings.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/27/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

private let schedulesSyncServiceObject = SchedulesSyncService(serverCommunicator: Settings.currentSettings.serverCommunicator)
extension Settings {
    var schedulesSyncService: SchedulesSyncService {
        get {
            return schedulesSyncServiceObject
        }
    }
    var availableColors: [CourseColor] {
        get {
            return self.persistentProperties["availableColors"] as? [CourseColor] ?? [CourseColor(normalColorHexString: "D0DECF", highlightedColorHexString: "2D6234", serverId: "0")]
        }
        set {
            self.persistentProperties["availableColors"] = newValue
        }
    }
    var lastOpenedScheduleIdUri: NSURL? {
        get {
            return self.persistentProperties["lastOpenedSchedule"] as? NSURL
        }
        set {
            self.persistentProperties["lastOpenedSchedule"] = newValue
        }
    }
    var scheduleDisplayTextStyle: ScheduleDisplayTextStyle {
        get {
            if let rawValue = self.volatileProperties["scheduleDisplayTextStyle"] as? Int {
                return ScheduleDisplayTextStyle(rawValue: rawValue) ?? .CourseNumber
            }
            return .CourseNumber
        }
        set {
            let oldValue = self.volatileProperties["scheduleDisplayTextStyle"] as? Int
            self.volatileProperties["scheduleDisplayTextStyle"] = newValue.rawValue
            if oldValue != newValue.rawValue {
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.ScheduleDisplayTextStyleDidChange, object: self)
            }
        }
    }
    enum ScheduleDisplayTextStyle: Int {
        case SectionName
        case CourseNumber
    }

}
extension Settings.Notifications {
    static let ScheduleDisplayTextStyleDidChange = "ScheduleDisplayTextStyleDidChange"
}