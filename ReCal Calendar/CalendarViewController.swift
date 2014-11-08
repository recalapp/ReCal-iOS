//
//  CalendarViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/8/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class CalendarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Settings.currentSettings.authenticator = Authenticator(rootViewController: self.view.window?.rootViewController ?? self, forAuthenticationUrlString: mobileLoggedInUrl)
        Settings.currentSettings.authenticator.authenticate()
        switch Settings.currentSettings.theme {
        case .Light:
            self.navigationController?.navigationBar.barStyle = .Default
        case .Dark:
            self.navigationController?.navigationBar.barStyle = .Black
        }
        self.view.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
