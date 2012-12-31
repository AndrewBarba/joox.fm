//
//  JooxJoinCreateViewController.h
//  Jooxbot
//
//  Created by Andrew Barba on 6/3/12.
//  Copyright (c) 2012 WhatsApp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateDelegate <NSObject>
-(void)userCreatedPlaylist:(BOOL)succes;
@end

@interface JooxCreateViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, weak) id <CreateDelegate> delegate;
@end
