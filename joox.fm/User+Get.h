//
//  User+Get.h
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "User.h"

@interface User (Get)
+ (User *)getUserByFB:(NSString *)fb inContext:(NSManagedObjectContext *)context;
+ (User *)getUserByID:(NSInteger)ID inContext:(NSManagedObjectContext *)context;
+(User *)getUserByFB:(NSString *)fb inPlaylist:(NSNumber *)playlistID inContext:(NSManagedObjectContext *)context;
@end
