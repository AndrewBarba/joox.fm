//
//  NSDictionary+JXFM.h
//  joox.fm
//
//  Created by Andrew Barba on 6/13/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ServiceYouTube     @"youtube"
#define ServiceVimeo       @"vimeo"
#define ServiceSoundCloud  @"soundcloud"
#define ServiceGrooveShark @"grooveshark"

@interface NSDictionary (JXFM)
-(NSInteger)ID;
-(NSString *)jooxID;
-(NSInteger)playlistID;
-(NSInteger)partyID;
-(NSString *)facebookID;
-(NSDate *)timestamp;
-(NSString *)firstName;
-(NSString *)lastName;
-(NSString *)fullName;
-(NSMutableDictionary *)tracks;
-(NSMutableDictionary *)users;
-(NSString *)srcForTrackWithService:(NSString *)service;
@end
