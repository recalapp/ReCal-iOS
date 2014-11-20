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
    static let activeSemesters = "\(courseSelectionBase)/api/v1/semester/?format=json"
    static func courses(#semesterTermCode: String) -> String {
        return "\(courseSelectionBase)/api/v1/course/?semester__term_code=\(semesterTermCode)&format=json"
    }
}