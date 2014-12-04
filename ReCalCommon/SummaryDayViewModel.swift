//
//  SummaryDayViewModel.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public extension SummaryDayView {
    public struct EventTime : Comparable {
        public let startHour: Int
        public let startMinute: Int
        public let endHour: Int
        public let endMinute: Int
    }
}

public protocol SummaryDayViewModel {
    var events: [SummaryDayViewEvent] { get }
}
public protocol SummaryDayViewEvent {
    var title: String { get }
    var time: SummaryDayView.EventTime { get }
}

public func == (lhs: SummaryDayView.EventTime, rhs: SummaryDayView.EventTime)->Bool {
    return lhs.startHour == rhs.startHour && lhs.startMinute == rhs.startMinute && lhs.endHour == rhs.endHour && lhs.endMinute == rhs.endMinute
}

public func < (lhs: SummaryDayView.EventTime, rhs: SummaryDayView.EventTime)->Bool {
    if lhs.startHour < rhs.startHour {
        return true
    } else if lhs.startHour > rhs.startHour {
        return false
    }
    // start hour equals
    if lhs.startMinute < rhs.startMinute {
        return true
    } else if lhs.startMinute > rhs.startMinute {
        return false
    }
    // start minute equals
    if lhs.endHour < rhs.endHour {
        return true
    } else if lhs.endHour > rhs.endHour {
        return false
    }
    // end hour equals
    if lhs.endMinute < rhs.endMinute {
        return true
    } else if lhs.endMinute > rhs.endMinute {
        return false
    }
    // end minute equals
    
    // times are equal
    return false
}