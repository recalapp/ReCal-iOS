//
//  Queue.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public struct Queue<T>: SequenceType {
    public typealias GeneratorType = QueueGenerator<T>
    public func generate()->GeneratorType {
        return QueueGenerator<T>(queue: self)
    }
    
    public init() {
        
    }
    
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

public struct QueueGenerator<T>: GeneratorType {
    
    typealias Element = T
    
    private var queue: Queue<T>
    
    private var index = 0
    
    init(queue: Queue<T>){
        self.queue = queue
    }
    
    public mutating func next()->T? {
        // ok, passed by value
        if self.queue.isEmpty {
            return nil
        }
        else {
            return self.queue.dequeue()
        }
    }
}
