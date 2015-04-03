//
//  StringUtil.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 4/3/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import Foundation

public extension Character {
    public func utf8Value() -> Int {
        let str = String(self)
        for s in str.utf8 {
            return Int(s)
        }
        return 0
    }
}
public extension String {
    public func contains(other: String, caseSensitive: Bool = true) -> Bool {
        return self.rangeOfString(other, options: caseSensitive ? NSStringCompareOptions.allZeros : NSStringCompareOptions.CaseInsensitiveSearch) != nil
    }
    public func isNumeric() -> Bool {
        return self.toInt() != nil
    }
    public func urlParameterEncoding() -> String {
        let queryCharacterSet: NSMutableCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as NSMutableCharacterSet
        queryCharacterSet.removeCharactersInRange(NSMakeRange(Character("&").utf8Value(), 1))
        queryCharacterSet.removeCharactersInRange(NSMakeRange(Character("=").utf8Value(), 1))
        queryCharacterSet.removeCharactersInRange(NSMakeRange(Character("?").utf8Value(), 1))
        return self.stringByAddingPercentEncodingWithAllowedCharacters(queryCharacterSet)!
    }
}