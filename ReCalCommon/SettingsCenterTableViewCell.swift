//
//  SettingsCenterTableViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/16/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class SettingsCenterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var centerLabel: UILabel!
    private var notificationObservers: [AnyObject] = []
    
    override func awakeFromNib() {
        
        let updateColorScheme: ()->Void = {
            self.centerLabel.textColor = Settings.currentSettings.colorScheme.textColor
        }
        updateColorScheme()
        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateColorScheme()
        }
        self.notificationObservers.append(observer1)
    }
    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }

}
