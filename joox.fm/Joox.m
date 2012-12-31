//
//  Joox.m
//  Jooxbot
//
//  Created by Andrew Barba on 6/1/12.
//  Copyright (c) 2012 WhatsApp. All rights reserved.
//

#import "Joox.h"
#import "JXFMAppDelegate.h"

#define USER_INFO_KEY @"jooxfmUserInfoKey"

@implementation Joox

// User Functions
+ (void)setUserInfo:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:USER_INFO_KEY];
}

+(NSDictionary *)getUserInfo
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO_KEY];
}

+(BOOL)isUserValid
{
    return [Joox getUserInfo] ? YES : NO;
}

// Other Functions

+(UIColor *)blueColor
{
    return [UIColor colorWithRed:0 green:0.647 blue:0.894 alpha:1];
}

+(UIColor *)greenColor
{
    return [UIColor colorWithRed:0.106 green:0.6 blue:0.118 alpha:1];
}

+(UIColor *)purpleColor
{
    return [UIColor colorWithRed:0.769 green:0.09 blue:0.827 alpha:1];
}

+(UIColor *)orangeColor
{
    return [UIColor colorWithRed:0.933 green:0.686 blue:0.027 alpha:1];
}

+(NSString *)strip:(NSString *)string
{
    NSString *copy = [string copy];
    return [copy stringByReplacingOccurrencesOfString:@"\\" withString:@""];
}

+ (BOOL)isFirstRun
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:REFRESH_DB_KEY]) {
        return NO;
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:REFRESH_DB_KEY];
        return YES;
    }
}

+ (void)alert:(NSString *)message withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title message:message 
                               delegate:nil 
                      cancelButtonTitle:@"Okay" 
                      otherButtonTitles: nil] show];
}

+ (NSString *)titleOfTrack:(NSDictionary *)track
{
    return [track objectForKey:@"title"];
}

+ (NSString *)sourceFromTrack:(NSDictionary *)track
{
    return [track objectForKey:@"id"];
}

+ (NSURL *)getFacebookImageURL:(NSString *)fb
{
    NSString *path = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",fb];
    return [NSURL URLWithString:path];
}

+ (UIStoryboard *)iphoneStoryboard
{
    return [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
}

+ (UIStoryboard *)ipadStoryboard
{
    return [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
}

+ (void)initViewController:(NSString *)identifier inNavigationController:(UINavigationController *)nav
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIViewController *vc = [[Joox ipadStoryboard] instantiateViewControllerWithIdentifier:identifier];
        [nav pushViewController:vc animated:NO];
    } else {
        UIViewController *vc = [[Joox iphoneStoryboard] instantiateViewControllerWithIdentifier:identifier];
        [nav pushViewController:vc animated:NO];
    }
}

+ (UIViewController *)initViewController:(NSString *)identifier
{
    return [[Joox iphoneStoryboard] instantiateViewControllerWithIdentifier:identifier];
}

+ (NSURL *)generateQRURL:(NSString *)jooxID
{
    NSString *path = [NSString stringWithFormat:@"http://api.qrserver.com/v1/create-qr-code/?data=%@&size=600x600",jooxID];
    return [NSURL URLWithString:path];
}

+(NSString *)niceTime:(NSDate *)date
{
    CGFloat diff = [date timeIntervalSinceNow];
    diff = fabs(diff);
    
    NSString *tense;
    
    if (diff < 60) {
        tense = @"second";
    } else if (diff < 60*60) {
        tense = @"minute";
        diff = floorf(diff/60);
    } else if (diff < 60*60*24) {
        tense = @"hour";
        diff = floorf(diff/60/60);
    } else if (diff < 60*60*24*7) {
        tense = @"day";
        diff = floorf(diff/60/60/24);
    } else if (diff < 60*60*24*7*4.33) {
        tense = @"week";
        diff = floorf(diff/60/60/24/7);
    } else if (diff < 60*60*24*7*4.33*12) {
        tense = @"month";
        diff = floorf(diff/60/60/24/7/4.33);
    } else if (diff < 60*60*24*7*4.33*12*10) {
        tense = @"year";
        diff = floorf(diff/60/60/24/7/4.33/10);
    }
    
    if (diff != 1) tense = [tense stringByAppendingString:@"s"];
    
    return [NSString stringWithFormat:@"%.0f %@ ago",diff,tense];
}

+(id)JSON:(NSData *)data
{
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+(NSString *)durationString:(NSInteger)seconds
{
    NSInteger min = seconds / 60;
    NSInteger sec = seconds % 60;
    return [NSString stringWithFormat:@"%i:%02i",min,sec];
}

+(NSString *)urlEncodeString:(NSString *)string
{
    NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (__bridge CFStringRef) string,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                kCFStringEncodingUTF8));
    return escapedString;
}

+(BOOL)isiPad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+(void)alertFacebookDenied
{
    [Joox alert:@"It appears joox.fm has been denied facebook access.\n\nPlease go to\nSettings > Facebook\nand ensure you are logged in, have a data connection and have enabled joox.fm"
      withTitle:@"Facebook Access Denied"];
}

@end















