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
        
        public init(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int) {
            self.startHour = startHour
            self.startMinute = startMinute
            self.endHour = endHour
            self.endMinute = endMinute
        }
        
        public var startHourFractional: Double {
            return Double(startHour) + Double(startMinute)/60.0
        }
        public var endHourFractional: Double {
            return Double(endHour) + Double(endMinute)/60.0
        }
        
        public var interval: Interval<Double> {
            return Interval(start: startHourFractional, end: endHourFractional)
        }
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
    return lhs.interval == rhs.interval
}

public func < (lhs: SummaryDayView.EventTime, rhs: SummaryDayView.EventTime)->Bool {
    return lhs.interval < rhs.interval
}