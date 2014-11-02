//
//  CourseSearchResultTableViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/2/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class CourseSearchResultTableViewCell: UITableViewCell {

    var course: Course? {
        didSet {
            self.refresh()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.lightBlackGrayColor()
        self.tintColor = UIColor.lightTextColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func refresh() {
        if let course = self.course {
            self.textLabel.text = course.displayText
        }
    }

}
