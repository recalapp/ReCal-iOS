//
//  CoreDataToCourseStructConverter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class CoreDataToCourseStructConverter {
    
    func courseStructFromCoreData(course: CDCourse) -> Course {
        return Course(managedObject: course)
    }
}