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
    
    override var highlighted: Bool {
        didSet {
            if highlighted {
                self.alpha = 0.5
            } else {
                self.alpha = 1
            }
        }
    }
    
    @IBOutlet weak var leftBorderView: UIView!
    var event: ScheduleCollectionViewDataSource.ScheduleEvent? = nil {
        didSet {
            self.updateText()
            self.updateColor()
        }
    }
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var alternativeEventTitleLabel: UILabel!
    
    override var selected: Bool {
        didSet {
            self.updateColor()
        }
    }

    private var notificationObservers: [AnyObject] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateColor()
        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ScheduleDisplayTextStyleDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            self.chooseTextLabel()
        }
        self.chooseTextLabel()
        self.notificationObservers.append(observer1)
    }

    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    private func updateText() {
        if let event = self.event {
            self.eventTitleLabel.text = event.course.displayText
            self.alternativeEventTitleLabel.text = event.section.displayText
        } else {
            self.alternativeEventTitleLabel.text = ""
            self.eventTitleLabel.text = ""
        }
    }
    
    private func chooseTextLabel() {
        switch Settings.currentSettings.scheduleDisplayTextStyle {
        case .SectionName:
            self.alternativeEventTitleLabel.hidden = false
            self.eventTitleLabel.hidden = true
        case .CourseNumber:
            self.alternativeEventTitleLabel.hidden = true
            self.eventTitleLabel.hidden = false
        }
    }
    
    private func updateColor() {
        self.leftBorderView.backgroundColor = self.event?.courseColor.highlightedColor
        if selected {
            self.backgroundColor = self.event?.courseColor.highlightedColor
            self.eventTitleLabel.textColor = self.event?.courseColor.normalColor
            self.alternativeEventTitleLabel.textColor = self.event?.courseColor.normalColor
        } else {
            self.backgroundColor = self.event?.courseColor.normalColor
            self.eventTitleLabel.textColor = self.event?.courseColor.highlightedColor
            self.alternativeEventTitleLabel.textColor = self.event?.courseColor.highlightedColor
        }
    }
}
