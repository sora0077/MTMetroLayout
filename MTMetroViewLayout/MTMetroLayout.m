//
//  MTMetroViewLayout.m
//  MTMetroViewLayoutDemo
//
//  Created by 林 達也 on 2013/05/05.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "MTMetroLayout.h"

@interface MTMetroLayout () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) id dataSource;

@property (nonatomic, strong) NSArray *itemElements;
@property (nonatomic, strong) NSArray *headerElements;

@property (nonatomic, assign) CGSize itemSize;

@property (nonatomic, assign) BOOL enableHeaderElements;

- (void)setCollectionViewInternal:(UICollectionView *)collectionView;

- (CGPoint)headerReferenceOriginWithIndex:(NSIndexPath *)indexPath baseOrigin:(CGPoint)baseOrigin;
- (CGSize)headerReferenceSizeWithIndex:(NSIndexPath *)indexPath;
@end

@implementation MTMetroLayout

- (id)init
{
	self = [super init];
	if (self) {
		[self addObserver:self forKeyPath:@"collectionView" options:NSKeyValueObservingOptionNew context:NULL];
		[self initialize];
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
		if ([self respondsToSelector:@selector(setCollectionViewInternal:)]) {
			[self setCollectionViewInternal:collectionView];
		}
	}
}

#pragma mark - 

- (void)initialize
{
//	self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	self.headerReferenceSize = CGSizeMake(100, 0);
	self.insetMargin = 40;
	self.minimumInteritemSpacing = 5;
}

- (void)setCollectionViewInternal:(UICollectionView *)collectionView
{
	//NOTE: Do nothing
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
	
//    NSLog(@"%s", __func__);
    
    //NOTE:
	if (self.collectionView.delegate != self) {
		self.delegate = self.collectionView.delegate;
        self.collectionView.delegate = self;
	}
    
    //NOTE:
	if (self.collectionView.dataSource != self) {
		self.dataSource = self.collectionView.dataSource;
        self.collectionView.dataSource = self;
	}

    
	self.collectionView.pagingEnabled = NO;
	self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
	
	BOOL hasHeaderElements = self.enableHeaderElements;
	CGSize contentSize = self.collectionViewContentSize;
	CGSize itemSize = self.itemSize;
	CGFloat itemPosition = 0;
	CGFloat headerPosition = 0;
	
//	NSLog(@"%@ %@", NSStringFromCGSize(itemSize), NSStringFromCGSize(self.collectionView.frame.size));
	
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
            
            attr.zIndex = 100;
			
			headerPosition = frame.origin.x + frame.size.width + self.minimumInteritemSpacing;
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
            
//            NSLog(@"%s %@", __func__, NSStringFromCGRect(frame));
			
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

	
//    NSLog(@"%s %@", __func__, NSStringFromCGSize(contentSize));
    
	return contentSize;
}

- (CGSize)itemSize
{
//    NSLog(@"%s %@", __func__, NSStringFromCGSize(UIEdgeInsetsInsetRect(self.collectionView.bounds, UIEdgeInsetsMake(self.headerReferenceSize.height, 0, 0, self.insetMargin)).size));
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


#pragma mark UICollectionViewDelegate


@end


#pragma mark -


@class MTMetroLayoutPivotHeaderView;
@protocol MTMetroLayoutPivotHeaderViewDelegate <NSObject>

- (void)pivotHeaderViewDidSelectHeader:(MTMetroLayoutPivotHeaderView *)view;

@end

@interface MTMetroLayoutPivotHeaderView : UICollectionViewCell
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *backgroundButton;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, weak) id<MTMetroLayoutPivotHeaderViewDelegate> delegate;
@end

@implementation MTMetroLayoutPivotHeaderView
{
	__weak UICollectionView *_attachmentView;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
        
        UIButton *backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backgroundButton addTarget:self action:@selector(backgroundButtonTapAction:) forControlEvents:UIControlEventTouchDown];
		[self.contentView addSubview:backgroundButton];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.font = [MTMetroLayoutPivotHeaderView titleFont];
		[self.contentView addSubview:titleLabel];
        
        self.backgroundButton = backgroundButton;
		self.titleLabel = titleLabel;
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	self.titleLabel.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsetsMake(4, 4, 4, 0));
    self.backgroundButton.frame = self.bounds;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	if ([newSuperview respondsToSelector:@selector(contentOffset)]) {
		if (_attachmentView) {
			[_attachmentView removeObserver:self forKeyPath:@"contentOffset"];
		}
		[newSuperview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
		
		_attachmentView = (UICollectionView *)newSuperview;
        
        [self updateContentOffset:_attachmentView.contentOffset];
	}
	
	[super willMoveToSuperview:newSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	CGPoint contentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
	[self updateContentOffset:contentOffset];
}

- (void)updateContentOffset:(CGPoint)contentOffset
{
    MTMetroLayout *collectionViewLayout = (MTMetroLayout *)_attachmentView.collectionViewLayout;
	CGSize itemSize = collectionViewLayout.itemSize;
	
	CGFloat roi = _index * (itemSize.width + collectionViewLayout.minimumInteritemSpacing);
	
	contentOffset.x = fabsf(contentOffset.x - roi);
	contentOffset.x /= itemSize.width;
	
	CGFloat dist = MAX(0, MIN(contentOffset.x, 0.7));
    
    UIColor *tintColor = [UIColor whiteColor];
    if (collectionViewLayout.tintColor) {
        tintColor = collectionViewLayout.tintColor;
    }
	
    dispatch_async(dispatch_get_main_queue(), ^{
        self.titleLabel.textColor = [tintColor colorWithAlphaComponent:1 - dist];
    });
}

- (void)backgroundButtonTapAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(pivotHeaderViewDidSelectHeader:)]) {
        [self.delegate pivotHeaderViewDidSelectHeader:self];
    }
}

