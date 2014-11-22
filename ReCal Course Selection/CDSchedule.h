//
//  CDSchedule.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourse, CDSection, CDSemester;

@interface CDSchedule : CDServerObject

@property (nonatomic, retain) id enrolledCoursesOrder;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id courseColorMap;
@property (nonatomic, retain) id courseColorManager;
@property (nonatomic, retain) NSSet *enrolledCourses;
@property (nonatomic, retain) NSSet *enrolledSections;
@property (nonatomic, retain) CDSemester *semester;
@end

@interface CDSchedule (CoreDataGeneratedAccessors)

- (void)addEnrolledCoursesObject:(CDCourse *)value;
- (void)removeEnrolledCoursesObject:(CDCourse *)value;
- (void)addEnrolledCourses:(NSSet *)values;
- (void)removeEnrolledCourses:(NSSet *)values;

- (void)addEnrolledSectionsObject:(CDSection *)value;
- (void)removeEnrolledSectionsObject:(CDSection *)value;
- (void)addEnrolledSections:(NSSet *)values;
- (void)removeEnrolledSections:(NSSet *)values;

@end
