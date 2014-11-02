//
//  SearchPredicate.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/2/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public class SearchPredicate<Target, Query> {
    
    public init() {
        
    }
    public func evaluate(subject: Target, withQuery query: Query) -> Bool {
        assertionFailure("Abstract method")
    }
}