//
//  EventTimeTableViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class EventTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    private var notificationObservers: [AnyObject] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.toLabel.text = leftToRightArrow
        self.toLabel.font = UIFont.systemFontOfSize(UIFont.labelFontSize() * 1.5)
        
        let updateColorScheme: ()->Void = {
            self.endLabel.textColor = Settings.currentSettings.colorScheme.textColor
            self.startLabel.textColor = Settings.currentSettings.colorScheme.textColor
            self.toLabel.textColor = Settings.currentSettings.colorScheme.textColor
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
