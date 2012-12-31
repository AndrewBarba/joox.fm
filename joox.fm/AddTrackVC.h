//
//  AddTrackVC.h
//  joox.fm
//
//  Created by Andrew Barba on 6/21/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackResultsController.h"
#import "JXRequest.h"
#import "JooxList+Get.h"

#define ServiceYouTube     @"youtube"
#define ServiceVimeo       @"vimeo"
#define ServiceSoundCloud  @"soundcloud"
#define ServiceGrooveShark @"grooveshark"

@interface AddTrackVC : UIViewController <UITextFieldDelegate, UIScrollViewDelegate,TrackResultsDelegate>
@property (nonatomic, strong) JooxList *list;
@end
