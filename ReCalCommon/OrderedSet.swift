//
//  OrderedSet.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/6/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

private let debug = true

public struct OrderedSet<T: Hashable>: Equatable, SequenceType {
    typealias CallBack = OrderedSet<T>->Void
    typealias Generator = OrderedSetGenerator<T>
    
    private var itemsArray: [T] = []
    private var itemsSet: Set<T> = Set()
    subscript(index: Int) -> T {
        get {
            assert(index < self.itemsArray.count, "Index must be smaller than the number of items")
            assert(index >= 0, "Index must be nonnegative")
            return self.itemsArray[index]
        }
        set {
            assert(index < self.itemsArray.count, "Index must be smaller than the number of items")
            assert(index >= 0, "Index must be nonnegative")
            self.itemsSet.remove(self.itemsArray[index])
            self.itemsArray[index] = newValue
            self.checkInvariants()
            self.itemsSet.add(newValue)
        }
    }
    
    public var didAdd: CallBack?
    public var didRemove: CallBack?
    public var willAdd: CallBack?
    public var willRemove: CallBack?
    
    public var count: Int {
        return self.itemsArray.count
    }
    
    public init() {
        
    }
    
    public init(initialValues: [T]){
        for item in initialValues {
            self.append(item)
        }
    }
    
    public func generate() -> Generator {
        return OrderedSetGenerator(set: self)
    }
    
    public mutating func append(item: T) {
        assert(!self.contains(item), "Cannot append an item that already belong to the set to begin with")
        self.willAdd?(self)
        self.itemsSet.add(item)
        self.itemsArray.append(item)
        self.checkInvariants()
        self.didAdd?(self)
    }
    
    public mutating func insert(item: T, atIndex index: Int) {
        assert(!self.contains(item), "Cannot add an item that already belong to the set to begin with")
        self.willAdd?(self)
        self.itemsSet.add(item)
        self.itemsArray.insert(item, atIndex: index)
        self.checkInvariants()
        self.didAdd?(self)
    }
    
    public mutating func swapItemsAtIndex(index1: Int, withItemAtIndex index2: Int) {
        assert(index1 < self.itemsArray.count, "Index must be smaller than the number of items")
        assert(index1 >= 0, "Index must be nonnegative")
        assert(index2 < self.itemsArray.count, "Index must be smaller than the number of items")
        assert(index2 >= 0, "Index must be nonnegative")
        let temp = self.itemsArray[index1]
        self.itemsArray[index1] = self.itemsArray[index2]
        self.itemsArray[index2] = temp
        self.checkInvariants()
    }
    
    public mutating func remove(item: T) {
        assert(self.contains(item), "Cannot remove an item that does not belong to the set to begin with")
        self.willRemove?(self)
        self.itemsSet.remove(item)
        let indexes = arrayFindIndexesOfElement(array: self.itemsArray, element: item)
        assert(indexes.count == 1, "True by invariant")
        self.itemsArray.removeAtIndex(indexes[0])
        self.checkInvariants()
        self.didRemove?(self)
    }
    
    public func contains(item: T) -> Bool {
        return self.itemsSet.contains(item)
    }
    
    public func reduce<U>(initial: U, combine: (U, T) -> U) -> U {
        return self.itemsArray.reduce(initial, combine: combine)
    }
    
    public func map<U: Hashable>(transform: T->U)->OrderedSet<U> {
        return OrderedSet<U>(initialValues: self.itemsArray.map(transform))
    }
    
    private func checkInvariants() {
        if debug {
            assert(self.itemsSet.count == self.itemsArray.count, "Item counts must be equal")
            for item in self.itemsArray {
                assert(self.itemsSet.contains(item), "Set and array must contain the same values")
            }
        }
    }
    
    public func toArray() -> [T] {
        return self.itemsArray.map { $0 }
    }
}

public func == <T: Hashable> (lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> Bool {
    return lhs.count == rhs.count && lhs.toArray() == rhs.toArray()
}

public struct OrderedSetGenerator<T: Hashable>: GeneratorType {
    
    typealias Element = T
    
    private var items: [T]
    private var index = 0
    
    init(set: OrderedSet<T>){
        self.items = set.itemsArray
    }
    
    public mutating func next()->T? {
        if index < self.items.count {
            index++
            return self.items[index - 1]
        }
        return nil
    }
}