//
//  Party+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 6/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "Party+Create.h"
#import "User+Get.h"
#import "Joox.h"
#import "NSDictionary+JXFM.h"

@implementation Party (Create)

+(Party *)createPartyWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    Party *party = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Party"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@",@([dict[@"party_id"] integerValue])];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"There was an error fetching parties");
        return nil;
    } else if (matches.count >= 1) {
        party = [matches lastObject];
    } else {
        party = [NSEntityDescription insertNewObjectForEntityForName:@"Party" inManagedObjectContext:context];
        party.identifier = @([dict[@"party_id"] integerValue]);
        party.type = @"party";
    }
    
    if ([party.version integerValue] != [dict[@"version"] integerValue]) {
        party.name      = [Joox strip:dict[@"name"]];
        party.timestamp = [dict timestamp];
        party.jooxID    = [NSString stringWithFormat:@"%@",dict[@"joox_id"]];
        party.active    = [dict[@"active"] boolValue] ? @(1) : nil;
        party.version   = @([dict[@"version"] integerValue]);
        return party;
    } else {
        return nil;
    }
}

@end
