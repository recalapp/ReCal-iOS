//
//  CDSection.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/12/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourse, CDEvent, CDSectionEnrollment;

@interface CDSection : CDServerObject

@property (nonatomic, retain) NSString * sectionTitle;
@property (nonatomic, retain) NSString * sectionTypeCode;
@property (nonatomic, retain) CDCourse *course;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSSet *enrolments;
@end

@interface CDSection (CoreDataGeneratedAccessors)

- (void)addEventsObject:(CDEvent *)value;
- (void)removeEventsObject:(CDEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

- (void)addEnrolmentsObject:(CDSectionEnrollment *)value;
- (void)removeEnrolmentsObject:(CDSectionEnrollment *)value;
- (void)addEnrolments:(NSSet *)values;
- (void)removeEnrolments:(NSSet *)values;

@end
