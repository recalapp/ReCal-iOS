//
//  CDSectionEnrollment.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/12/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDSection, CDUser;

@interface CDSectionEnrollment : NSManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) CDUser *user;
@property (nonatomic, retain) CDSection *section;

@end
