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
    override func awakeFromNib() {
        super.awakeFromNib()
        self.startLabel.textColor = Settings.currentSettings.colorScheme.textColor
        self.toLabel.textColor = Settings.currentSettings.colorScheme.textColor
        self.toLabel.text = "\u{2192}"
        self.toLabel.font = UIFont.systemFontOfSize(UIFont.labelFontSize() * 1.5)
        self.endLabel.textColor = Settings.currentSettings.colorScheme.textColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
