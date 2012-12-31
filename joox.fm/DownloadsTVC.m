//
//  DownloadsTVC.m
//  joox.fm
//
//  Created by Andrew Barba on 8/18/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import "DownloadsTVC.h"
#import "JooxListTrackCell.h"

@interface DownloadsTVC ()

@end

@implementation DownloadsTVC

-(void)setUpResultsController
{
    [self setUpResultsControllerWithEntity:@"Track"
                                 predicate:[NSPredicate predicateWithFormat:@"isCached != nil"]
                                     limit:0
                        andSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                           ascending:YES
                                                                            selector:@selector(localizedCaseInsensitiveCompare:)]]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cached Track Cell";
    JooxListTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Track *track = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell initWithCachedTrack:track];    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Track *track = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([[JXFMAppDelegate jooxDownloader] isDownloading] && [JXFMAppDelegate jooxDownloader].track == track) return;
    [[JXFMAppDelegate jooxPlayer] playSoloTrack:track];
    [self.parentViewController performSelector:@selector(openPlayerView)];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    
    int64_t delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    });
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Track *track = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([[JXFMAppDelegate jooxDownloader] isDownloading] && [JXFMAppDelegate jooxDownloader].track == track) {
            [[JXFMAppDelegate jooxDownloader] done:NO];
        } else {
            [track deleteCache];
        }
    }
}

-(void)search:(NSString *)query
{
    if (!query || [query isEqualToString:@""]) {
        [self changeRequestPredicate:[NSPredicate predicateWithFormat:@"isCached != nil"]];
    } else {
        [self changeRequestPredicate:[NSPredicate predicateWithFormat:@"isCached != nil AND title CONTAINS[cd] %@",query]];
    }
}

@end
