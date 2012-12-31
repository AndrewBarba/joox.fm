//
//  LogoutVC.m
//  joox.fm
//
//  Created by Andrew Barba on 8/25/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "LogoutVC.h"
#import "JXFMAppDelegate+CoreData.h"

@interface LogoutVC ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@end

@implementation LogoutVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.versionLabel.text = [NSString stringWithFormat:@"version %@",VERSION_KEY];
    [self initStyles];
}

-(void)initStyles
{
//    self.logOutButton.layer.shadowRadius = 1;
//    self.logOutButton.layer.shadowOpacity = 0.8;
//    self.logOutButton.layer.shadowOffset = CGSizeMake(0, 2);
//    self.logOutButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.logOutButton.layer.cornerRadius = 3;
}

- (IBAction)logout:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to logout of joox.fm?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Logout"
                                              otherButtonTitles:nil];
    [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [sheet showInView:self.parentViewController.parentViewController.parentViewController.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.logOutButton.layer.opacity = 0;
        }completion:^(BOOL done){
            [self.loading startAnimating];
            [[JXFMAppDelegate appDelegate] logout];
        }];
    }
}


@end
