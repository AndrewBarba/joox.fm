//
//  FailedRequest+Create.h
//  joox.fm
//
//  Created by Andrew Barba on 7/14/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "FailedRequest.h"

@interface FailedRequest (Create)
+(void)createRequestToPage:(NSString *)page withData:(NSString *)data andListID:(NSInteger)listID inContext:(NSManagedObjectContext *)context;
+(NSArray *)allFailedRequests:(NSManagedObjectContext *)context;
@end
