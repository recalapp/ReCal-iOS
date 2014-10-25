//
//  SectionSelectionViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class SectionSelectionViewController: UIViewController, UICollectionViewDelegate, UITableViewDelegate, EnrolledCoursesTableViewDataSourceDelegate, ScheduleCollectionViewDataSourceDelegate {
    
    private var enrollments = Dictionary<Course, Dictionary<SectionType, SectionEnrollment>>()
    
    private var courses: [Course] = [Course]() {
        didSet {
            // courses have been set. initialize enrollment to being unenrolled in all section types
            if oldValue != self.courses {
                self.enrollments.removeAll(keepCapacity: true)
                for course in self.courses {
                    var typeEnrollment = Dictionary<SectionType, SectionEnrollment>()
                    let sectionTypes = course.sections.reduce(Set<SectionType>(), combine: {(var set, section) in
                        set.add(section.type)
                        return set
                    })
                    for sectionType in sectionTypes {
                        typeEnrollment[sectionType] = .Unenrolled
                    }
                    self.enrollments[course] = typeEnrollment
                }
            }
        }
    }
    
    private var sections: [Section] {
        return self.courses.reduce([], combine: { (allSections, course) in
            return allSections + course.sections
        })
    }
    
    private let enrolledCoursesTableViewDataSource = EnrolledCoursesTableViewDataSource()
    private let scheduleCollectionViewDataSource = ScheduleCollectionViewDataSource()
    
    private func populateDummyData() {
        var start = NSDateComponents()
        start.hour = 8
        start.minute = 0
        var end = NSDateComponents()
        end.hour = 9
        end.minute = 50
        let section1 = Section(type: .Precept, sectionNumber: 1, startTime: start, endTime: end, days: [.Monday, .Wednesday])
        start = NSDateComponents()
        start.hour = 11
        start.minute = 0
        end = NSDateComponents()
        end.hour = 12
        end.minute = 20
        let section2 = Section(type: .Precept, sectionNumber: 2, startTime: start, endTime: end, days:[.Tuesday, .Thursday])
        let course1 = Course(departmentCode: "COS", courseNumber: 333, sections: [section1, section2])
        end = NSDateComponents()
        end.hour = 11
        end.minute = 50
        let section3 = Section(type: .Precept, sectionNumber: 1, startTime: start, endTime: end, days: [.Monday, .Wednesday, .Friday])
        let course2 = Course(departmentCode: "ELE", courseNumber: 396, sections: [section3])
        self.courses = [course1, course2]
    }
    
    @IBOutlet weak var enrolledCoursesView: UITableView!
    @IBOutlet weak var scheduleView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateDummyData()
        self.initializeScheduleView()
        self.initializeEnrolledCoursesView()
    }
    
    private func initializeScheduleView(){
        let dataSource = self.scheduleCollectionViewDataSource
        dataSource.delegate = self
        let layout = self.scheduleView.collectionViewLayout as CollectionViewCalendarWeekLayout
        dataSource.enrollments = self.enrollments
        dataSource.enrolledCourses = self.courses
        layout.dataSource = dataSource
        self.scheduleView.dataSource = dataSource
        self.scheduleView.delegate = self
        self.scheduleView.allowsMultipleSelection = true
        dataSource.registerReusableViewsWithCollectionView(self.scheduleView, forLayout: self.scheduleView.collectionViewLayout)
    }
    private func initializeEnrolledCoursesView(){
        self.enrolledCoursesTableViewDataSource.delegate = self
        self.enrolledCoursesTableViewDataSource.enrolledCourses = self.courses
        self.enrolledCoursesTableViewDataSource.enrollments = self.enrollments
        self.enrolledCoursesView.dataSource = self.enrolledCoursesTableViewDataSource
        self.enrolledCoursesView.delegate = self
        self.enrolledCoursesView.reloadData()
    }

    
    // MARK: - Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.enrolledCoursesTableViewDataSource.handleSelectionInTableView(tableView, forRowAtIndexPath: indexPath)
        
    }
    
    // MARK: - Collection View Delegate
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        self.scheduleCollectionViewDataSource.handleDeselectionInCollectionView(collectionView, forItemAtIndexPath: indexPath)
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.scheduleCollectionViewDataSource.handleSelectionInCollectionView(collectionView, forItemAtIndexPath: indexPath)
    }
    
    // MARK: - Enrolled Courses Table View Data Source Delegate
    func enrollmentsDidChangeForEnrolledCoursesTableViewDataSource(dataSource: EnrolledCoursesTableViewDataSource) {
        assert(dataSource == self.enrolledCoursesTableViewDataSource, "Wrong data source object for enrolled courses view")
        self.enrollments = dataSource.enrollments
        self.scheduleCollectionViewDataSource.enrollments = self.enrollments
        self.scheduleView.reloadData()
    }
    
    // MARK: - Schedule Collection View Data Source Delegate
    func enrollmentDidChangeForScheduleCollectionViewDataSource(dataSource: ScheduleCollectionViewDataSource) {
        assert(dataSource == self.scheduleCollectionViewDataSource, "Wrong data source object for schedule view")
        self.enrollments = dataSource.enrollments
        self.enrolledCoursesTableViewDataSource.enrollments = self.enrollments
        self.enrolledCoursesView.reloadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}