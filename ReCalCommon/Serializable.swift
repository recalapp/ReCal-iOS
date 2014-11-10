//
//  Serializable.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/9/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public typealias SerializedDictionary = Dictionary<String, AnyObject>
public protocol Serializable {
    init(serializedDictionary: SerializedDictionary)
    func serialize() -> SerializedDictionary
}