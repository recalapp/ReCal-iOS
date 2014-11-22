//
//  ScheduleSelectionDelegate.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/7/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

protocol ScheduleSelectionDelegate: class {
    func didDeleteScheduleWithObjectId(objectId: NSManagedObjectID)
    func didSelectScheduleWithObjectId(objectId: NSManagedObjectID)
}