//
//  Invite.h
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Invite : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * playlistID;
@property (nonatomic, retain) NSString * playlistName;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * userFB;
@property (nonatomic, retain) NSString * userName;

@end
