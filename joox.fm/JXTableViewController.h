//
//  JXTableViewController.h
//  joox.fm
//
//  Created by Andrew Barba on 12/13/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface JXTableViewController : CoreDataTableViewController
@property (weak, nonatomic) IBOutlet UIView *actionsView;
@property (strong, nonatomic) IBOutlet UIView *noContentView;

-(void)initStyles;
-(void)fetch;
-(void)setUpResultsController;
@end
