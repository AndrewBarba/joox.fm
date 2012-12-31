//
//  ContainerVC.h
//  joox.fm
//
//  Created by Andrew Barba on 8/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuDelegate <NSObject>
-(void)userDidPan:(UIPanGestureRecognizer *)pan toggleView:(UIView *)view;
-(void)toggleMenu:(UIView *)view;
@end

@interface ContainerVC : UIViewController <UIGestureRecognizerDelegate, MenuDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@end
