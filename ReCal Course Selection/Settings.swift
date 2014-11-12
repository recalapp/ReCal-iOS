//
//  Settings.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/7/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public class Settings {
    private struct Static {
        static var instance: Settings?
        static var token: dispatch_once_t = 0
    }
    public class var currentSettings: Settings {
        // thread safe singleton implementation. Taken from http://code.martinrue.com/posts/the-singleton-pattern-in-swift
        
        dispatch_once(&Static.token, {
            Static.instance = Settings()
        })
        return Static.instance!
    }
    
    public var theme: Theme = .Dark
    
    public var colorScheme: ColorScheme = DarkColorScheme()
    
    public var authenticator: Authenticator = Authenticator(rootViewController: UIViewController(), forAuthenticationUrlString: authenticationUrl, withLogOutUrlString: logOutUrl)
    
    public var coreDataImporter: CoreDataImporter = CoreDataImporter()
}

public enum Theme {
    case Dark, Light
}