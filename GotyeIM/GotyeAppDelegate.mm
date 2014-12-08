//
//  GotyeAppDelegate.m
//  GotyeIM
//
//  Created by Peter on 14-9-26.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeAppDelegate.h"
#import "GotyeTabViewController.h"

#import "GotyeUIUtil.h"
#import "GotyeDelegateManager.h"
#import "GotyeHistoryManager.h"

@implementation GotyeAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController = [[GotyeTabViewController alloc] initWithNibName:@"GotyeTabViewController.xib" bundle:nil];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.navController.navigationBar.translucent = NO;
    [self.navController.navigationBar setBarTintColor:Common_Color_Def_Nav];
    [self.navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
    [self.navController.navigationBar setTintColor:[UIColor whiteColor]];
    //[[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window.rootViewController = self.navController;

    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    apiist->init("9c236035-2bf4-40b0-bfbf-e8b6dec54928"/*388d424f-5293-44b5-bfd7-28666d8ad685*/, "gotyeimapp");
    
    NSLog(@"api verison: %s", apiist->getVersion().c_str());
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
//    [GotyeHistoryManager defaultManager];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"注册设备成功: %@", deviceToken);
#ifdef DEBUG
    NSString *certName = @"cpp-dev1";
#else
    NSString *certName = @"cpp-dev1";
#endif
    
    apiist->registerAPNS([[deviceToken description] UTF8String], [certName UTF8String]);
    //[GotyeAPI registerRemoteNotificationWithDeviceToken:deviceToken certName:certName];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"注册设备失败: %@", error);
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"注册推送失败" message:[error description] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    int decrement = application.applicationIconBadgeNumber - apiist->getTotalUnreadMessageCount();
    application.applicationIconBadgeNumber = apiist->getTotalUnreadMessageCount();
    apiist->updateUnreadMessageDecrement(decrement);
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
