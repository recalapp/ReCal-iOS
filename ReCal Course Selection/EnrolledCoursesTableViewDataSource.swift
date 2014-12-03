//
//  EnrolledCoursesTableViewDataSource.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/24/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let courseCellIdentifier = "CourseCell"

class EnrolledCoursesTableViewDataSource: NSObject, UITableViewDataSource, EnrolledCourseTableViewCellDelegate {
    
    weak var delegate: EnrolledCoursesTableViewDataSourceDelegate?
    var enrollments: Dictionary<Course, Dictionary<SectionType, SectionEnrollmentStatus>> = Dictionary<Course, Dictionary<SectionType, SectionEnrollmentStatus>>() {
        didSet {
            if (!arraysContainSameElements(oldValue.keys.array, enrollments.keys.array)) {
                // enrolled courses changed. invalidate old selection
                self.selectedIndexPath = nil
            }
        }
    }
    
    var courseColorMap: Dictionary<Course, CourseColor> = Dictionary()
    var enrolledCourses: [Course] {
        return self.enrollments.keys.array
    }
    var selectedIndexPath: NSIndexPath?
    
    func courseForIndexPath(indexPath: NSIndexPath) -> Course {
        assert(indexPath.row < enrolledCourses.count, "Invalid index path")
        return self.enrolledCourses[indexPath.row]
    }
    
    // MARK: - Table View Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(courseCellIdentifier, forIndexPath: indexPath) as EnrolledCourseTableViewCell
        let course = self.courseForIndexPath(indexPath)
        cell.enrollmentsBySectionType = self.enrollments[course]!
        cell.expanded = indexPath == self.selectedIndexPath
        // color must be set before course, as setting course forces a refresh
        cell.viewModel = EnrolledCourseCellViewModelAdapter(course: course, courseColor: self.courseColorMap[course]!)
        cell.delegate = self
        return cell
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.enrolledCourses.count
    }
    func handleSelectionInTableView(tableView: UITableView, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.selectedIndexPath == indexPath {
            self.selectedIndexPath = nil
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else {
            let oldSelectedOpt = self.selectedIndexPath
            self.selectedIndexPath = indexPath
            if let oldSelected = oldSelectedOpt {
                tableView.reloadRowsAtIndexPaths([oldSelected, indexPath], withRowAnimation: .Fade)
            } else {
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    // MARK: - Enrolled Course Table View Cell Delegate
    func enrollmentsDidChangeForEnrolledCourseTableViewCell(cell: EnrolledCourseTableViewCell) {
        let course = cell.viewModel?.course
        assert(course != nil, "Course is nil in cell")
        assert(self.enrollments[course!] != nil, "Invalid course found in cell")
        self.enrollments[course!] = cell.enrollmentsBySectionType
        self.delegate?.enrollmentsDidChangeForEnrolledCoursesTableViewDataSource(self)
    }
    func touchUpForEnrolledCourseTableViewCell(cell: EnrolledCourseTableViewCell) {
        let course = cell.viewModel?.course
        assert(course != nil, "Course is nil in cell")
        assert(self.enrollments[course!] != nil, "Invalid course found in cell")
        self.delegate?.enrollmentsDidStopChangingForEnrolledCoursesTableViewDataSource(self)
    }
    func shouldDeleteCourseForEnrolledCourseTableViewCell(cell: EnrolledCourseTableViewCell) {
        let course = cell.viewModel?.course
        assert(course != nil, "Course is nil in cell")
        assert(self.enrollments[course!] != nil, "Invalid course found in cell")
        self.delegate?.enrolledCoursesTableViewDataSource(self, shouldDeleteCourse: course!)
    }
    struct EnrolledCourseCellViewModelAdapter: EnrolledCourseCellViewModel {
        let color: UIColor
        let highlightedColor: UIColor
        let course: Course
        init(course: Course, courseColor: CourseColor) {
            self.course = course
            self.color = courseColor.normalColor
            self.highlightedColor = courseColor.highlightedColor
        }
    }
}

protocol EnrolledCoursesTableViewDataSourceDelegate: class {
    func enrollmentsDidChangeForEnrolledCoursesTableViewDataSource(dataSource: EnrolledCoursesTableViewDataSource)
    func enrollmentsDidStopChangingForEnrolledCoursesTableViewDataSource(dataSource: EnrolledCoursesTableViewDataSource)
    func enrolledCoursesTableViewDataSource(dataSource: EnrolledCoursesTableViewDataSource, shouldDeleteCourse course: Course)
}
