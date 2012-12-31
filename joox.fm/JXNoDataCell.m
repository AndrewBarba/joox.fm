//
//  JXNoDataCell.m
//  joox.fm
//
//  Created by Andrew Barba on 12/13/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JXNoDataCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation JXNoDataCell

-(void)initWithMessage:(NSString *)message
{
    self.messageLabel.text = message;
    
    self.bgView.layer.shadowRadius = 1;
    self.bgView.layer.shadowOpacity = 0.4;
    self.bgView.layer.shadowOffset = CGSizeMake(0, 0);
    self.bgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bgView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bgView.bounds].CGPath;
}

@end
