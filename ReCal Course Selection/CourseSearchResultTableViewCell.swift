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

    var course: Course? {
        didSet {
            self.refresh()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
        self.textLabel.textColor = Settings.currentSettings.colorScheme.textColor
        self.detailTextLabel?.textColor = Settings.currentSettings.colorScheme.textColor
        //self.tintColor = ColorScheme.currentColorScheme.textColor
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
