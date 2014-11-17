//
//  SettingsSwitchTableViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/17/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class SettingsSwitchTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    weak var delegate: SettingsSwitchTableViewCellDelegate?
    
    private var notificationObservers: [AnyObject] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let updateColorScheme: ()->Void = {
            self.label.textColor = Settings.currentSettings.colorScheme.textColor
            self.switchControl.onTintColor = Settings.currentSettings.colorScheme.actionableTextColor
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
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        assert(self.switchControl == sender)
        self.delegate?.settingsSwitchTableViewCell(self, valueDidChange: self.switchControl.on)
    }
}

protocol SettingsSwitchTableViewCellDelegate: class {
    func settingsSwitchTableViewCell(cell: SettingsSwitchTableViewCell, valueDidChange selected: Bool)
}