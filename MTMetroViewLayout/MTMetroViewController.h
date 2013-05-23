//
//  MTMetroViewController.h
//  MTMetroViewLayoutDemo
//
//  Created by 林 達也 on 2013/05/05.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTMetroViewLayout;
@interface MTMetroViewController : UIViewController

@property (nonatomic, readonly) MTMetroViewLayout *metroLayout;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, copy) NSArray *viewControllers;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@end
