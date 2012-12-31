//
//  JXTableViewController.m
//  joox.fm
//
//  Created by Andrew Barba on 12/13/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "JXTableViewController.h"
#import "AB.h"
#import "Joox.h"
#import "JXFMAppDelegate+CoreData.h"

@interface JXTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *plusOneButton;
@property (weak, nonatomic) IBOutlet UIButton *trackButton;
@property (weak, nonatomic) IBOutlet UIButton *userButton;
@end

@implementation JXTableViewController

-(void)fetch
{
    // Override
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initStyles];
    [self setUpResultsController];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetch) forControlEvents:UIControlEventValueChanged];
}

-(void)initStyles
{
    self.actionsView.layer.shadowRadius = 1;
    self.actionsView.layer.shadowOpacity = 0.4;
    self.actionsView.layer.shadowOffset = CGSizeMake(0, 0);
    self.actionsView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.actionsView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.actionsView.bounds].CGPath;
    
    self.noContentView.layer.shadowRadius = 1;
    self.noContentView.layer.shadowOpacity = 0.4;
    self.noContentView.layer.shadowOffset = CGSizeMake(0, 0);
    self.noContentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.noContentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.noContentView.bounds].CGPath;
}

-(void)setUpResultsController
{
    // Override
}

@end
