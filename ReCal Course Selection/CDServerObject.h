//
//  CDServerObject.h
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 1/28/15.
//  Copyright (c) 2015 ReCal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDServerObject : NSManagedObject

@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSNumber * modified;

@end
