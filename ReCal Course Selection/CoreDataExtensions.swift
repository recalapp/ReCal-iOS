//
//  CoreDataExtensions.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import CoreData

extension CDSectionMeeting {
    var days: [Day] {
        let daysStringArray = self.daysStorage.componentsSeparatedByString(" ")
        return daysStringArray.reduce([Day](), combine: { (days, dayString) in
            if let day = Day(dayString: dayString) {
                return days + [day]
            }
            return days
        }).sorted { $0.rawValue < $1.rawValue }
    }
}