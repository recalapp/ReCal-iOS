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
    
    override func awakeFromNib() {
        self.centerLabel.textColor = Settings.currentSettings.colorScheme.textColor
    }

}
