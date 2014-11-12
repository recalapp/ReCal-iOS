//
//  CDCourse.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/11/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourseListing, CDSection;

@interface CDCourse : CDServerObject

@property (nonatomic, retain) NSString * courseTitle;
@property (nonatomic, retain) NSString * courseDescription;
@property (nonatomic, retain) NSSet *sections;
@property (nonatomic, retain) NSSet *courseListings;
@end

@interface CDCourse (CoreDataGeneratedAccessors)

- (void)addSectionsObject:(CDSection *)value;
- (void)removeSectionsObject:(CDSection *)value;
- (void)addSections:(NSSet *)values;
- (void)removeSections:(NSSet *)values;

- (void)addCourseListingsObject:(CDCourseListing *)value;
- (void)removeCourseListingsObject:(CDCourseListing *)value;
- (void)addCourseListings:(NSSet *)values;
- (void)removeCourseListings:(NSSet *)values;

@end
