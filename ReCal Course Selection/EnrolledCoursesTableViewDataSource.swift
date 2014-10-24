//
//  EnrolledCoursesTableViewDataSource.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/24/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

let courseCellIdentifier = "CourseCell"

class EnrolledCoursesTableViewDataSource: NSObject, UITableViewDataSource {
    
    var enrolledCourses = [Course]()
    
    override init() {
        super.init()
    }
    
    func courseForIndexPath(indexPath: NSIndexPath) -> Course {
        assert(indexPath.row < enrolledCourses.count, "Invalid index path")
        return self.enrolledCourses[indexPath.row]
    }
    
    // MARK: - Table View Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(courseCellIdentifier, forIndexPath: indexPath) as EnrolledCourseTableViewCell
        cell.course = self.courseForIndexPath(indexPath)
        return cell
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.enrolledCourses.count
    }
}
