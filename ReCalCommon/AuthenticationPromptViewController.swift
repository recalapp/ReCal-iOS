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
    @IBOutlet weak var demoButton: UIButton!
    
    private var notificationObservers: [AnyObject] = []
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let updateWithColorScheme: (ColorScheme)->Void = {(colorScheme) in
            self.view.backgroundColor = colorScheme.accessoryBackgroundColor
            self.titleLabel.textColor = colorScheme.textColor
            self.authenticateButton.backgroundColor = colorScheme.actionableTextColor
            self.authenticateButton.setTitleColor(colorScheme.alternateActionableTextColor, forState: UIControlState.Normal)
            self.demoButton.backgroundColor = colorScheme.actionableTextColor
            self.demoButton.setTitleColor(colorScheme.alternateActionableTextColor, forState: UIControlState.Normal)
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
    
    @IBAction public func authenticateButtonTapped(sender: UIButton) {
        assert(sender === self.authenticateButton)
        Settings.currentSettings.authenticator.authenticate()
    }
    @IBAction func demoButtonTapped(sender: UIButton) {
        assert(sender === self.demoButton)
        let alertController = UIAlertController(title: "Demo Mode", message: "Demo mode allows you to try all the features of the app. However, nothing will be saved.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (_) -> Void in
            Settings.currentSettings.authenticator.logInAsDemo()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
