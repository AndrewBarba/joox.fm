//
//  UITableView+Reorder.m
//  joox.fm
//
//  Created by Andrew Barba on 7/21/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "UITableView+Reorder.h"
#import <CoreData/CoreData.h>

@implementation UITableView (Reorder)

-(void)reorderOldArray:(NSArray *)oldObjects toNewArray:(NSArray *)newArray
{
    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    dispatch_async(queue, ^{
        NSMutableArray *deleteIndexPaths = [NSMutableArray array];
        NSMutableArray *insertIndexPaths = [NSMutableArray array];
        NSMutableArray *moveFromIndexPaths = [NSMutableArray array];
        NSMutableArray *moveToIndexPaths = [NSMutableArray array];
        
        [oldObjects enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger oldIndex, BOOL *stop){
            NSUInteger newIndex = [newArray indexOfObject:obj];
            if (newIndex == NSNotFound) {
                [deleteIndexPaths addObject:[NSIndexPath indexPathForItem:oldIndex inSection:0]];
            } else if (newIndex != oldIndex) {
                [moveFromIndexPaths addObject:[NSIndexPath indexPathForItem:oldIndex inSection:0]];
                [moveToIndexPaths addObject:[NSIndexPath indexPathForItem:newIndex inSection:0]];
            }
        }];
        [newArray enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger newIndex, BOOL *stop){
            NSUInteger oldIndex = [oldObjects indexOfObject:obj];
            if (oldIndex == NSNotFound) {
                [insertIndexPaths addObject:[NSIndexPath indexPathForItem:newIndex inSection:0]];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self beginUpdates];
            [self deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [self insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [moveFromIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *fromIndexPath, NSUInteger index, BOOL *stop){
                NSIndexPath *toIndexPath = moveToIndexPaths[index];
                [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
            }];
            [self endUpdates];
        });
    });
}

@end
