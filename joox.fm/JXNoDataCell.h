//
//  JXNoDataCell.h
//  joox.fm
//
//  Created by Andrew Barba on 12/13/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXNoDataCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@end
