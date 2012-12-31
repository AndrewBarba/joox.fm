//
//  Joox.h
//  Jooxbot
//
//  Created by Andrew Barba on 6/1/12.
//  Copyright (c) 2012 WhatsApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#define BUILD_KEY      [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey]
#define REFRESH_DB_KEY [NSString stringWithFormat:@"joox_fm_%@",BUILD_KEY]
#define VERSION_KEY    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define ServiceYouTube     @"youtube"
#define ServiceVimeo       @"vimeo"
#define ServiceSoundCloud  @"soundcloud"
#define ServiceGrooveShark @"grooveshark"

#define degreesToRadians(x) (M_PI * (x) / 180.0)

@interface Joox : NSObject
// User Functions
+ (void)setUserInfo:(NSDictionary *)dict;
+ (NSDictionary *)getUserInfo;

+ (UIColor *)blueColor;
+ (UIColor *)greenColor;
+ (UIColor *)purpleColor;
+ (UIColor *)orangeColor;
+ (BOOL)isUserValid;
+ (NSString *)strip:(NSString *)string;
+ (NSString *)niceTime:(NSDate *)date;
+ (void)alert:(NSString *)message withTitle:(NSString *)title;
+ (NSString *)titleOfTrack:(NSDictionary *)track;
+ (NSString *)sourceFromTrack:(NSDictionary *)track;
+ (BOOL)isFirstRun;
+ (NSURL *)getFacebookImageURL:(NSString *)fb;
+ (UIStoryboard *)iphoneStoryboard;
+ (UIStoryboard *)ipadStoryboard;
+ (void)initViewController:(NSString *)identifier inNavigationController:(UINavigationController *)nav;
+ (NSURL *)generateQRURL:(NSString *)jooxID;
+ (UIViewController *)initViewController:(NSString *)identifier;
+ (id)JSON:(NSData *)data;
+(NSString *)durationString:(NSInteger)seconds;
+(NSString *)urlEncodeString:(NSString *)string;
+(BOOL)isiPad;
+(void)alertFacebookDenied;
@end
