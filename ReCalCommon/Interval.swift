//
//  Interval.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public struct Interval<T: Comparable>: Comparable {
    public let start: T
    public let end: T
    
    public init(start: T, end: T) {
        assert(start <= end, "start must be less than or equal to end")
        self.start = start
        self.end = end
    }
    
    public func contains(item: T, inclusive: Bool = true) -> Bool {
        if inclusive {
            return start <= item && item <= end
        } else {
            return start < item && item < end
        }
    }
    
    public func intersects(otherInterval: Interval<T>, inclusive: Bool = true) -> Bool {
        if inclusive {
            return self.start <= otherInterval.end && self.end >= otherInterval.start
        } else {
            return self.start < otherInterval.end && self.end > otherInterval.start
        }
    }
}

public func == <T: Comparable>(lhs: Interval<T>, rhs: Interval<T>)->Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end
}

public func < <T: Comparable>(lhs: Interval<T>, rhs: Interval<T>)->Bool {
    if lhs.start < rhs.start {
        return true
    } else if lhs.start > rhs.start {
        return false
    }
    if lhs.end < rhs.end {
        return true
    } else if lhs.end > rhs.end {
        return false
    }
    return false
}

public func + <T: Comparable>(lhs: Interval<T>, rhs: Interval<T>) -> Interval<T> {
    assert(lhs.intersects(rhs), "Cannot merge intervals that do not intersect")
    return Interval(start: min(lhs.start, rhs.start), end: max(lhs.end, rhs.end))
}

infix operator +? { associativity left precedence 160 }

public func +? <T: Comparable>(lhs: Interval<T>, rhs: Interval<T>) -> Interval<T>? {
    if lhs.intersects(rhs) {
        return lhs + rhs
    }
    return nil
}