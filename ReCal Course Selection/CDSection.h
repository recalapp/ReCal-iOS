//
//  CDSection.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourse, CDSectionMeeting;

@interface CDSection : CDServerObject

@property (nonatomic, retain) NSString * sectionTypeCode;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) CDCourse *course;
@property (nonatomic, retain) NSSet *meetings;
@end

@interface CDSection (CoreDataGeneratedAccessors)

- (void)addMeetingsObject:(CDSectionMeeting *)value;
- (void)removeMeetingsObject:(CDSectionMeeting *)value;
- (void)addMeetings:(NSSet *)values;
- (void)removeMeetings:(NSSet *)values;

@end
