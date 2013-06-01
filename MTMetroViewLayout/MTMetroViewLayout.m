//
//  MTMetroViewLayout.m
//  MTMetroViewLayoutDemo
//
//  Created by 林 達也 on 2013/05/05.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "MTMetroViewLayout.h"

@interface MTMetroViewLayout () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) id dataSource;

@property (nonatomic, strong) NSArray *itemElements;
@property (nonatomic, strong) NSArray *headerElements;

@property (nonatomic, assign) CGSize itemSize;

@property (nonatomic, assign) BOOL enableHeaderElements;

- (CGPoint)headerReferenceOriginWithIndex:(NSIndexPath *)indexPath baseOrigin:(CGPoint)baseOrigin;
- (CGSize)headerReferenceSizeWithIndex:(NSIndexPath *)indexPath;
@end

@implementation MTMetroViewLayout

- (id)init
{
	self = [super init];
	if (self) {
		[self initialize];
	}
	return self;
}

//- (CGFloat)minimumLineSpacing
//{
//	return 0;
//}

#pragma mark - 

- (void)initialize
{
//	self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	self.headerReferenceSize = CGSizeMake(100, 0);
	self.insetMargin = 40;
	self.minimumInteritemSpacing = 5;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	BOOL ret = [super respondsToSelector:aSelector];
	if (!ret) {
		ret = [self.dataSource respondsToSelector:aSelector];
		if (!ret) {
			ret = [self.delegate respondsToSelector:aSelector];
		}
	}
	return ret;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if(!signature) {
        if([self.dataSource respondsToSelector:selector]) {
            return [self.dataSource methodSignatureForSelector:selector];
        }
        if([self.delegate respondsToSelector:selector]) {
            return [self.delegate methodSignatureForSelector:selector];
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    if ([self.dataSource respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:self.dataSource];
    } else if ([self.delegate respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:self.delegate];
    }
}

- (CGPoint)headerReferenceOriginWithIndex:(NSIndexPath *)indexPath baseOrigin:(CGPoint)baseOrigin
{
	return baseOrigin;
}

- (CGSize)headerReferenceSizeWithIndex:(NSIndexPath *)indexPath
{
	return self.headerReferenceSize;
}

#pragma mark -

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return NO;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return self.itemElements[indexPath.section][indexPath.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	return self.headerElements[indexPath.section];
}


- (void)prepareLayout
{
	[super prepareLayout];
	
    //NOTE:
	if (self.collectionView.delegate != self) {
		self.delegate = self.collectionView.delegate;
	}
    self.collectionView.delegate = self;
    
    //NOTE:
	if (self.collectionView.dataSource != self) {
		self.dataSource = self.collectionView.dataSource;
	}
    self.collectionView.dataSource = self;

    
	self.collectionView.pagingEnabled = NO;
	self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
	
	BOOL hasHeaderElements = self.enableHeaderElements;
	CGSize contentSize = self.collectionViewContentSize;
	CGSize itemSize = self.itemSize;
	CGFloat itemPosition = 0;
	CGFloat headerPosition = 0;
	
	NSLog(@"%@ %@", NSStringFromCGSize(itemSize), NSStringFromCGSize(self.collectionView.frame.size));
	
	NSMutableArray *itemElements = [NSMutableArray array];
	NSMutableArray *headerElements = [NSMutableArray array];
	for (int section = 0; section < self.collectionView.numberOfSections; section++) {
		
		if (hasHeaderElements) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
			UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
			
			CGRect frame = CGRectZero;
			frame.origin = [self headerReferenceOriginWithIndex:indexPath baseOrigin:CGPointMake(headerPosition, 0)];
			frame.size = [self headerReferenceSizeWithIndex:indexPath];
			
			attr.frame = frame;
			
			headerPosition += frame.size.width + self.minimumInteritemSpacing;
			headerElements[section] = attr;
		}
		
		NSMutableArray *items = [NSMutableArray array];
		for (int item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
			UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
			
			CGRect frame = CGRectZero;
			frame.origin.x = itemPosition;
			frame.origin.y = [self headerReferenceSizeWithIndex:indexPath].height;
			frame.size = itemSize;
			
			attr.frame = frame;
			
			itemPosition += frame.size.width + self.minimumInteritemSpacing;
			
			items[item] = attr;
		}
		itemElements[section] = items;
	}
	_itemElements = itemElements;
	_headerElements = headerElements;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	BOOL hasHeaderElements = self.enableHeaderElements;
	NSMutableArray *attributes = [NSMutableArray array];
	for (int section = 0; section < self.collectionView.numberOfSections; section++) {
		if (hasHeaderElements) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
			UICollectionViewLayoutAttributes *attr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
			if (CGRectIntersectsRect(rect, attr.frame)) {
				[attributes addObject:attr];
			}
		}
		for (int item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
			UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
			if (CGRectIntersectsRect(rect, attr.frame)) {
				[attributes addObject:attr];
			}
		}
	}
	return attributes;
}

- (CGSize)collectionViewContentSize
{
	NSUInteger numOfItems = 0;
	for (int i = 0; i < self.collectionView.numberOfSections; i++) {
		numOfItems += [self.collectionView numberOfItemsInSection:i];
	}
	CGSize contentSize;// = [super collectionViewContentSize];
	
	contentSize.width = (self.itemSize.width + self.minimumInteritemSpacing) * numOfItems + self.insetMargin;
//	contentSize.width = contentSize.width + self.minimumLineSpacing * numOfItems + 100;
	contentSize.height = self.collectionView.frame.size.height;

	
	return contentSize;
}

