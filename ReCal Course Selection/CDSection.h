//
//  CDSection.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 3/29/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourse, CDSectionMeeting;

@interface CDSection : CDServerObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sectionTypeCode;
@property (nonatomic, retain) CDCourse *course;
@property (nonatomic, retain) NSSet *meetings;
@end

@interface CDSection (CoreDataGeneratedAccessors)

- (void)addMeetingsObject:(CDSectionMeeting *)value;
- (void)removeMeetingsObject:(CDSectionMeeting *)value;
- (void)addMeetings:(NSSet *)values;
- (void)removeMeetings:(NSSet *)values;

@end
