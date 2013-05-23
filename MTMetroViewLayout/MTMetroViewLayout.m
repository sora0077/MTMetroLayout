//
//  MTMetroViewLayout.m
//  MTMetroViewLayoutDemo
//
//  Created by 林 達也 on 2013/05/05.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "MTMetroViewLayout.h"

@implementation MTMetroViewLayout

- (id)init
{
	self = [super init];
	if (self) {
		[self initialize];
	}
	return self;
}

#pragma mark - 

- (void)initialize
{
	self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	
	self.insetMargin = 40;
}

- (void)prepareLayout
{
	self.collectionView.pagingEnabled = NO;
	self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (CGSize)collectionViewContentSize
{
	
	NSUInteger numOfItems = 0;
	for (int i = 0; i < self.collectionView.numberOfSections; i++) {
		numOfItems += [self.collectionView numberOfItemsInSection:i];
	}
	CGSize contentSize = [super collectionViewContentSize];
	contentSize.width += self.insetMargin;// + self.minimumInteritemSpacing * numOfItems;
	contentSize.width -= numOfItems * self.headerReferenceSize.width;
	
	return contentSize;
}

- (CGSize)itemSize
{
	return UIEdgeInsetsInsetRect(self.collectionView.bounds, UIEdgeInsetsMake(0, 0, 0, self.insetMargin)).size;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
	// https://github.com/naotokui/UITableView-pagingEnabled
	
    CGPoint offset = proposedContentOffset;
    CGPoint contentOffset = self.collectionView.contentOffset;
	if (contentOffset.x < 0) contentOffset.x = 0;
	if (contentOffset.x > self.collectionViewContentSize.width - self.itemSize.width - self.insetMargin) contentOffset.x = self.collectionViewContentSize.width - self.itemSize.width - self.insetMargin;
	
	offset.x += self.itemSize.width / 2;
	contentOffset.x += self.itemSize.width / 2;
	
	NSIndexPath *contentIndexPath = [self.collectionView indexPathForItemAtPoint:contentOffset];
	
	
	NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:offset];
    int numberOfRow = [self.collectionView numberOfItemsInSection:indexPath.section];
    
	
	if (velocity.x > 0.2) {
		NSUInteger item = contentIndexPath.item + 1;
		if (item > numberOfRow - 1) item = numberOfRow - 1;
		indexPath = [NSIndexPath indexPathForItem:item inSection:contentIndexPath.section];
	} else if (velocity.x < -0.2) {
		NSUInteger item = contentIndexPath.item - 1;
		if (item > numberOfRow - 1) item = 0;
		indexPath = [NSIndexPath indexPathForItem:item inSection:contentIndexPath.section];
	} else {
		
	}
	if (abs(indexPath.item - contentIndexPath.item) > 1) {
		NSUInteger item = indexPath.item;
		item += indexPath.item / abs(indexPath.item);
		if (item > numberOfRow - 1) item = numberOfRow - 1;
		
		indexPath = [NSIndexPath indexPathForItem:item inSection:indexPath.section];
	}
	
    /* Find closest row at *targetContentOffset */
    
    // Row at *targetContentOffset
    CGRect rowRect = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
	
    // temporary assign
    CGRect targetRect = rowRect;
	
	
    /* Centering */
    offset = targetRect.origin;
	
    // Snap speed
    // it seems it's better set it slow when the distance of target offset and current offset is small to avoid abrupt jumps
    float currentOffset = self.collectionView.contentOffset.y;
    float rowH = targetRect.size.height;
    static const float thresholdDistanceCoef  = 0.25;
    if (fabs(currentOffset - offset.y) > rowH * thresholdDistanceCoef){
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    } else {
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
	
	return offset;
}

@end
