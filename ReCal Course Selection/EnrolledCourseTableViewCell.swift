//
//  EnrolledCourseTableViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/24/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class EnrolledCourseTableViewCell: UITableViewCell {

    var course: Course? = nil {
        didSet {
            if let course = self.course {
                self.courseLabel.text = course.displayText
            } else {
                self.courseLabel.text = ""
            }
        }
    }
    @IBOutlet weak var courseLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
