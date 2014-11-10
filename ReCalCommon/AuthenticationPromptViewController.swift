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
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
        self.titleLabel.textColor = Settings.currentSettings.colorScheme.textColor
        self.authenticateButton.backgroundColor = Settings.currentSettings.colorScheme.actionableTextColor
        self.authenticateButton.setTitleColor(Settings.currentSettings.colorScheme.textColor, forState: UIControlState.Normal)
        // Do any additional setup after loading the view.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction public func authenticateButtonTapped(sender: UIButton) {
        Settings.currentSettings.authenticator.authenticate()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
