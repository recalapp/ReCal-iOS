//
//  CDServerObject.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 4/3/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDServerObject : NSManagedObject

@property (nonatomic, retain) NSNumber * modified;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSNumber * isNew;

@end
