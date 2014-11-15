//
//  CDEvent.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDServerObject.h"

@class CDSection;

@interface CDEvent : CDServerObject

@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSDate * eventEnd;
@property (nonatomic, retain) NSDate * eventStart;
@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSString * eventTypeCode;
@property (nonatomic, retain) NSString * agendaSection;
@property (nonatomic, retain) CDSection *section;

@end
