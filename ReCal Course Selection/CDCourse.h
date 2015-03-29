//
//  CDCourse.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 3/29/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourseListing, CDSection, CDSemester;

@interface CDCourse : CDServerObject

@property (nonatomic, retain) NSString * courseDescription;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *courseListings;
@property (nonatomic, retain) NSSet *sections;
@property (nonatomic, retain) CDSemester *semester;
@end

@interface CDCourse (CoreDataGeneratedAccessors)

- (void)addCourseListingsObject:(CDCourseListing *)value;
- (void)removeCourseListingsObject:(CDCourseListing *)value;
- (void)addCourseListings:(NSSet *)values;
- (void)removeCourseListings:(NSSet *)values;

- (void)addSectionsObject:(CDSection *)value;
- (void)removeSectionsObject:(CDSection *)value;
- (void)addSections:(NSSet *)values;
- (void)removeSections:(NSSet *)values;

@end
