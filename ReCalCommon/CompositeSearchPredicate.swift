//
//  CompositeSearchPredicate.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/2/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public class CompositeSearchPredicate<Target, Query>: SearchPredicate<Target, Query> {
    public let childPredicates: [SearchPredicate<Target, Query>]
    
    public init(childPredicates: [SearchPredicate<Target, Query>]) {
        assert(childPredicates.count > 0, "Must have at least one child predicate")
        self.childPredicates = childPredicates
        super.init()
    }
    
    public override func evaluate(subject: Target, withQuery query: Query) -> Bool {
        assertionFailure("Abstract method")
        return false
    }
}