//
//  MTMetroNavigationController.m
//  MTMetroViewLayoutDemo
//
//  Created by 林 達也 on 2013/06/11.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "MTMetroNavigationController.h"

@implementation MTMetroNavigationBar

+ (void)initialize
{
	[[self appearance] setShadowImage:[[UIImage alloc] init]];
	[[self appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
	[[self appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsLandscapePhone];
	[[self appearance] setTitleVerticalPositionAdjustment:6 forBarMetrics:UIBarMetricsDefault];
	[[self appearance] setTitleVerticalPositionAdjustment:6 forBarMetrics:UIBarMetricsLandscapePhone];
//	[[self appearance] setTitleTextAttributes:@{
//						  UITextAttributeFont: [UIFont fontWithName:@"Avenir-Light" size:18],
//					 UITextAttributeTextColor: [UIColor lightGrayColor],
//	 }];
	
	[[UIBarButtonItem appearanceWhenContainedIn:[self class], nil] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//	[[UIBarButtonItem appearanceWhenContainedIn:[self class], nil] setBackButtonBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//	[[UIBarButtonItem appearanceWhenContainedIn:[self class], nil] setBackgroundVerticalPositionAdjustment:25 forBarMetrics:UIBarMetricsDefault];
//	[[UIBarButtonItem appearanceWhenContainedIn:[self class], nil] setBackButtonBackgroundVerticalPositionAdjustment:10 forBarMetrics:UIBarMetricsDefault];
	//	[[self appearance] setTitlePositionAdjustment:UIOffsetMake(-80, 0) forBarMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearanceWhenContainedIn:[self class], nil]
	 setTitleTextAttributes:@{
	 UITextAttributeFont: [UIFont fontWithName:@"Avenir-Light" size:18],
	 UITextAttributeTextColor: [UIColor lightGrayColor],
	 } forState:UIControlStateNormal];
}


- (CGSize)sizeThatFits:(CGSize)size
{
	CGRect frame = self.frame;
	frame.size.height = 32;
	return frame.size;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	
    for (UINavigationItem *v in self.items) {
        if([v isKindOfClass:[UINavigationItem class]]){
			[self adjustTitleView:v];
            for(UIBarButtonItem *item in v.rightBarButtonItems){
                [self adjustRightButtonItem:item];
            }
            for(UIBarButtonItem *item in v.leftBarButtonItems){
				[self adjustLeftButtonItem:item];
            }
        }
    }
}

- (void)adjustTitleView:(UINavigationItem *)item
{
	if (item.title) {
		if (item.titleView == nil) {
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 32)];
			label.text = item.title;
			label.textAlignment = NSTextAlignmentLeft;
			label.backgroundColor = [UIColor clearColor];
			label.textColor = [UIColor lightGrayColor];
			label.font = [UIFont fontWithName:@"Avenir-Light" size:18];
			item.titleView = label;
		}
		
//		CGFloat offset = 0;
//		for (UIBarButtonItem *barButtonItem in item.leftBarButtonItems) {
//			offset += barButtonItem.width;
//			NSLog(@"%@", barButtonItem.customView);
//		}
		CGRect frame = item.titleView.frame;
		frame.origin.x = 50;
		item.titleView.frame = frame;
	}
}

- (void)adjustRightButtonItem:(UIBarButtonItem *)item
{
	
}

- (void)adjustLeftButtonItem:(UIBarButtonItem *)item
{
}


@end

#pragma mark -

@interface MTMetroNavigationController () <UINavigationBarDelegate>

@end

@implementation MTMetroNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	self = [super initWithNavigationBarClass:[MTMetroNavigationBar class] toolbarClass:nil];
	if (self) {
		[self pushViewController:rootViewController animated:NO];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNavigationBarClass:[MTMetroNavigationBar class] toolbarClass:nil];
	if (self) {
		
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
