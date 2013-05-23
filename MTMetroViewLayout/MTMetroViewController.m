//
//  MTMetroViewController.m
//  MTMetroViewLayoutDemo
//
//  Created by 林 達也 on 2013/05/05.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "MTMetroViewController.h"
#import "MTMetroViewLayout.h"

#pragma mark - MTCollectionViewCell

@interface MTCollectionViewCell : UICollectionViewCell

@property (nonatomic, readonly) UIViewController *viewController;

- (void)updateViewController:(UIViewController *)viewController parentViewController:(UIViewController *)parentViewController;

@end

@implementation MTCollectionViewCell
{
	UIViewController *_viewController;
}

- (UIViewController *)viewController
{
	return _viewController;
}

- (void)updateViewController:(UIViewController *)viewController parentViewController:(UIViewController *)parentViewController
{
	[viewController.view removeFromSuperview];
	if (_viewController != viewController) {
		[_viewController willMoveToParentViewController:nil];
		[_viewController removeFromParentViewController];
		
		viewController.view.frame = self.contentView.bounds;
		[self.contentView addSubview:viewController.view];
		[parentViewController addChildViewController:viewController];
		[viewController didMoveToParentViewController:parentViewController];
		
		_viewController = viewController;
	} else {
		[self.contentView addSubview:_viewController.view];
	}
}

@end

#pragma mark -

@interface MTMetroViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation MTMetroViewController
{
	NSMutableArray *_mutableViewControllers;
}

- (id)init
{
	self = [super init];
	if (self) {
		[self initialize];
		
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		
		[self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	if (self.collectionView == nil) {
		self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.metroLayout];
		
		self.collectionView.dataSource = self;
		self.collectionView.delegate = self;
		[self.view addSubview:self.collectionView];
		
		
		[self.collectionView registerClass:[MTCollectionViewCell class] forCellWithReuseIdentifier:@"MTCollectionViewCell"];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	self.collectionView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method

- (void)initialize
{
	_metroLayout = [[MTMetroViewLayout alloc] init];
}

- (void)renewViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
	_mutableViewControllers = [viewControllers mutableCopy];
	
	[self.collectionView reloadData];
}


#pragma mark -

- (NSArray *)viewControllers
{
	return _mutableViewControllers;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
	[self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
	//NOTE: check
	__block BOOL refreshViewControllers = NO;
	if (viewControllers.count != _mutableViewControllers.count) {
		refreshViewControllers = YES;
	} else {
		[viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([obj isEqual:_mutableViewControllers[idx]]) {
				refreshViewControllers = YES;
				*stop = YES;
			}
		}];
	}
	
	if (refreshViewControllers) {
		[self renewViewControllers:viewControllers animated:animated];
	}
}

#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.viewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	MTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MTCollectionViewCell" forIndexPath:indexPath];
	
	UIViewController *viewController = self.viewControllers[indexPath.item];
	
	[cell updateViewController:viewController parentViewController:self];
	
	return cell;
}

#pragma mark -

@end
