//
//  NotSearchPredicate.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/2/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public final class NotSearchPredicate<Target, Query>: SearchPredicate<Target, Query> {
    public let originalPredicate: SearchPredicate<Target, Query>
    public init(originalPredicate: SearchPredicate<Target, Query>) {
        self.originalPredicate = originalPredicate
        super.init()
    }
    
    public override func evaluate(subject: Target, withQuery query: Query) -> Bool {
        return !self.originalPredicate.evaluate(subject, withQuery: query)
    }
}