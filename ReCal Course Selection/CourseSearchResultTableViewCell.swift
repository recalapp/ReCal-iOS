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
        
        self.backgroundColor = ColorScheme.currentColorScheme.contentBackgroundColor
        self.textLabel.textColor = ColorScheme.currentColorScheme.textColor
        self.detailTextLabel?.textColor = ColorScheme.currentColorScheme.textColor
        //self.tintColor = ColorScheme.currentColorScheme.textColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.backgroundColor = ColorScheme.currentColorScheme.selectedContentBackgroundColor
        } else {
            self.backgroundColor = ColorScheme.currentColorScheme.contentBackgroundColor
        }
    }
    
    private func refresh() {
        if let course = self.course {
            self.textLabel.text = course.displayText
            self.detailTextLabel?.text = course.title
        }
    }

}
