//
//  CourseSelectionViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let courseCellIdentifier = "CourseCell"

class CourseSelectionViewController: DoubleSidebarViewController, UICollectionViewDelegate, UITableViewDelegate, ScheduleCollectionViewDataSourceDelegate, EnrolledCoursesTableViewDataSourceDelegate {
    
    // MARK: - Variables
    private let enrolledCoursesTableViewDataSource = EnrolledCoursesTableViewDataSource()
    private let scheduleCollectionViewDataSource = ScheduleCollectionViewDataSource()
    /// The width of the sidebars
    override var sidebarWidth: CGFloat {
        get {
            return self.view.bounds.size.width / 4.0
        }
    }
    
    // MARK: Models
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
                        // check how many sections there are for this type
                        let sections = course.sections.filter { $0.type == sectionType }
                        if sections.count == 1 {
                            typeEnrollment[sectionType] = .Enrolled(sections[0])
                        } else {
                            typeEnrollment[sectionType] = .Unenrolled
                        }
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
    
    // MARK: Views
    private var scheduleView: UICollectionView!
    private var enrolledCoursesView: UITableView!
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.leftSidebarCoverText = "SEARCH"
        self.rightSidebarCoverText = "ENROLLED"
        self.populateDummyData()
        self.initializeScheduleView()
        self.initializeEnrolledCoursesView()
    }
    private func populateDummyData() {
        var start = NSDateComponents()
        start.hour = 8
        start.minute = 30
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
        start = NSDateComponents()
        start.hour = 13
        start.minute = 30
        end = NSDateComponents()
        end.hour = 14
        end.minute = 50
        let section3 = Section(type: .Precept, sectionNumber: 3, startTime: start, endTime: end, days:[.Tuesday, .Thursday])
        start = NSDateComponents()
        start.hour = 15
        start.minute = 0
        end = NSDateComponents()
        end.hour = 16
        end.minute = 20
        let lecture1 = Section(type: .Lecture, sectionNumber: 1, startTime: start, endTime: end, days: [.Monday, .Wednesday, .Friday])
        let course1 = Course(departmentCode: "COS", courseNumber: 333, color: UIColor.greenColor(), sections: [lecture1, section1, section2, section3])
        start = NSDateComponents()
        start.hour = 11
        start.minute = 0
        end = NSDateComponents()
        end.hour = 11
        end.minute = 50
        let section4 = Section(type: .Precept, sectionNumber: 1, startTime: start, endTime: end, days: [.Monday, .Tuesday, .Wednesday, .Friday])
        let course2 = Course(departmentCode: "ELE", courseNumber: 396, color: UIColor.orangeColor(), sections: [section4])
        self.courses = [course1, course2]
    }
    
    private func initializeScheduleView(){
        self.scheduleView = UICollectionView(frame: CGRectZero, collectionViewLayout: CollectionViewCalendarWeekLayout())
        self.scheduleView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.primaryContentView.addSubview(self.scheduleView)
        self.primaryContentView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(self.scheduleView, inParentView: self.primaryContentView, withInsets: UIEdgeInsetsZero))
        
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
        self.enrolledCoursesView = UITableView()
        self.enrolledCoursesView.backgroundColor = UIColor.darkGrayColor()
        self.enrolledCoursesView.separatorStyle = .None
        self.enrolledCoursesView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.enrolledCoursesView.registerNib(UINib(nibName: "EnrolledCourseTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: courseCellIdentifier)
        self.rightSidebarContentView.addSubview(self.enrolledCoursesView)
        self.rightSidebarContentView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(self.enrolledCoursesView, inParentView: self.rightSidebarContentView, withInsets: UIEdgeInsetsZero))
        
        self.enrolledCoursesTableViewDataSource.delegate = self
        self.enrolledCoursesTableViewDataSource.enrolledCourses = self.courses
        self.enrolledCoursesTableViewDataSource.enrollments = self.enrollments
        self.enrolledCoursesView.dataSource = self.enrolledCoursesTableViewDataSource
        self.enrolledCoursesView.delegate = self
        self.enrolledCoursesView.reloadData()
    }
    
    // MARK: - Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.enrolledCoursesView {
            self.enrolledCoursesTableViewDataSource.handleSelectionInTableView(tableView, forRowAtIndexPath: indexPath)
        }
    }
    
    // MARK: - Collection View Delegate
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.scheduleView {
            self.scheduleCollectionViewDataSource.handleDeselectionInCollectionView(collectionView, forItemAtIndexPath: indexPath)
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.scheduleView {
            self.scheduleCollectionViewDataSource.handleSelectionInCollectionView(collectionView, forItemAtIndexPath: indexPath)
        }
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
}
