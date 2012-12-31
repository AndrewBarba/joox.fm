//
//  User+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "User.h"

@interface User (Create)
+(User *)createUserFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+(void)createUserFromFacebook:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
@end
