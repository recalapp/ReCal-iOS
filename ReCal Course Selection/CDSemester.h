//
//  CDSemester.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourse;

@interface CDSemester : CDServerObject

@property (nonatomic, retain) NSString * termCode;
@property (nonatomic, retain) NSSet *courses;
@end

@interface CDSemester (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(CDCourse *)value;
- (void)removeCoursesObject:(CDCourse *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;

@end
