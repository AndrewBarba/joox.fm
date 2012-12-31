//
//  JXFMFetcher.h
//  joox.fm
//
//  Created by Andrew Barba on 6/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JooxList+Get.h"

@interface JXFMFetcher : NSObject <NSURLConnectionDelegate>
@property (nonatomic) NSInteger playlistID;
@property (nonatomic) NSInteger partyID;

-(JXFMFetcher *)initWithPartyID:(NSNumber *)partyID;
-(JXFMFetcher *)initWithPlaylistID:(NSNumber *)playlistID;
-(JXFMFetcher *)initWithList:(JooxList *)list;
-(void)start;
-(void)stop;
@end
