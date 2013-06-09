//
//  MTMetroViewController.m
//  MTMetroViewLayoutDemo
//
//  Created by 林 達也 on 2013/05/05.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "MTMetroViewController.h"
#import "MTMetroLayout.h"

@interface MTBatchController : NSObject

@property (nonatomic, assign) NSTimeInterval interval;

- (void)registerSelector:(SEL)sel;
- (void)performBatch:(void (^)())batch;
- (void)performBatch:(void (^)())batch after:(NSTimeInterval)duration;
@end

@implementation MTBatchController
{
//	NSMutableDictionary *_batchs;
	NSMutableArray *_batches;
	NSDate *_lastFireDate;
}


- (id)init
{
	self = [super init];
	if (self) {
		_interval = 0.01;
//		_batchs = [NSMutableDictionary dictionary];
		_batches = [NSMutableArray arrayWithCapacity:2];
		_lastFireDate = [NSDate date];
	}
	return self;
}

- (void)registerSelector:(SEL)sel
{
}

- (void)performBatch:(void (^)())batch
{
	NSDate *now = [NSDate date];
	NSLog(@"%s %f", __func__, [now timeIntervalSinceDate:_lastFireDate]);
//	[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];
//	if ([now timeIntervalSinceDate:_lastFireDate] > _interval) {
		_lastFireDate = now;
		batch();
//	[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:_interval + 1]];

		NSLog(@"done");
//	}
}

- (void)performBatch:(void (^)())batch after:(NSTimeInterval)duration
{
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		batch();
	});
}

@end

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
	[self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[viewController.view removeFromSuperview];
	viewController.view.frame = self.contentView.bounds;
	if (_viewController != viewController) {
		[_viewController willMoveToParentViewController:nil];
		[_viewController removeFromParentViewController];
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

@interface MTMetroViewController () <UIScrollViewDelegate, UICollectionViewDataSource, MTMetroLayoutDelegatePivot>
@end

@implementation MTMetroViewController
{
	NSMutableArray *_mutableViewControllers;
	
	NSUInteger _currentIndex;
	
	MTBatchController *_batchController;
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
		self.collectionView.backgroundColor = [UIColor clearColor];
		self.collectionView.dataSource = self;
		self.collectionView.delegate = self;
		[self.view addSubview:self.collectionView];
		
		
		[self.collectionView registerClass:[MTCollectionViewCell class] forCellWithReuseIdentifier:@"MTCollectionViewCell"];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
//	[self.collectionView reloadData];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.collectionView reloadData];
	[_batchController performBatch:^{
		[self moveViewControllerAtIndex:_currentIndex animated:NO];
	}];
	double delayInSeconds = 2.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		
	});
}

#pragma mark - Private method

- (void)initialize
{
	_metroLayout = [[MTMetroLayoutPivot alloc] init];
	_currentIndex = 0;
	
	_batchController = [[MTBatchController alloc] init];
	
	[_batchController registerSelector:@selector(setSelectedIndex:animated:)];
	[_batchController registerSelector:@selector(renewViewControllers:animated:)];
}

- (void)renewViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
	if (self.viewControllers.count) {
		[self.collectionView performBatchUpdates:^{
			NSRange range = NSMakeRange(0, _mutableViewControllers.count);
			[_mutableViewControllers removeAllObjects];
			[self.collectionView deleteSections:[NSIndexSet indexSetWithIndexesInRange:range]];
		} completion:^(BOOL finished) {
			[self.collectionView performBatchUpdates:^{
				NSRange range = NSMakeRange(0, viewControllers.count);
				_mutableViewControllers = [viewControllers mutableCopy];
				[self.collectionView insertSections:[NSIndexSet indexSetWithIndexesInRange:range]];
			} completion:^(BOOL finished) {
				[_batchController performBatch:^{
					[self moveViewControllerAtIndex:_currentIndex animated:animated];
				} after:2];
			}];
		}];
	} else {
		
		NSLog(@"%s", __func__);
		_mutableViewControllers = [viewControllers mutableCopy];
		[self.collectionView reloadData];
		
		[_batchController performBatch:^{
			[self moveViewControllerAtIndex:_currentIndex animated:animated];
		}];
	}
}


- (void)moveViewControllerAtIndex:(NSInteger)selectedIndex animated:(BOOL)animated
{
	NSLog(@"%d %d", selectedIndex, _selectedIndex);
//	if (selectedIndex != _selectedIndex) {
		//TODO:
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:selectedIndex];
	UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
	[self.collectionView setContentOffset:attr.frame.origin animated:animated];
//		[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
		_selectedIndex = selectedIndex;
//	}
}


#pragma mark -

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
	[self setSelectedIndex:selectedIndex animated:NO];
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
	_currentIndex = selectedIndex;
	if (_selectedIndex != selectedIndex) {
		[_batchController performBatch:^{
			[self moveViewControllerAtIndex:selectedIndex animated:animated];
		}];
	}
}

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
		[_batchController performBatch:^{
			[self renewViewControllers:viewControllers animated:animated];
		}];
	}
}

#pragma mark -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:scrollView.contentOffset];
	_currentIndex = indexPath.section;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:scrollView.contentOffset];
	_currentIndex = indexPath.section;
}

#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return self.viewControllers.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//	return self.viewControllers.count;
	return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	MTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MTCollectionViewCell" forIndexPath:indexPath];
	
	UIViewController *viewController = self.viewControllers[indexPath.section];
	
	[cell updateViewController:viewController parentViewController:self];
	
	return cell;
}

#pragma mark -

- (NSString *)collectionView:(UICollectionView *)collectionView titleForHeaderInSection:(NSInteger)section
{
	return [self.viewControllers[section] title];
}

@end
