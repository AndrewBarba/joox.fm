//
//  JooxJoinViewController.h
//  Jooxbot
//
//  Created by Andrew Barba on 6/3/12.
//  Copyright (c) 2012 WhatsApp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@protocol JoinDelegate <NSObject>
-(void)userJoinedJooxList:(BOOL)success;
@end

@interface JooxJoinViewController : UIViewController <UITextFieldDelegate, ZBarReaderDelegate>
@property (nonatomic, weak) id <JoinDelegate> delegate;
@end
