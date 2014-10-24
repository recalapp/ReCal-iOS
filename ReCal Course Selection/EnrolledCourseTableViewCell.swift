//
//  EnrolledCourseTableViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/24/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class EnrolledCourseTableViewCell: UITableViewCell {

    var course: Course? = nil {
        didSet {
            if oldValue != course {
                self.refresh()
            }
        }
    }
    var sectionTypes: [SectionType] {
        if let course = self.course {
            return course.sections.reduce([], combine: { (var allSectionTypes, section) in
                if !arrayContainsElement(array: allSectionTypes, element: section.type) {
                    allSectionTypes.append(section.type)
                }
                return allSectionTypes
            })
        }
        return []
    }
    var sectionPickerControls = Stack<SlidingSelectionControl>()
    var expanded: Bool = false {
        didSet {
            if oldValue != expanded {
                self.refresh()
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

    }
    
    /// return all sections with the specified section type
    private func sectionsWithType(sectionType: SectionType) -> [Section] {
        if let course = self.course {
            return course.sections.filter { $0.type == sectionType }
        }
        return []
    }
    
    /// refresh the content of cell
    private func refresh() {
        // course title
        if let course = self.course {
            self.courseLabel.text = course.displayText
        } else {
            self.courseLabel.text = ""
        }
        
        // section pickers
        while let sectionPicker = self.sectionPickerControls.pop() {
            sectionPicker.removeFromSuperview()
        }
        if self.expanded {
            let sectionTypes = self.sectionTypes
            var prev: UIView = self.courseLabel
            for sectionType in sectionTypes {
                let sections = self.sectionsWithType(sectionType)
                let titles = ["All precepts"] + sections.map { $0.displayText }
                let slidingSelectionControl = SlidingSelectionControl(items: titles, initialSelection: 0)
                slidingSelectionControl.preferredMaxLayoutWidth = self.contentView.bounds.size.width
                self.contentView.addSubview(slidingSelectionControl)
                let topConstraint = NSLayoutConstraint(item: slidingSelectionControl, attribute: .Top, relatedBy: .Equal, toItem: prev, attribute: .Bottom, multiplier: 1, constant: 8)
                let leadingConstraint = NSLayoutConstraint(item: slidingSelectionControl, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1, constant: 0)
                let trailingConstraint = NSLayoutConstraint(item: slidingSelectionControl, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1, constant: 0)
                self.contentView.addConstraints([topConstraint, leadingConstraint, trailingConstraint])
                prev = slidingSelectionControl
                self.sectionPickerControls.push(slidingSelectionControl)
            }
            if prev != self.courseLabel {
                let bottomConstraint = NSLayoutConstraint(item: prev, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1, constant: -8)
                self.contentView.addConstraint(bottomConstraint)
            }
        }
    }

}
