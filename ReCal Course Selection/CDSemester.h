//
//  CDSemester.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/6/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourse, CDSchedule;

@interface CDSemester : CDServerObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * termCode;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *courses;
@property (nonatomic, retain) NSSet *schedules;
@end

@interface CDSemester (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(CDCourse *)value;
- (void)removeCoursesObject:(CDCourse *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;

- (void)addSchedulesObject:(CDSchedule *)value;
- (void)removeSchedulesObject:(CDSchedule *)value;
- (void)addSchedules:(NSSet *)values;
- (void)removeSchedules:(NSSet *)values;

@end
