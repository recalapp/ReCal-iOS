//
//  CDCourseListings.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourse;

@interface CDCourseListings : CDServerObject

@property (nonatomic, retain) NSString * departmentCode;
@property (nonatomic, retain) NSNumber * courseNumber;
@property (nonatomic, retain) NSNumber * isPrimary;
@property (nonatomic, retain) CDCourse *course;

@end
