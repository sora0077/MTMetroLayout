//
//  MTAppDelegate.m
//  MTMetroViewLayoutDemo
//
//  Created by 林 達也 on 2013/05/05.
//  Copyright (c) 2013年 林 達也. All rights reserved.
//

#import "MTAppDelegate.h"

#import "MTMetroLayout.h"
#import "MTMetroViewController.h"

@implementation MTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
	UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
	MTMetroViewController *rootViewController = (MTMetroViewController *)navController.topViewController;
    
    rootViewController.metroLayout.tintColor = [UIColor whiteColor];
	
	
	rootViewController.title = @"People";
	
	UIViewController *viewController1 = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"UIViewController1"];
	UIViewController *viewController2 = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"UIViewController2"];
	UIViewController *viewController3 = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"UIViewController3"];
//	UIViewController *viewController4 = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"UIViewController1"];
	
	UIViewController *viewController4 = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"ListViewController"];
	
	viewController1.title = @"all";
	viewController2.title = @"friends";
	viewController3.title = @"other";
	viewController4.title = @"list";
	
	[rootViewController setViewControllers:@[viewController1, viewController2, viewController3, viewController4] animated:NO];
//	rootViewController.selectedIndex = 2;
//	double delayInSeconds = 0.01;
//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		
		[rootViewController setSelectedIndex:2 animated:NO];;
//	});
	
//	double delayInSeconds = 2.0;
//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//		[rootViewController setViewControllers:@[viewController1, viewController2, viewController3, viewController4] animated:YES];
//	});
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
