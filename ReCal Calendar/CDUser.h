//
//  CDUser.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/12/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDSectionEnrollment;

@interface CDUser : CDServerObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *enrollments;
@end

@interface CDUser (CoreDataGeneratedAccessors)

- (void)addEnrollmentsObject:(CDSectionEnrollment *)value;
- (void)removeEnrollmentsObject:(CDSectionEnrollment *)value;
- (void)addEnrollments:(NSSet *)values;
- (void)removeEnrollments:(NSSet *)values;

@end
