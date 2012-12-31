//
//  JooxListVC.h
//  joox.fm
//
//  Created by Andrew Barba on 7/8/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXFMAppDelegate+CoreData.h"
#import "JXRequest.h"
#import "JXFMFetcher.h"
#import "JooxListTracksVC.h"
#import "JooxListActivityVC.h"
#import "JooxListUsersVC.h"
#import "AddTrackVC.h"
#import "AddUserVC.h"
#import "BarCodeVC.h"
#import "JooxDownloader.h"

@interface JooxListVC : UIViewController <JooxDownloadDelegate,UIScrollViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) JooxList *list;
@end
