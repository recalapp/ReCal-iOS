//
//  Util.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

func ASSERT_MAIN_THREAD() {
    assert(NSThread.isMainThread(), "This method must be called on the main thread");
}

extension Array {
    func find(isIncludedElement: T -> Bool) -> NSIndexSet {
        var indexes = NSMutableIndexSet()
        for (i, element) in enumerate(self) {
            if isIncludedElement(element) {
                indexes.addIndex(i)
            }
        }
        return indexes
    }
}