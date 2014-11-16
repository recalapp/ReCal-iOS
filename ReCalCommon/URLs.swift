//
//  URLs.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/9/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public let baseUrl = "http://localhost:8000"
public let authenticationUrl = "\(baseUrl)/mobile_logged_in"
public let logOutUrl = "\(baseUrl)/logout"


public let recalUrlScheme = "recal"
public let calendarUrlHost = "calendar"
public let courseSelectionUrlHost = "courseSelection"
public let calendarUrl = "\(recalUrlScheme)://\(calendarUrlHost)"
public let courseSelectionUrl = "\(recalUrlScheme)://\(courseSelectionUrlHost)"