//
//  AddUserVC.h
//  joox.fm
//
//  Created by Andrew Barba on 7/5/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddUserCollectionVC.h"

@interface AddUserVC : UIViewController <UITextFieldDelegate, FacebookUsersDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) JooxList *list;
@end
