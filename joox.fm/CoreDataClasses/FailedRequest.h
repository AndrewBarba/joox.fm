//
//  FailedRequest.h
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JooxList;

@interface FailedRequest : NSManagedObject

@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSString * page;
@property (nonatomic, retain) JooxList *list;

@end
