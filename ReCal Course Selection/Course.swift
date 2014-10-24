//
//  Course.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import ReCalCommon

struct Course: Equatable {
    let sections: [Section]
}

func == (lhs: Course, rhs: Course)-> Bool {
    if lhs.sections.count != rhs.sections.count {
        return false
    }
    return arraysContainSameElements(lhs.sections, rhs.sections)
}