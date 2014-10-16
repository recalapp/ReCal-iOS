//
//  Queue.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public struct Queue<T> {
    private var array:[T] = [];
    public var isEmpty: Bool {
        return self.array.count == 0;
    }
        
    public mutating func enqueue(item: T) {
        self.array.append(item);
    }
    
    public mutating func dequeue() -> T? {
        if self.isEmpty {
            return nil;
        }
        return self.array.removeAtIndex(0);
    }
}