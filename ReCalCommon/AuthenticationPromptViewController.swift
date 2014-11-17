//
//  AuthenticationPromptViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/9/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public class AuthenticationPromptViewController: UIViewController {
    
    @IBOutlet weak public var titleLabel: UILabel!
    @IBOutlet weak public var authenticateButton: UIButton!
    
    private var notificationObservers: [AnyObject] = []
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let updateWithColorScheme: (ColorScheme)->Void = {(colorScheme) in
            self.view.backgroundColor = colorScheme.accessoryBackgroundColor
            self.titleLabel.textColor = colorScheme.textColor
            self.authenticateButton.backgroundColor = colorScheme.actionableTextColor
            self.authenticateButton.setTitleColor(colorScheme.alternateActionableTextColor, forState: UIControlState.Normal)
        }
        updateWithColorScheme(Settings.currentSettings.colorScheme)
        
        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateWithColorScheme(Settings.currentSettings.colorScheme)
        }
        self.notificationObservers.append(observer1)
        // Do any additional setup after loading the view.
    }
    
    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction public func authenticateButtonTapped(sender: UIButton) {
        Settings.currentSettings.authenticator.authenticate()
    }
}
