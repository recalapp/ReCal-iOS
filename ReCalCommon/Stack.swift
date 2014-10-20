//
//  Stack.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/16/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public struct Stack<T>: SequenceType {
    public typealias GeneratorType = StackGenerator<T>
    public func generate()->GeneratorType {
        return StackGenerator<T>(stack: self)
    }
    
    private var array:[T] = [];
    public var isEmpty: Bool {
        return self.array.count == 0;
    }
    
    public mutating func push(item: T) {
        self.array.append(item);
    }
    
    public mutating func pop() -> T? {
        if self.isEmpty {
            return nil;
        }
        return self.array.removeLast();
    }
}

public struct StackGenerator<T>: GeneratorType {
    
    typealias Element = T
    
    private var stack: Stack<T>
    
    private var index = 0
    
    init(stack: Stack<T>){
        self.stack = stack
    }
    
    public mutating func next()->T? {
        // ok, passed by value
        return self.stack.pop()
    }
}
