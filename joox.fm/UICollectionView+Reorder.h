//
//  UICollectionView+Reorder.h
//  joox.fm
//
//  Created by Andrew Barba on 7/21/12.
//  Copyright (c) 2012 Andrew Barba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (Reorder)
// This can only be used with CoreData
-(void)reorderOldArray:(NSArray *)oldObjects toNewArray:(NSArray *)newArray;
@end
