//
//  ListUser+Get.h
//  joox.fm
//
//  Created by Andrew Barba on 7/7/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "ListUser.h"

@interface ListUser (Get)
+(ListUser *)getUser:(NSInteger)userID InList:(NSInteger)listID inContext:(NSManagedObjectContext *)context;
@end
