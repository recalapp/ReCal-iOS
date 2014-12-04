//
//  EventCollectionViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var leftBorderView: UIView!
    var event: ScheduleCollectionViewDataSource.ScheduleEvent? = nil {
        didSet {
            if let event = self.event {
                switch Settings.currentSettings.scheduleDisplayTextStyle {
                case .CourseNumber:
                    self.eventTitleLabel.text = event.course.displayText
                case .SectionName:
                    self.eventTitleLabel.text = event.section.displayText
                }
                
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
        self.leftBorderView.backgroundColor = self.event?.courseColor.highlightedColor
        if selected {
            self.backgroundColor = self.event?.courseColor.highlightedColor
            self.eventTitleLabel.textColor = self.event?.courseColor.normalColor
        } else {
            self.backgroundColor = self.event?.courseColor.normalColor
            self.eventTitleLabel.textColor = self.event?.courseColor.highlightedColor
        }
    }
}
