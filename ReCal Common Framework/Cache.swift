//
//  Cache.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
public class Cache<Key: Hashable, Value> {
    
    private var cacheDictionary = [Key: Value]()
    
    public var itemConstructor: ((Key)->Value)?
    
    public var willClear: ((Cache<Key, Value>)->Void)?
    
    public var didClear: ((Cache<Key, Value>)->Void)?

    public var count: Int {
        return self.cacheDictionary.count
    }
    
    public var isEmpty: Bool {
        return self.count == 0
    }

    public init() {
        
    }
    
    public convenience init(itemConstructor: (Key)->Value) {
        self.init()
        self.itemConstructor = itemConstructor
    }
    
    public func clearCache() {
        self.willClear?(self)
        self.cacheDictionary = Dictionary<Key, Value>()
        self.didClear?(self)
    }
    
    public subscript(key: Key) -> Value{
        get {
            if let hit = self.cacheDictionary[key] {
                return hit
            }
            if let itemConstructor = self.itemConstructor {
                let computed = itemConstructor(key)
                self.cacheDictionary[key] = computed
                return computed
            }
            assert(false, "ItemConstructor must be provided before first call to cache")
        }
        set {
            self.cacheDictionary[key] = newValue
        }
    }
    
    public func reduce<Result>(initialValue: Result, combine: (Result, Key, Value)-> Result)->Result{
        var finalValue = initialValue
        for (key, value) in self.cacheDictionary {
            finalValue = combine(finalValue, key, value)
        }
        return finalValue
    }
    
    public func iter(apply: (Key, Value)->Void) {
        for (key, value) in self.cacheDictionary {
            apply(key, value)
        }
    }
    
    public func filter(shouldInclude: (Key, Value)->Bool)->[Value] {
        var filtered: [Value] = []
        for (key, value) in self.cacheDictionary {
            if shouldInclude(key, value) {
                filtered.append(value)
            }
        }
        return filtered
    }
}