//
//  MTMetroViewController.h
//  MTMetroViewLayoutDemo
//
//  Created by 林 達也 on 2013/05/05.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MTMetroLayoutStyle) {
    MTMetroLayoutStylePivot,
    MTMetroLayoutStylePanorama,
};

@class MTMetroLayout;
@interface MTMetroViewController : UIViewController

@property (nonatomic, readonly) MTMetroLayout *metroLayout;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, copy) NSArray *viewControllers;


- (id)initWithLayoutStyle:(MTMetroLayoutStyle)style;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@end
