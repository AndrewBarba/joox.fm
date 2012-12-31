//
//  ListTrack+Get.h
//  joox.fm
//
//  Created by Andrew Barba on 7/7/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "ListTrack.h"

@interface ListTrack (Get)
+(ListTrack *)getTrack:(NSInteger)trackID InList:(NSInteger)listID inContext:(NSManagedObjectContext *)context;
-(BOOL)userDidVote:(NSInteger)userID;
-(BOOL)didUpload;
@end
