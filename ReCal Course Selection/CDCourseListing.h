//
//  CDCourseListing.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/6/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDCourse;

@interface CDCourseListing : NSManagedObject

@property (nonatomic, retain) NSString * courseNumber;
@property (nonatomic, retain) NSString * departmentCode;
@property (nonatomic, retain) NSNumber * isPrimary;
@property (nonatomic, retain) CDCourse *course;

@end
