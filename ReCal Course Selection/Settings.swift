//
//  Settings.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/27/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

extension Settings {
    var availableColors: [CourseColor] {
        get {
            return self.persistentProperties["availableColors"] as? [CourseColor] ?? [CourseColor(normalColorHexString: "D0DECF", highlightedColorHexString: "2D6234")]
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
}