//
//  Settings.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/7/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public class Settings {
    public struct Notifications {
        public static let ThemeDidChange = "SettingsNotificationsThemeDidChange"
    }
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
    
    public var theme: Theme = .Dark {
        didSet {
            switch theme {
            case .Dark:
                colorScheme = DarkColorScheme()
            case .Light:
                colorScheme = LightColorScheme()
            }
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.ThemeDidChange, object: self)
        }
    }
    
    private(set) public var colorScheme: ColorScheme = DarkColorScheme()
    
    public var authenticator: Authenticator = Authenticator(rootViewController: UIViewController(), forAuthenticationUrlString: Urls.authentication, withLogOutUrlString: Urls.logOut)
    
    public var coreDataImporter: CoreDataImporter!
    
    public var serverCommunicator: ServerCommunicator = ServerCommunicator()
    
}

public enum Theme {
    case Dark, Light
}