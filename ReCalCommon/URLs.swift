//
//  URLs.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/9/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public struct Urls {
    public static let base = "http://recal.io"
    public static let authentication = "\(base)/mobile_logged_in"
    public static let logOut = "\(base)/logout"
    
    
    public static let calendarUrlScheme = "recalCalendar"
    public static let courseSelectionUrlScheme = "recalCourseSelection"
    public static let calendar = "\(calendarUrlScheme)://launch"
    public static let courseSelection = "\(courseSelectionUrlScheme)://launch"
}

