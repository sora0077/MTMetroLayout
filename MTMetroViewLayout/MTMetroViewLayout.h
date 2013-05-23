//
//  MTMetroViewLayout.h
//  MTMetroViewLayoutDemo
//
//  Created by 林 達也 on 2013/05/05.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MTMetroViewDelegateLayout <UICollectionViewDelegate>

- (CGFloat)heightForGroupHeaderInCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout;
- (NSString *)titleForGroupHeaderInCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout;
- (UIView *)viewForGroupHeaderInCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout;

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout heightForItemHeaderInSection:(NSInteger)section;
//- (NSString *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout titleForItemHeaderInSection:(NSInteger)section;
//- (UIView *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout viewForItemHeaderInSection:(NSInteger)section;

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

@end

@interface MTMetroViewLayout : UICollectionViewFlowLayout

@property (nonatomic, copy) NSString *groupTitle;
@property (nonatomic) CGFloat groupHeight;

@property (nonatomic, assign) CGFloat insetMargin;

@end
