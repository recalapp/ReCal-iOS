//
//  CDSection.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/6/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourse, CDSchedule, CDSectionMeeting;

@interface CDSection : CDServerObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sectionTypeCode;
@property (nonatomic, retain) CDCourse *course;
@property (nonatomic, retain) NSSet *meetings;
@property (nonatomic, retain) NSSet *schedules;
@end

@interface CDSection (CoreDataGeneratedAccessors)

- (void)addMeetingsObject:(CDSectionMeeting *)value;
- (void)removeMeetingsObject:(CDSectionMeeting *)value;
- (void)addMeetings:(NSSet *)values;
- (void)removeMeetings:(NSSet *)values;

- (void)addSchedulesObject:(CDSchedule *)value;
- (void)removeSchedulesObject:(CDSchedule *)value;
- (void)addSchedules:(NSSet *)values;
- (void)removeSchedules:(NSSet *)values;

@end
