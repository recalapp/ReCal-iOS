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
    weak var delegate: EnrolledCourseTableViewCellDelegate?
    var enrollmentsBySectionType = Dictionary<SectionType, SectionEnrollment>()
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
    var sectionPickerControls = Dictionary<SectionType, SlidingSelectionControl>()
    var expanded: Bool = false
    
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
        for (_, sectionPicker) in self.sectionPickerControls {
            sectionPicker.removeFromSuperview()
        }
        self.sectionPickerControls.removeAll(keepCapacity: true)
        if self.expanded {
            let sectionTypes = self.sectionTypes
            var prev: UIView = self.courseLabel
            for sectionType in sectionTypes {
                let sections = self.sectionsWithType(sectionType)
                let titles = ["All \(sectionType.displayText.pluralize())"] + sections.map { $0.displayText }
                var initialSelection = 0
                let enrollmentOpt = self.enrollmentsBySectionType[sectionType]
                assert(enrollmentOpt != nil, "Must pass a valid section enrollment dict")
                switch enrollmentOpt! {
                case .Unenrolled:
                    initialSelection = 0
                case .Enrolled(let section):
                    let indexes = arrayFindIndexesOfElement(array: sections, element: section)
                    assert(indexes.count == 1, "Section array cannot contain duplicate, and enrollment must be with an existing section")
                    initialSelection = indexes[0] + 1
                }
                
                let slidingSelectionControl = SlidingSelectionControl(items: titles, initialSelection: initialSelection)
                slidingSelectionControl.preferredMaxLayoutWidth = self.contentView.bounds.size.width
                slidingSelectionControl.defaultBackgroundColor = UIColor.blackColor()
                slidingSelectionControl.tintColor = UIColor.greenColor()
                slidingSelectionControl.layoutMargins = UIEdgeInsetsZero
                self.contentView.addSubview(slidingSelectionControl)
                let topConstraint = NSLayoutConstraint(item: slidingSelectionControl, attribute: .Top, relatedBy: .Equal, toItem: prev, attribute: .Bottom, multiplier: 1, constant: 8)
                let leadingConstraint = NSLayoutConstraint(item: slidingSelectionControl, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1, constant: 0)
                let trailingConstraint = NSLayoutConstraint(item: slidingSelectionControl, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1, constant: 0)
                self.contentView.addConstraints([topConstraint, leadingConstraint, trailingConstraint])
                prev = slidingSelectionControl
                self.sectionPickerControls[sectionType] = slidingSelectionControl
                slidingSelectionControl.addTarget(self, action: "handleEnrollmentSelectionChanged:", forControlEvents: UIControlEvents.ValueChanged)
            }
            
            // add bottom constraint if needed. courseLabel's constraint is set in the storyboard
            if prev != self.courseLabel {
                let bottomConstraint = NSLayoutConstraint(item: prev, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1, constant: -8)
                self.contentView.addConstraint(bottomConstraint)
            }
        }
    }
    
    func handleEnrollmentSelectionChanged(sender: SlidingSelectionControl) {
        for (sectionType, sectionPicker) in self.sectionPickerControls {
            if sectionPicker == sender {
                let oldEnrollment = self.enrollmentsBySectionType[sectionType]!
                if sender.selectedIndex == 0 {
                    self.enrollmentsBySectionType[sectionType] = .Unenrolled
                } else {
                    let section = self.sectionsWithType(sectionType)[sender.selectedIndex - 1]
                    self.enrollmentsBySectionType[sectionType] = .Enrolled(section)
                }
                if oldEnrollment != self.enrollmentsBySectionType[sectionType] {
                    self.delegate?.enrollmentsDidChangeForEnrolledCourseTableViewCell(self)
                }
                break
            }
        }
    }
}

protocol EnrolledCourseTableViewCellDelegate: class {
    func enrollmentsDidChangeForEnrolledCourseTableViewCell(cell: EnrolledCourseTableViewCell)
}
