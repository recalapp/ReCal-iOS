//
//  ClosureSearchPredicate.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/2/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public class ClosureSearchPredicate<Target, Query>: SearchPredicate<Target, Query> {
    public let closure: (Target, Query)->Bool
    public init(closure: (Target, Query)->Bool) {
        self.closure = closure
        super.init()
    }
    public override func evaluate(subject: Target, withQuery query: Query) -> Bool {
        return self.closure(subject, query)
    }
}