//
//  JXFMAppDelegate.m
//  joox.fm
//
//  Created by Andrew Barba on 6/12/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JXFMAppDelegate.h"
#import <AVFoundation/AVFoundation.h>

#define DOCUMENT_NAME @"joox_fm_document"

NSString *const FBSessionStateChangedNotification =@"com.abarba.joox-fm.Login:FBSessionStateChangedNotification";

@implementation JXFMAppDelegate

+(JXFMAppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

+(JooxPlayer *)jooxPlayer
{
    return [JXFMAppDelegate appDelegate].jooxPlayer;
}

+(JooxDownloader *)jooxDownloader
{
    return [JXFMAppDelegate appDelegate].jooxDownloader;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupDocument];
    self.request = [[JXRequest alloc] init];
    self.jooxPlayer = [[JooxPlayer alloc] init];
    self.jooxDownloader = [[JooxDownloader alloc] init];
    self.lastRefresh = [NSDate date];
    self.isActive = YES;
    
    return YES;
}

-(void)merge:(NSNotification *)notification
{
    [self.jxfmDocument.managedObjectContext performBlock:^{
        [self.jxfmDocument.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        [self.importContext performBlock:^{
            [self.importContext reset];
        }];
        //NSLog(@"Merged importContext");
    }];
}

+(void)registerForPush
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	[JXRequest updatePushToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //NSLog(@"Failed To Register %@",error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"Recieved Active Notification");
        [JXRequest fetchAllInvites:nil];
    } else {
        NSLog(@"Recieved Background Notification");
        [JXRequest fetchAllInvites:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:JXInviteNotification object:nil userInfo:userInfo];
    }
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"Memory Warning");
}

-(void)setupFacebook:(SuccessCompletionHandler)complete
{
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *type = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *accessParams =
    @{ACFacebookAppIdKey     : @"404618059582804",
    ACFacebookPermissionsKey : @[@"email"],
    ACFacebookAudienceKey    : ACFacebookAudienceFriends};
    
    [self.accountStore requestAccessToAccountsWithType:type options:accessParams completion:^(BOOL success, NSError *e){
        if (success) {
            NSArray *accounts = [self.accountStore accountsWithAccountType:type];
            self.facebookAccount = [accounts lastObject];
            if (complete) complete(YES);
        } else {
            //[self showLogin];
            if (complete) complete(NO);
        }
    }];
}

-(void)showLogin
{
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    [nav popToRootViewControllerAnimated:YES];
}

-(void)renewFacebookCredentials:(SuccessCompletionHandler)complete
{
    if (!self.facebookAccount) {
        if (complete) complete(NO);
        return;
    }
    [self.accountStore renewCredentialsForAccount:self.facebookAccount completion:^(ACAccountCredentialRenewResult result, NSError *e){
        if (result == ACAccountCredentialRenewResultRenewed) {
            if (complete) complete(YES);
        } else if (result == ACAccountCredentialRenewResultRejected) {
            if (complete) complete(NO);
        } else {
            if (complete) complete(NO);
        }
    }];
}

-(void)setupDocument
{
    NSURL *fileURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    fileURL = [fileURL URLByAppendingPathComponent:DOCUMENT_NAME];
    self.jxfmDocument = [[UIManagedDocument alloc] initWithFileURL:fileURL];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),NSInferMappingModelAutomaticallyOption:@(YES)};
    self.jxfmDocument.persistentStoreOptions = options;
}

-(void)resetDocument:(DoneCompletionHandler)complete
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.jxfmDocument.fileURL path]]) {
        if (self.jxfmDocument.documentState == UIDocumentStateNormal) {
            [self.jxfmDocument closeWithCompletionHandler:^(BOOL done){
                [[NSFileManager defaultManager] removeItemAtURL:self.jxfmDocument.fileURL error:nil];
                [self setupDocument];
                [self useDocument:complete];
            }];
        } else {
            [[NSFileManager defaultManager] removeItemAtURL:self.jxfmDocument.fileURL error:nil];
            [self setupDocument];
            [self useDocument:complete];
        }
    }
}

-(void)logout
{
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    [self resetDocument:^{
        [Joox setUserInfo:nil];
        [self closeSession];
        dispatch_async(dispatch_get_main_queue(), ^{
            [nav popToRootViewControllerAnimated:YES];
        });
    }];
}

