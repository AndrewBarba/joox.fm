//
//  Invite+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 6/25/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Invite.h"

@interface Invite (Create)
+(void)createInviteFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+(NSArray *)allInvitesInContext:(NSManagedObjectContext *)context;
@end
