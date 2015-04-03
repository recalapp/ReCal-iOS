//
//  UrlEncoding.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 4/1/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

import Foundation

public final class UrlEncoding {
    private init() {}
    public class func encodeParameters(#parameters: [String:String])->String {
        if parameters.count == 0 {
            return ""
        }
        var parametersString = ""
        for (key, value) in parameters {
            parametersString += "\(key.urlParameterEncoding())=\(value.urlParameterEncoding())&"
        }
        parametersString.substringToIndex(parametersString.endIndex.predecessor())
        return parametersString
    }
    
    public class func encodeParameters(#parameters: [String:String], encoding: NSStringEncoding)->NSData {
        return self.encodeParameters(parameters: parameters).dataUsingEncoding(encoding)!
    }
}