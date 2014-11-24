//
//  Cache.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

final public class Cache<Key: Hashable, Value>: SequenceType {
    
    public typealias GeneratorType = CacheGenerator<Key, Value>
    public func generate() -> GeneratorType {
        return CacheGenerator<Key, Value>(cache: self)
    }
    
    private var cacheDictionary = [Key: Value]()
    
    public var itemConstructor: ((Key)->Value)?
    
    public var willClear: ((Cache<Key, Value>)->Void)?
    
    public var didClear: ((Cache<Key, Value>)->Void)?
    
    public var keys: LazyBidirectionalCollection<MapCollectionView<Dictionary<Key, Value>, Key>> {
        return self.cacheDictionary.keys
    }
    
    public var values: LazyBidirectionalCollection<MapCollectionView<Dictionary<Key, Value>, Value>> {
        return self.cacheDictionary.values
    }

    public var count: Int {
        return self.cacheDictionary.count
    }
    
    public var isEmpty: Bool {
        return self.count == 0
    }

    public init() {
        
    }
    
    public func clearCache() {
        self.willClear?(self)
        self.cacheDictionary.removeAll(keepCapacity: true)
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
            return self.cacheDictionary.values.first!
        }
        set {
            self.cacheDictionary[key] = newValue
        }
    }
    
    public func preloadDataForKey(key: Key) {
        if self.cacheDictionary[key] != nil {
            return
        }
        if let itemConstructor = self.itemConstructor {
            let computed = itemConstructor(key)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if self.cacheDictionary[key] == nil {
                    println("preload successful")
                    self.cacheDictionary[key] = computed
                }
            })
        } else {
            assert(false, "ItemConstructor must be provided before first call to cache")
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

public struct CacheGenerator<Key: Hashable, Value>: GeneratorType {
    private var cache: Cache<Key, Value>
    private var keysStack = Stack<Key>()
    init(cache: Cache<Key, Value>)
    {
        self.cache = cache
        for key in self.cache.keys {
            self.keysStack.push(key)
        }
    }
    
    public mutating func next()->(Key, Value)? {
        if let key = self.keysStack.pop() {
            return (key, self.cache[key])
        }
        return nil
    }
}