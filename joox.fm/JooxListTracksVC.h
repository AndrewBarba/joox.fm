//
//  JooxListTracksVC.h
//  joox.fm
//
//  Created by Andrew Barba on 7/8/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface JooxListTracksVC : CoreDataTableViewController
@property (nonatomic, strong) JooxList *list;
@property (nonatomic) BOOL originalActive;
@end
