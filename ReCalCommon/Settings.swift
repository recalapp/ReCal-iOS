//
//  Settings.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/7/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public class Settings {
    private let persistentPropertiesFileName = "SettingsPersistentPropertiesFileName"
    private var persistentPropertiesFilePath: String! {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last?.stringByAppendingPathComponent(persistentPropertiesFileName)
    }
    public struct Notifications {
        public static let ThemeDidChange = "SettingsNotificationsThemeDidChange"
    }
    public struct UserDefaultsKeys {
        public static let Theme = "SettingsUserDefaultsKeysTheme"
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
            self.sharedUserDefaults.setInteger(theme.rawValue, forKey: UserDefaultsKeys.Theme)
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.ThemeDidChange, object: self)
        }
    }
    
    private(set) public var colorScheme: ColorScheme = DarkColorScheme()
    
    public var authenticator: Authenticator = Authenticator(rootViewController: UIViewController(), forAuthenticationUrlString: Urls.authentication, withLogOutUrlString: Urls.logOut)
    
    public var coreDataImporter: CoreDataImporter!
    
    public var serverCommunicator: ServerCommunicator = ServerCommunicator()
    
    public let sharedUserDefaults = NSUserDefaults(suiteName: "group.io.recal.ReCalShared")!
    
    public var persistentProperties: Dictionary<String, NSCoding> = Dictionary() {
        didSet {
            let _ = NSKeyedArchiver.archiveRootObject(persistentProperties, toFile: persistentPropertiesFilePath)
        }
    }
    
    public init() {
        if let persistentProperties = NSKeyedUnarchiver.unarchiveObjectWithFile(persistentPropertiesFilePath) as? Dictionary<String, NSCoding> {
            self.persistentProperties = persistentProperties
        }
    }
}

public enum Theme: Int {
    case Dark, Light
}