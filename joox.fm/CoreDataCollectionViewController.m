//
//  CoreDataCollectionViewController.m
//  joox.fm
//
//  Created by Andrew Barba on 6/19/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "CoreDataCollectionViewController.h"

@interface CoreDataCollectionViewController ()
@property (nonatomic) BOOL beganUpdates;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;
@property (nonatomic, strong) NSMutableArray *removeIndexPaths;
@property (nonatomic, strong) NSMutableArray *fromIndexPaths;
@property (nonatomic, strong) NSMutableArray *toIndexPaths;
@property (nonatomic, strong) NSMutableArray *reloadIndexPaths;
@end

@implementation CoreDataCollectionViewController

-(void)setUpResultsControllerWithEntity:(NSString *)entityName
                              predicate:(NSPredicate *)predicate
                                  limit:(NSInteger)limit
                     andSortDescriptors:(NSArray *)sortDescriptors
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    if (limit > 0) [request setFetchLimit:limit];
    request.predicate = predicate;
    request.sortDescriptors = sortDescriptors;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[JXFMAppDelegate context]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

-(void)initChangeArrays
{
    self.insertIndexPaths = [NSMutableArray array];
    self.removeIndexPaths = [NSMutableArray array];
    self.fromIndexPaths   = [NSMutableArray array];
    self.toIndexPaths     = [NSMutableArray array];
    self.reloadIndexPaths = [NSMutableArray array];
}

-(void)changeRequestEntity:(NSString *)entity
{
    self.fetchedResultsController.fetchRequest.entity =
    [NSEntityDescription entityForName:entity inManagedObjectContext:self.fetchedResultsController.managedObjectContext];
    [self animateUpdates];
}

-(void)changeRequestPredicate:(NSPredicate *)predicate
{
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    [self animateUpdates];
}

-(void)animateUpdates
{
    NSArray *oldObjects = self.fetchedResultsController.fetchedObjects;
    [self.fetchedResultsController performFetch:nil];
    NSArray *newObjects = self.fetchedResultsController.fetchedObjects;
    [self.collectionView reorderOldArray:oldObjects toNewArray:newObjects];
}

- (void)performFetch
{
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        } else {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    } else {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    [self.collectionView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title)) {
            self.title = newfrc.fetchRequest.entity.name;
        }
        if (newfrc) {
            if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch]; 
        } else {
            if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        self.beganUpdates = YES;
        [self initChangeArrays];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                break;
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{		
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                if (newIndexPath) [self.insertIndexPaths addObject: newIndexPath];
                break;
                
            case NSFetchedResultsChangeDelete:
                if (indexPath) [self.removeIndexPaths addObject:indexPath];
                break;
                
            case NSFetchedResultsChangeUpdate:
                if (newIndexPath) [self.reloadIndexPaths addObject:newIndexPath];
                break;
                
            case NSFetchedResultsChangeMove:
                if (indexPath && newIndexPath) {
                    [self.fromIndexPaths addObject:indexPath];
                    [self.toIndexPaths addObject:newIndexPath];
                }
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([self.contentChangedDelegate respondsToSelector:@selector(contentDidChange:)]) [self.contentChangedDelegate contentDidChange:self.fetchedResultsController.fetchedObjects.count];
    if (self.beganUpdates) {
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadItemsAtIndexPaths:self.reloadIndexPaths];
            [self.collectionView insertItemsAtIndexPaths:self.insertIndexPaths];
            [self.collectionView deleteItemsAtIndexPaths:self.removeIndexPaths];
            if (!self.insertIndexPaths.count && !self.removeIndexPaths.count) {
                [self.fromIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *fromIndexPath, NSUInteger index, BOOL *stop){
                    NSIndexPath *toIndexPath = self.toIndexPaths[index];
                    [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                }];
            }
        }completion:nil];
    }
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}

-(NSUInteger)numberOfObjects
{
    return self.fetchedResultsController.fetchedObjects.count;
}


@end
