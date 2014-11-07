//
//  Set.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/24/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public struct Set<T: Hashable>: Equatable, SequenceType {
    typealias CallBack = Set<T>->Void
    public typealias GeneratorType = SetGenerator<T>
    public func generate()->GeneratorType {
        return SetGenerator<T>(set: self)
    }
    
    private var dict: Dictionary<T, Bool> = Dictionary<T, Bool>()
    
    public var count: Int {
        return dict.count
    }
    
    public var didAdd: CallBack?
    public var didRemove: CallBack?
    public var willAdd: CallBack?
    public var willRemove: CallBack?
    
    public init(initialItems: [T] = []) {
        for items in initialItems {
            self.add(items)
        }
    }
    
    public mutating func add(item: T) {
        assert(!self.contains(item), "Cannot add an item that already belong to the set")
        self.willAdd?(self)
        dict[item] = true
        self.didAdd?(self)
    }
    
    public func contains(item: T) -> Bool {
        return dict[item] == true
    }
    
    public mutating func remove(item: T) {
        assert(self.contains(item), "Cannot remove an item that does not belong to the set to begin with")
        self.willRemove?(self)
        dict.removeValueForKey(item)
        self.didRemove?(self)
    }
    
    public func map<U: Hashable>(transform: (T)->U)->Set<U> {
        var newSet = Set<U>()
        for item in self {
            newSet.add(transform(item))
        }
        return newSet
    }
    
    public func reduce<U>(initialValue: U, combine: (U, T)->U)-> U {
        var answer = initialValue
        for (key, _) in dict {
            answer = combine(answer, key)
        }
        return answer
    }
    
    public func anyItem() -> T? {
        return self.dict.keys.first
    }
    
    public func toArray() -> [T] {
        return self.reduce([], combine: { (array, item) in
            return array + [item]
        })
    }
}

public struct SetGenerator<T: Hashable>: GeneratorType {
    
    typealias Element = T
    
    private var set: Set<T>
    
    init(set: Set<T>){
        self.set = set
    }
    
    public mutating func next()->T? {
        // ok, passed by value
        if let key = self.set.anyItem() {
            self.set.remove(key)
            return key
        }
        return nil
    }
}

public func -<T: Hashable> (lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    var newSet = Set<T>()
    for item in lhs {
        newSet.add(item)
    }
    for item in rhs {
        if newSet.contains(item) {
            newSet.remove(item)
        }
    }
    return newSet
}

public func +<T: Hashable> (lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    var newSet = Set<T>()
    for item in lhs {
        newSet.add(item)
    }
    for item in rhs {
        newSet.add(item)
    }
    return newSet
}

public func ==<T: Hashable> (lhs: Set<T>, rhs: Set<T>) -> Bool {
    return lhs.count == rhs.count && lhs.reduce(true, combine: { (answer, item) in
        answer && rhs.contains(item)
    })
}

public func intersects<T: Hashable>(set1: Set<T>, set2: Set<T>) -> Set<T> {
    return set1 - (set1 - set2)
}