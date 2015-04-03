//
//  Json.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 4/1/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import Foundation

public class Json {
    private init() { }
    private class func serializeToData(dict: AnyObject) -> NSData? {
        var errorOpt: NSError?
        return NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.allZeros, error: &errorOpt)
    }
    private class func serializeToString(dict: AnyObject)-> String? {
        if let data = self.serializeToData(dict) {
            return NSString(data: data, encoding: NSUTF8StringEncoding)
        } else {
            return nil
        }
    }
    public class func serializeToData(dict: [String: AnyObject]) -> NSData? {
        return self.serializeToData(dict as AnyObject)
    }
    public class func serializeToData(array: [AnyObject]) -> NSData? {
        return self.serializeToData(array as AnyObject)
    }
    
    public class func serializeToString(dict: [String: AnyObject]) -> String? {
        return self.serializeToString(dict as AnyObject)
    }
    public class func serializeToString(array: [AnyObject]) -> String? {
        return self.serializeToString(array as AnyObject)
    }
}