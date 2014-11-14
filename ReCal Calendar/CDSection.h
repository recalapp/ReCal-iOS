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
@property (nonatomic, retain) NSSet *enrollments;
@end

@interface CDSection (CoreDataGeneratedAccessors)

- (void)addEventsObject:(CDEvent *)value;
- (void)removeEventsObject:(CDEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

- (void)addEnrollmentsObject:(CDSectionEnrollment *)value;
- (void)removeEnrollmentsObject:(CDSectionEnrollment *)value;
- (void)addEnrollments:(NSSet *)values;
- (void)removeEnrollments:(NSSet *)values;

@end