+ (UIFont *)titleFont
{
	return [UIFont fontWithName:@"Avenir-Light" size:38];
}

@end

@interface MTMetroLayoutPivot () <MTMetroLayoutPivotHeaderViewDelegate, UICollectionViewDelegate>
@end

@implementation MTMetroLayoutPivot
{
	Class _customHeaderClass;
	UINib *_customHeaderNib;
	NSString *_customHeaderIdentifier;
}

- (id)init
{
    self = [super init];
    if (self) {
        _headerHeight = 42;
		self.enableHeaderElements = YES;
    }
    return self;
}

- (void)setCollectionViewInternal:(UICollectionView *)collectionView
{
	collectionView.showsHorizontalScrollIndicator = NO;
	if ([self.delegate respondsToSelector:@selector(collectionView:viewForHeaderInSection:)]) {
		if (_customHeaderNib) {
			[collectionView registerNib:_customHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:_customHeaderIdentifier];
		} else {
			[collectionView registerClass:_customHeaderClass forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:_customHeaderIdentifier];
		}
		_customHeaderClass = nil;
		_customHeaderNib = nil;
		_customHeaderIdentifier = nil;
	} else {
		[collectionView registerClass:[MTMetroLayoutPivotHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MTMetroLayoutPivotHeaderView"];
	}
}

- (void)registerClassForHeaderView:(Class)viewClass withReuseIdentifier:(NSString *)identifier
{
	_customHeaderClass = viewClass;
	_customHeaderIdentifier = identifier;
}

- (void)registerNibForHeaderView:(UINib *)nib withReuseIdentifier:(NSString *)identifier
{
	_customHeaderNib = nib;
	_customHeaderIdentifier = identifier;
}

- (CGPoint)headerReferenceOriginWithIndex:(NSIndexPath *)indexPath baseOrigin:(CGPoint)baseOrigin
{
	CGSize itemSize = self.itemSize;
	CGSize headerSize = [self headerReferenceSizeWithIndex:indexPath];
	CGPoint contentOffset = self.collectionView.contentOffset;
	CGPoint origin = CGPointZero;
	
	NSInteger index = contentOffset.x / (itemSize.width + self.minimumInteritemSpacing);
	origin.x = baseOrigin.x - self.minimumInteritemSpacing * (indexPath.section ? 1 : 0);
	if (indexPath.section == index) {
		origin.x = - (headerSize.width / (itemSize.width + self.minimumInteritemSpacing)) * contentOffset.x +  contentOffset.x + index * headerSize.width;
	}
	
//    NSLog(@"%s %@", __func__, NSStringFromCGPoint(origin));
	return origin;
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

//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
//{
//	NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
//	NSLog(@"%@", attributes);
//	return attributes;
//}

#pragma mark UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionView:viewForHeaderInSection:)]) {
        UICollectionReusableView *headerView = [self.delegate collectionView:collectionView viewForHeaderInSection:indexPath.section];
        return headerView;
    }
    MTMetroLayoutPivotHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MTMetroLayoutPivotHeaderView" forIndexPath:indexPath];
	headerView.index = indexPath.section;
    headerView.delegate = self;
    
    if ([self.delegate respondsToSelector:@selector(collectionView:titleForHeaderInSection:)]) {
        NSString *title = [self.delegate collectionView:collectionView titleForHeaderInSection:indexPath.section];
        headerView.titleLabel.text = title;
    }
	
	
    [headerView updateContentOffset:collectionView.contentOffset];
//	NSArray *colors = @[[UIColor whiteColor], [UIColor blueColor], [UIColor orangeColor], [UIColor redColor]];
//	headerView.backgroundColor = colors[indexPath.section];
    
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
//		NSLog(@"%@", title);
		
		CGSize itemSize = self.itemSize;
		CGSize size = [title sizeWithFont:[MTMetroLayoutPivotHeaderView titleFont] constrainedToSize:CGSizeMake(self.itemSize.width * 2, self.headerHeight) lineBreakMode:NSLineBreakByWordWrapping];
		size.width += 20;
		size.width = MIN(MAX(itemSize.width * 0.3, size.width), itemSize.width * 0.9);
		size.height = self.headerHeight;
		return size;
	} else {
		
	}
	return CGSizeMake(self.itemSize.width * 0.7, self.headerHeight);
}

#pragma mark - MTMetroLayoutPivotHeaderViewDelegate

- (void)pivotHeaderViewDidSelectHeader:(MTMetroLayoutPivotHeaderView *)view
{
    if ([self.delegate respondsToSelector:@selector(collectionView:didSelectHeaderInSection:)]) {
        [self.delegate collectionView:self.collectionView didSelectHeaderInSection:view.index];
    }
}

@end

#pragma mark -
@implementation MTMetroLayoutPanorama



@end
