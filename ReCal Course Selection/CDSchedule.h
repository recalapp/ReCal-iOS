//
//  CDSchedule.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 3/29/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDSemester;

@interface CDSchedule : CDServerObject

@property (nonatomic, retain) id availableColors;
@property (nonatomic, retain) id courseColorMap;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id enrolledCoursesIds;
@property (nonatomic, retain) id enrolledSectionsIds;
@property (nonatomic, retain) CDSemester *semester;

@end
