//
//  HomeVC.h
//  joox.fm
//
//  Created by Andrew Barba on 7/18/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JooxJoinViewController.h"
#import "JooxCreateViewController.h"

@interface HomeVC : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, JoinDelegate, CreateDelegate>

@end
