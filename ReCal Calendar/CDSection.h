//
//  CDSection.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/11/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDCourse, CDEvent;

@interface CDSection : CDServerObject

@property (nonatomic, retain) NSString * sectionTitle;
@property (nonatomic, retain) NSString * sectionTypeCode;
@property (nonatomic, retain) CDCourse *course;
@property (nonatomic, retain) NSSet *events;
@end

@interface CDSection (CoreDataGeneratedAccessors)

- (void)addEventsObject:(CDEvent *)value;
- (void)removeEventsObject:(CDEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
