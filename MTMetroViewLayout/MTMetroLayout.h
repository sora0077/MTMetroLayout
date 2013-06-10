//
//  MTMetroViewLayout.h
//  MTMetroViewLayoutDemo
//
//  Created by 林 達也 on 2013/05/05.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MTMetroViewDelegateLayout <UICollectionViewDelegate>
@end

@interface MTMetroLayout : UICollectionViewLayout
@property (nonatomic, assign) CGFloat insetMargin;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) CGSize headerReferenceSize;
@end


#pragma mark - Pivot

@protocol MTMetroLayoutDelegatePivot;
@interface MTMetroLayoutPivot : MTMetroLayout

@property (nonatomic, assign) CGFloat headerHeight;

- (void)registerClassForHeaderView:(Class)viewClass withReuseIdentifier:(NSString *)identifier;
- (void)registerNibForHeaderView:(UINib *)nib withReuseIdentifier:(NSString *)identifier;

@end


#pragma mark - Panorama

@protocol MTMetroLayoutDelegatePanorama;
@interface MTMetroLayoutPanorama : MTMetroLayout

@end



//#pragma mark - 


@protocol MTMetroLayoutDelegatePivot <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@optional

//- (CGFloat)heightForHeaderViewInCollectionView:(UICollectionView *)collectionView;

- (NSString *)collectionView:(UICollectionView *)collectionView titleForHeaderInSection:(NSInteger)section;

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView widthForHeaderInSection:(NSInteger)section;

@end