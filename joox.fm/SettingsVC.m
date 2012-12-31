//
//  SettingsVC.m
//  joox.fm
//
//  Created by Andrew Barba on 8/18/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "SettingsVC.h"
#import "Joox.h"

@interface SettingsVC ()
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation SettingsVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.text = [Joox getUserInfo][@"full_name"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initStyles];
}

-(void)initStyles
{
    self.topBar.layer.shadowRadius = 2;
    self.topBar.layer.shadowOpacity = 0.8;
    self.topBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.topBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topBar.bounds].CGPath;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initStyles];
}

-(IBAction)sendFeedback:(UIButton *)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        NSDictionary *user = [Joox getUserInfo];
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:@[@"support@joox.fm"]];
        [controller setSubject:[NSString stringWithFormat:@"joox.fm Feedback | %@",VERSION_KEY]];
        
        NSString *initial = [NSString stringWithFormat:
                             @"INSERT FEEDBACK\n\n--------------------\nName: %@\nJXID: %@\njoox.fm Version: %@\niOS Version: %@\niOS Name: %@\n--------------------",
                             user[@"full_name"],user[@"id"],VERSION_KEY,[[UIDevice currentDevice] systemVersion],[[UIDevice currentDevice] systemName]];
        
        
        
        
        [controller setMessageBody:initial isHTML:NO];
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [Joox alert:@"It appears your device cannot send email. Please email us at\nsupport@joox.fm\nwith a detailed description of your problem."
          withTitle:@"Can't Send Email"];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        [self dismissViewControllerAnimated:YES completion:^{
            [Joox alert:@"Thank you for your feedback! If you are having problems with joox.fm we will be contacting you shortly." withTitle:@"Thanks!"];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
