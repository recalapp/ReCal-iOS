//
//  CourseSearchResultTableViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/2/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class CourseSearchResultTableViewCell: UITableViewCell {

    var course: CDCourse? {
        didSet {
            self.refresh()
        }
    }
    private var notificationObservers: [AnyObject] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        let updateColorScheme: ()->Void = {
            let backgroundColor = self.selected ? Settings.currentSettings.colorScheme.selectedContentBackgroundColor : Settings.currentSettings.colorScheme.contentBackgroundColor
            self.backgroundColor = backgroundColor
            self.textLabel.textColor = Settings.currentSettings.colorScheme.textColor
            self.detailTextLabel?.textColor = Settings.currentSettings.colorScheme.textColor
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.backgroundColor = Settings.currentSettings.colorScheme.selectedContentBackgroundColor
        } else {
            self.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
        }
    }
    
    private func refresh() {
        if let course = self.course {
            self.textLabel.text = course.displayText
            self.detailTextLabel?.text = course.title
        }
    }
}
