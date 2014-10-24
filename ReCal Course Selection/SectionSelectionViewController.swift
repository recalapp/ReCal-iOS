//
//  SectionSelectionViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class SectionSelectionViewController: UIViewController, UICollectionViewDelegate {

    private var courses = [Course]()
    
    private var sections: [Section] {
        return self.courses.reduce([], combine: { (allSections, course) in
            return allSections + course.sections
        })
    }
    
    private func populateDummyData() {
        let start = NSDateComponents()
        start.hour = 8
        start.minute = 0
        let end = NSDateComponents()
        end.hour = 10
        end.minute = 0
        let section1 = Section(type: .Precept, sectionNumber: 1, startTime: start, endTime: end, days: [.Monday, .Tuesday])
        let course1 = Course(sections: [section1])
        self.courses = [course1]
    }
    
    @IBOutlet weak var scheduleView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateDummyData()
        let dataSource = ScheduleCollectionViewDataSource()
        let layout = self.scheduleView.collectionViewLayout as CollectionViewCalendarWeekLayout
        dataSource.events = self.sections.map { $0 } // TODO this is a workaround, must remove once swift is fixed
        layout.dataSource = dataSource
        self.scheduleView.dataSource = dataSource
        self.scheduleView.delegate = self
        dataSource.registerReusableViewsWithCollectionView(self.scheduleView, forLayout: self.scheduleView.collectionViewLayout)
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

