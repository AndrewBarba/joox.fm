//
//  FailedRequest+Create.m
//  joox.fm
//
//  Created by Andrew Barba on 7/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "FailedRequest+Create.h"
#import "JooxList+Get.h"

@implementation FailedRequest (Create)
+(void)createRequestToPage:(NSString *)page withData:(NSString *)data andListID:(NSInteger)listID inContext:(NSManagedObjectContext *)context
{    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FailedRequest"];
    if (listID > 0) {
        request.predicate = [NSPredicate predicateWithFormat:@"page = %@ AND data = %@ AND list.identifier = %i",page,data,listID];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"page = %@ AND data = %@",page,data];
    }
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (matches.count >= 1) {
        FailedRequest *request = [NSEntityDescription insertNewObjectForEntityForName:@"FailedRequest" inManagedObjectContext:context];
        request.page = page;
        request.data = data;
        if (listID > 0) request.list = [JooxList getListByIdentifier:listID inContext:context];
        NSLog(@"Created FailedRequest");
    }
}

+(NSArray *)allFailedRequests:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FailedRequest"];
    return [context executeFetchRequest:request error:nil];
}
@end
