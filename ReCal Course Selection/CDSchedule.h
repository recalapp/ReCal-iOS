//
//  CDSchedule.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/6/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourse, CDSection, CDSemester;

@interface CDSchedule : CDServerObject

@property (nonatomic, retain) id courseSectionTypeEnrollments;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSOrderedSet *enrolledCourses;
@property (nonatomic, retain) NSSet *enrolledSections;
@property (nonatomic, retain) CDSemester *semester;
@end

@interface CDSchedule (CoreDataGeneratedAccessors)

- (void)insertObject:(CDCourse *)value inEnrolledCoursesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEnrolledCoursesAtIndex:(NSUInteger)idx;
- (void)insertEnrolledCourses:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEnrolledCoursesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEnrolledCoursesAtIndex:(NSUInteger)idx withObject:(CDCourse *)value;
- (void)replaceEnrolledCoursesAtIndexes:(NSIndexSet *)indexes withEnrolledCourses:(NSArray *)values;
- (void)addEnrolledCoursesObject:(CDCourse *)value;
- (void)removeEnrolledCoursesObject:(CDCourse *)value;
- (void)addEnrolledCourses:(NSOrderedSet *)values;
- (void)removeEnrolledCourses:(NSOrderedSet *)values;
- (void)addEnrolledSectionsObject:(CDSection *)value;
- (void)removeEnrolledSectionsObject:(CDSection *)value;
- (void)addEnrolledSections:(NSSet *)values;
- (void)removeEnrolledSections:(NSSet *)values;

@end
