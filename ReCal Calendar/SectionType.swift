//
//  SectionType.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/11/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

enum SectionType: String {
    case Precept = "pre", Lecture = "lec", Drill = "dri", Class = "cla", Seminar = "sem", Studio = "stu", Film = "fil", Ear = "ear", Lab = "lab", All = "all"
    
    var displayText: String {
        switch self {
        case .Precept:
            return "Precept"
        case .Lecture:
            return "Lecture"
        case .Drill:
            return "Drill"
        case .Class:
            return "Class"
        case .Seminar:
            return "Seminar"
        case .Studio:
            return "Studio"
        case .Film:
            return "Film"
        case .Ear:
            return "Ear Training"
        case .Lab:
            return "Lab"
        case .All:
            return "All Students"
        }
    }
}