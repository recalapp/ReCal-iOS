//
//  CoreDataToCourseStructConverter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class CoreDataToCourseStructConverter {
    
    private func courseListingStructFromCoreData(listing: CDCourseListing) -> CourseListing {
        return CourseListing(courseNumber: listing.courseNumber, departmentCode: listing.departmentCode, isPrimary: listing.isPrimary.boolValue)
    }
    
    private func sectionMeetingStructFromCoreData(sectionMeeting: CDSectionMeeting) -> SectionMeeting {
        return SectionMeeting(startTime: sectionMeeting.startTime, endTime: sectionMeeting.endTime, location: sectionMeeting.location, days: sectionMeeting.days)
    }
    
    private func sectionStructFromCoreData(section: CDSection) -> Section {
        let meetings = section.meetings.allObjects.map { self.sectionMeetingStructFromCoreData($0 as CDSectionMeeting) }
        return Section(type: section.sectionType, sectionName: section.name, sectionMeetings: meetings)
    }
    
    func courseStructFromCoreData(course: CDCourse) -> Course {
        let listings = course.courseListings.allObjects.map { self.courseListingStructFromCoreData($0 as CDCourseListing) }
        let sections = course.sections.allObjects.map { self.sectionStructFromCoreData($0 as CDSection) }.sorted { $0.sectionName < $1.sectionName }
        let courseStruct = Course(courseListings: listings, title: course.title, courseDescription: course.courseDescription, color: UIColor.greenColor(), sections: sections)
        return courseStruct
    }
}