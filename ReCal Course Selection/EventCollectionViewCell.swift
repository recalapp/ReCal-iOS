//
//  EventCollectionViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
//    let selectedAlpha: CGFloat = 1.0
//    let unselectedAlpha: CGFloat = 0.5
    
    var event: ScheduleCollectionViewDataSource.ScheduleEvent? = nil {
        didSet {
            if let event = self.event {
                self.eventTitleLabel.text = event.section.displayText
            } else {
                self.eventTitleLabel.text = ""
            }
            self.updateColor()
        }
    }
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    
    override var selected: Bool {
        didSet {
            self.updateColor()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateColor()
    }

    private func updateColor() {
        if selected {
            self.backgroundColor = self.event?.courseColor.highlightedColor
            self.eventTitleLabel.textColor = self.event?.courseColor.normalColor
        } else {
            self.backgroundColor = self.event?.courseColor.normalColor
            self.eventTitleLabel.textColor = self.event?.courseColor.highlightedColor
        }
    }
}
