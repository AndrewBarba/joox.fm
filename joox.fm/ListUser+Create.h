//
//  ListUser+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 9/9/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "ListUser.h"
#import "JooxList.h"

@interface ListUser (Create)
+(void)createListUserWithUser:(User *)user inList:(JooxList *)list fromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
@end
