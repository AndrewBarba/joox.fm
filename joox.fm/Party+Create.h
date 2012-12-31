//
//  Party+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Party.h"

@interface Party (Create)
+(Party *)createPartyWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
@end
