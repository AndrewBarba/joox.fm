//
//  Party+Get.h
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Party.h"

@interface Party (Get)
+ (Party *)getPartyByIdentifier:(NSInteger)ID inContext:(NSManagedObjectContext *)context;
+(NSArray *)allPartiesInContext:(NSManagedObjectContext *)context;
-(void)restart;
@end
