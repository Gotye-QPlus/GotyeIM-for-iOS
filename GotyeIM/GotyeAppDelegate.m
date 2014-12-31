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
#import "GotyeOCAPI.h"

#import "iflyMSC/IFlySpeechUtility.h"

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
    
    [GotyeOCAPI init:/*@"ccbfcd8e-4393-482c-9808-69dce84015d8"*/@"9c236035-2bf4-40b0-bfbf-e8b6dec54928"  packageName:@"gotyeimapp"];
    
    NSLog(@"api verison: %@", [GotyeOCAPI getVersion]);
    
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@", @"548571bd", @"20000"];
    
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];

    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
//    [GotyeHistoryManager defaultManager];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"注册设备成功: %@", deviceToken);
#ifdef DEBUG
    NSString *certName = @"GotyeIMDev"; 
#else
    NSString *certName = @"GotyeIMDis";
#endif
    
    [GotyeOCAPI registerAPNS:[deviceToken description] certName:certName];
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
    int decrement = application.applicationIconBadgeNumber - [GotyeOCAPI getTotalUnreadMessageCount];
    application.applicationIconBadgeNumber = [GotyeOCAPI getTotalUnreadMessageCount];
    [GotyeOCAPI updateUnreadMessageCount:decrement];
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
