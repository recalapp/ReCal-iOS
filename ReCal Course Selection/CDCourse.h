//
//  CDCourse.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourseListings, CDSection, CDSemester;

@interface CDCourse : CDServerObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * courseDescription;
@property (nonatomic, retain) CDSemester *semester;
@property (nonatomic, retain) NSSet *sections;
@property (nonatomic, retain) NSSet *courseListings;
@end

@interface CDCourse (CoreDataGeneratedAccessors)

- (void)addSectionsObject:(CDSection *)value;
- (void)removeSectionsObject:(CDSection *)value;
- (void)addSections:(NSSet *)values;
- (void)removeSections:(NSSet *)values;

- (void)addCourseListingsObject:(CDCourseListings *)value;
- (void)removeCourseListingsObject:(CDCourseListings *)value;
- (void)addCourseListings:(NSSet *)values;
- (void)removeCourseListings:(NSSet *)values;

@end
