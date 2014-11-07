//
//  Day.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/6/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

enum Day: Int, Printable {
    init?(rawValue: Int) {
        switch rawValue {
        case Day.Monday.rawValue:
            self = .Monday
        case Day.Tuesday.rawValue:
            self = .Tuesday
        case Day.Wednesday.rawValue:
            self = .Wednesday
        case Day.Thursday.rawValue:
            self = .Thursday
        case Day.Friday.rawValue:
            self = .Friday
        case Day.Saturday.rawValue:
            self = .Saturday
        case Day.Sunday.rawValue:
            self = .Sunday
        default:
            return nil
        }
    }
    init?(dayString: String) {
        switch dayString.lowercaseString {
        case "monday", "mon", "mo", "m":
            self = .Monday
        case "tuesday", "tue", "tu", "t":
            self = .Tuesday
        case "wednesday", "wed", "w":
            self = .Wednesday
        case "thursday", "th":
            self = .Thursday
        case "friday", "fri", "fr", "f":
            self = .Friday
        case "saturday", "sat", "sa":
            self = .Saturday
        case "sunday", "sun", "su":
            self = .Sunday
        default:
            return nil
        }
    }
    case Monday = 0, Tuesday = 1, Wednesday = 2, Thursday = 3, Friday = 4, Saturday, Sunday
    var description: String {
        switch self {
        case .Monday:
            return "Monday"
        case .Tuesday:
            return "Tuesday"
        case .Wednesday:
            return "Wednesday"
        case .Thursday:
            return "Thursday"
        case .Friday:
            return "Friday"
        case .Saturday:
            return "Saturday"
        case .Sunday:
            return "Sunday"
        }
    }
    var shortDayString: String {
        switch self {
        case .Monday:
            return "m"
        case .Tuesday:
            return "t"
        case .Wednesday:
            return "w"
        case .Thursday:
            return "th"
        case .Friday:
            return "f"
        case .Saturday:
            return "sa"
        case .Sunday:
            return "su"
        }
    }
}