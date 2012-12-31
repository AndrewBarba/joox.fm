//
//  PartyTrack.h
//  joox.fm
//
//  Created by Andrew Barba on 10/26/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ListTrack.h"


@interface PartyTrack : ListTrack

@property (nonatomic, retain) NSNumber * state;

@end
