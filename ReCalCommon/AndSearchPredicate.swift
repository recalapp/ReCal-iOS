//
//  AndSearchPredicate.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/2/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public final class AndSearchPredicate<Target, Query>: CompositeSearchPredicate<Target, Query> {
    public override func evaluate(subject: Target, withQuery query: Query) -> Bool {
        for childPredicate in self.childPredicates {
            if !childPredicate.evaluate(subject, withQuery: query) {
                return false
            }
        }
        return true
    }
}