- (CGSize)itemSize
{
	return UIEdgeInsetsInsetRect(self.collectionView.bounds, UIEdgeInsetsMake(self.headerReferenceSize.height, 0, 0, self.insetMargin)).size;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
	// https://github.com/naotokui/UITableView-pagingEnabled
	
    CGPoint offset = proposedContentOffset;
    CGPoint contentOffset = self.collectionView.contentOffset;
	CGSize itemSize = self.itemSize;
	
	if (contentOffset.x < 0) contentOffset.x = 0;
	if (contentOffset.x > self.collectionViewContentSize.width - itemSize.width - self.insetMargin) contentOffset.x = self.collectionViewContentSize.width - itemSize.width - self.insetMargin;
	
	offset.x += itemSize.width / 2;
	offset.y = itemSize.height / 2;
	contentOffset.x += itemSize.width / 2;
	contentOffset.y = itemSize.height / 2;
	
	NSIndexPath *contentIndexPath = [self.collectionView indexPathForItemAtPoint:contentOffset];
	
	NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:offset];
    int numberOfRow = self.collectionView.numberOfSections;
    
	
	if (velocity.x > 0.2) {
		NSUInteger section = contentIndexPath.section + 1;
		if (section > numberOfRow - 1) section = numberOfRow - 1;
		indexPath = [NSIndexPath indexPathForItem:contentIndexPath.item inSection:section];
	} else if (velocity.x < -0.2) {
		NSUInteger section = contentIndexPath.section - 1;
		if (section > numberOfRow - 1) section = 0;
		indexPath = [NSIndexPath indexPathForItem:contentIndexPath.item inSection:section];
	}
	
	if (abs(indexPath.section - contentIndexPath.section) > 1) {
		NSUInteger section = indexPath.section;
		section += indexPath.section / abs(indexPath.section);
		if (section > numberOfRow - 1) section = numberOfRow - 1;
		
		indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:section];
	}
    
    // Row at *targetContentOffset
    CGRect rowRect = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
	
    // temporary assign
    CGRect targetRect = rowRect;
	
	
    /* Centering */
    offset = targetRect.origin;
	
	return offset;
}


#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
		return [self.dataSource numberOfSectionsInCollectionView:collectionView];
	}
	return 1;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
//        return [self.dataSource collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
//    } else {
//        return nil;
//    }
//}

#pragma mark UICollectionViewDelegate


@end


#pragma mark -

@interface MTMetroLayoutPivotHeaderView : UICollectionReusableView
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation MTMetroLayoutPivotHeaderView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}

@end

@interface MTMetroLayoutPivot () <UICollectionViewDelegateFlowLayout>

@end

@implementation MTMetroLayoutPivot
{
	NSMutableArray *_headerAttributes;
}

- (id)init
{
    self = [super init];
    if (self) {
        _headerHeight = 60;
		_headerAttributes = [NSMutableArray array];
		self.enableHeaderElements = YES;
		
		[self addObserver:self forKeyPath:@"collectionView" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"collectionView"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	UICollectionView *collectionView = [change objectForKey:NSKeyValueChangeNewKey];
	if (collectionView && [collectionView isKindOfClass:[UICollectionView class]]) {
		[collectionView registerClass:[MTMetroLayoutPivotHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MTMetroLayoutPivotHeaderView"];
	}
}


- (CGPoint)headerReferenceOriginWithIndex:(NSIndexPath *)indexPath baseOrigin:(CGPoint)baseOrigin
{
	CGSize itemSize = self.itemSize;
	itemSize.width *= 1.4;
	CGSize headerSize = [self headerReferenceSizeWithIndex:indexPath];
	CGPoint contentOffset = self.collectionView.contentOffset;
//	contentOffset.x -= itemSize.width * indexPath.section;
	contentOffset.x = contentOffset.x * headerSize.width / itemSize.width;
	NSLog(@"%@", NSStringFromCGPoint(CGPointMake(baseOrigin.x + contentOffset.x, baseOrigin.y)));
	return CGPointMake(baseOrigin.x + contentOffset.x, baseOrigin.y);
}

- (CGSize)headerReferenceSizeWithIndex:(NSIndexPath *)indexPath
{
	self.headerReferenceSize = [self collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:indexPath.section];
	return self.headerReferenceSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return YES;
}

- (void)prepareLayout
{
	[super prepareLayout];
	
	
}

#pragma mark UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionView:viewForHeaderInSection:)]) {
        UICollectionReusableView *headerView = [self.delegate collectionView:collectionView viewForHeaderInSection:indexPath.section];
        return headerView;
    }
    MTMetroLayoutPivotHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MTMetroLayoutPivotHeaderView" forIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(collectionView:titleForHeaderInSection:)]) {
        NSString *title = [self.delegate collectionView:collectionView titleForHeaderInSection:indexPath.section];
        headerView.titleLabel.text = title;
    }
	
	NSLog(@"header %@", indexPath);
    
    return headerView;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	if ([self.delegate respondsToSelector:@selector(collectionView:widthForHeaderInSection:)]) {
		CGFloat width = [self.delegate collectionView:collectionView widthForHeaderInSection:section];
		return CGSizeMake(width, self.headerHeight);
	}
	if ([self.delegate respondsToSelector:@selector(collectionView:titleForHeaderInSection:)]) {
		NSString *title = [self.delegate collectionView:collectionView titleForHeaderInSection:section];
		
		CGSize size = [title sizeWithFont:[UIFont boldSystemFontOfSize:22] constrainedToSize:CGSizeMake(self.itemSize.width * 0.6, self.headerHeight) lineBreakMode:NSLineBreakByWordWrapping];
		size.width = MAX(self.itemSize.width / 2, size.width);
		size.height = self.headerHeight;
		return size;
	} else {
		
	}
	return CGSizeMake(80, self.headerHeight);
}

@end

#pragma mark -
@implementation MTMetroLayoutPanorama



@end