-(void)saveDocument
{
    [self.jxfmDocument performAsynchronousFileAccessUsingBlock:^{
        [self.jxfmDocument saveToURL:self.jxfmDocument.fileURL
                    forSaveOperation:UIDocumentSaveForOverwriting
                   completionHandler:nil];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if (self.jxfmDocument.documentState == UIDocumentStateNormal) {
        [self saveDocument];
    }
    
    if ([self.jooxPlayer isPlaying]) {
        double delayInSeconds = 0.05;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.jooxPlayer.player play];
        });
    }
    
    self.isActive = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([self.jooxPlayer isPlaying]) {
        double delayInSeconds = 0.05;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.jooxPlayer.player play];
        });
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self useDocument:^{
        [self initContextNotifications];
    }];
    //    [self renewFacebookCredentials];
    
    self.isActive = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self becomeFirstResponder];
	[application beginReceivingRemoteControlEvents];
    
    if ([self.jooxPlayer isPaused]) {
        double delayInSeconds = 0.05;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.jooxPlayer.player pause];
        });
    }
    
    // 15 minute refresh
    if (fabs([self.lastRefresh timeIntervalSinceNow]) > 60*15) {
        NSLog(@"Refreshing...");
        [JXRequest fetchEverything:^{
            self.lastRefresh = [NSDate date];
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if ([[JXFMAppDelegate jooxDownloader] isDownloading]) [[JXFMAppDelegate jooxDownloader] done:NO];
    [self resignFirstResponder];
	[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [FBSession.activeSession close];
}

-(void)initContextNotifications
{
    [self.jxfmDocument.managedObjectContext performBlock:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.importContext];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(merge:)
                                                     name:NSManagedObjectContextDidSaveNotification object:self.importContext];
    }];
}

-(void)setupImportContext
{
    self.importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.importContext setPersistentStoreCoordinator:self.jxfmDocument.managedObjectContext.persistentStoreCoordinator];
    [self.importContext setUndoManager:nil];
    [self initContextNotifications];
}

-(void)useDocument:(DoneCompletionHandler)complete
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.jxfmDocument.fileURL path]]) {
        [self.jxfmDocument saveToURL:self.jxfmDocument.fileURL
                    forSaveOperation:UIDocumentSaveForCreating
                   completionHandler:^(BOOL x){
                       [self setupImportContext];
                       if (complete) complete();
                   }];
    } else if (self.jxfmDocument.documentState == UIDocumentStateClosed) {
        [self.jxfmDocument openWithCompletionHandler:^(BOOL x){
            [self setupImportContext];
            if (complete) complete();
        }];
    } else if (self.jxfmDocument.documentState == UIDocumentStateNormal) {
        if (complete) complete();
    }
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self.jooxPlayer.player play];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self.jooxPlayer.player pause];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            if ([self.jooxPlayer isPlaying]) {
                [self.jooxPlayer.player pause];
            } else {
                [self.jooxPlayer.player play];
            }
        } else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
            [self.jooxPlayer nextTrack];
        } else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
            [self.jooxPlayer previousTrack];
        } else if (event.subtype == UIEventSubtypeRemoteControlStop) {
            [self.jooxPlayer.player stop];
        } else if (event.subtype == UIEventSubtypeRemoteControlEndSeekingForward) {
            [self.jooxPlayer nextTrack];
        } else if (event.subtype == UIEventSubtypeRemoteControlEndSeekingBackward) {
            [self.jooxPlayer previousTrack];
        } else if (event.subtype == UIEventSubtypeRemoteControlBeginSeekingBackward) {
            NSLog(@"Began Seeking Backward");
        } else if (event.subtype == UIEventSubtypeRemoteControlBeginSeekingForward) {
            NSLog(@"Began Seeking Forward");
        }
    }
}





/**************** FACEBOOK ******************/

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and shows the login UX if not iOS6.
 */
-(void)openFBSessionNew:(BOOL)new onComplete:(JXRequestStringCompletionHandler)complete
{
    NSArray *permissions = @[@"email"];
    [FBSession openActiveSessionWithPermissions:permissions
                                   allowLoginUI:new
                              completionHandler:^(FBSession *session,FBSessionState state,NSError *error) {
                                  [self sessionStateChanged:session
                                                      state:state
                                                      error:error];
                                  
                                  if (!error) {
                                      if (complete) complete(session.accessToken);
                                  } else {
                                      if (complete) complete(nil);
                                  }
                              }];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
}
@end