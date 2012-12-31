//
//  JXFMAppDelegate.h
//  joox.fm
//
//  Created by Andrew Barba on 6/12/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXRequest.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "JooxPlayer.h"
#import "JooxDownloader.h"
#import <FacebookSDK/FacebookSDK.h>

extern NSString *const FBSessionStateChangedNotification;

// Notifications
#define JXInviteNotification @"JXInviteNotification"

typedef void(^SuccessCompletionHandler)(BOOL);
typedef void(^DoneCompletionHandler)(void);

@protocol JXFMDatabaseDelegate <NSObject>
-(void)documentIsReady;
@end

@interface JXFMAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIManagedDocument *jxfmDocument;
@property (strong, nonatomic) NSManagedObjectContext *importContext;
@property (strong, nonatomic) JXRequest *request;
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *facebookAccount;
@property (strong, nonatomic) JooxPlayer *jooxPlayer;
@property (strong, nonatomic) JooxDownloader *jooxDownloader;
@property (strong, nonatomic) NSDate *lastRefresh;
@property (nonatomic) BOOL isActive;

-(void)useDocument:(DoneCompletionHandler)complete;
-(void)setupDocument;
-(void)resetDocument:(DoneCompletionHandler)complete;
+(JXFMAppDelegate *)appDelegate;
+(void)registerForPush;
-(void)setupFacebook:(SuccessCompletionHandler)complete;
+(JooxPlayer *)jooxPlayer;
+(JooxDownloader *)jooxDownloader;
-(void)logout;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
-(void)renewFacebookCredentials:(SuccessCompletionHandler)complete;
-(void)openFBSessionNew:(BOOL)new onComplete:(JXRequestStringCompletionHandler)complete;
@end
