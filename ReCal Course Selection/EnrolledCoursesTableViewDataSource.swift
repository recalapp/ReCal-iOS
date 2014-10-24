//
//  EnrolledCoursesTableViewDataSource.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/24/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

let courseCellIdentifier = "CourseCell"

class EnrolledCoursesTableViewDataSource: NSObject, UITableViewDataSource {
    
    var enrollments = Dictionary<Course, Dictionary<SectionType, SectionEnrollment>>()
    var enrolledCourses = [Course]()
    var selectedIndexPath: NSIndexPath?
    
    func courseForIndexPath(indexPath: NSIndexPath) -> Course {
        assert(indexPath.row < enrolledCourses.count, "Invalid index path")
        return self.enrolledCourses[indexPath.row]
    }
    
    // MARK: - Table View Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(courseCellIdentifier, forIndexPath: indexPath) as EnrolledCourseTableViewCell
        cell.expanded = indexPath == self.selectedIndexPath
        let course = self.courseForIndexPath(indexPath)
        cell.course = course
        cell.enrollmentsBySectionType = self.enrollments[course]!
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
            return
        }
        let oldSelectedOpt = self.selectedIndexPath
        self.selectedIndexPath = indexPath
        if let oldSelected = oldSelectedOpt {
            tableView.reloadRowsAtIndexPaths([oldSelected, indexPath], withRowAnimation: .Fade)
        } else {
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}
