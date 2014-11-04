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

@class CDCourse;

@interface CDSection : CDServerObject

@property (nonatomic, retain) NSNumber * startMinute;
@property (nonatomic, retain) NSNumber * startHour;
@property (nonatomic, retain) NSNumber * endHour;
@property (nonatomic, retain) NSString * daysStorage;
@property (nonatomic, retain) NSNumber * endMinute;
@property (nonatomic, retain) NSString * sectionTypeCode;
@property (nonatomic, retain) CDCourse *course;

@end
