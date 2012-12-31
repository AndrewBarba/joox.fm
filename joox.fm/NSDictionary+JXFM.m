//
//  NSDictionary+JXFM.m
//  joox.fm
//
//  Created by Andrew Barba on 6/13/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "NSDictionary+JXFM.h"

@implementation NSDictionary (JXFM)
-(NSInteger)ID
{
    return [self[@"id"] integerValue];
}
-(NSString *)jooxID;
{
    return self[@"joox_id"];
}
-(NSInteger)playlistID
{
    return [self[@"playlist_id"] integerValue];
}
-(NSInteger)partyID
{
    return [self[@"party_id"] integerValue];
}
-(NSString *)facebookID
{
    return self[@"fb"] ? self[@"fb"] : self[@"user_fb"];
}

-(NSDate *)timestamp
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:3600*1];
    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [format dateFromString:self[@"timestamp"]];
}

-(NSString *)firstName
{
    return self[@"first_name"];
}
-(NSString *)lastName
{
    return self[@"last_name"];
}
-(NSString *)fullName
{
    return self[@"full_name"];
}
-(NSMutableDictionary *)tracks
{
    return [self[@"tracks"] mutableCopy];
}
-(NSMutableDictionary *)users
{
    return self[@"users"];
}

-(NSString *)srcForTrackWithService:(NSString *)service
{
    if ([service isEqualToString:ServiceYouTube]) {
        return self[@"id"];
    }
    
    if ([service isEqualToString:ServiceSoundCloud]) {
        return self[@"id"];
    }
    
    if ([service isEqualToString:ServiceGrooveShark]) {
        return self[@"SongID"];
    }
    
    return nil;
}

@end
