//
//  URLs.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/16/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

extension Urls {
    static let courseSelectionBase = "\(base)/course_selection"
    static let courseSelectionApiBase = "\(courseSelectionBase)/api/v1"
    static let activeSemesters = "\(courseSelectionApiBase)/semester/?format=json"
    static let availableColors = "\(courseSelectionApiBase)/color_palette/?format=json"
    static private let schedules = "\(courseSelectionApiBase)/schedule/?format=json"
    static func schedulesForUser(#username: String) -> String {
        return "\(schedules)&user__netid=\(username)";
    }
    static func courses(#semesterTermCode: String) -> String {
        return "\(courseSelectionApiBase)/course/?semester__term_code=\(semesterTermCode)&format=json"
    }
    static func courses(#semesterTermCode: String, limit: Int, offset: Int) -> String {
        return "\(courses(semesterTermCode: semesterTermCode))&limit=\(limit)&offset=\(offset)"
    }
    static func scheduleWithId(#scheduleId: Int) -> String {
        return "\(courseSelectionApiBase)/schedule/\(scheduleId)/" // trailing slash necessary for POST
    }
    static let newSchedule = "\(courseSelectionApiBase)/schedule/"
}