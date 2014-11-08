//
//  DayColumnHeaderView.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class DayColumnHeaderView: UICollectionReusableView {
    @IBOutlet weak var weekDayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.weekDayLabel.textColor = Settings.currentSettings.colorScheme.textColor
        // Initialization code
    }
    
}
