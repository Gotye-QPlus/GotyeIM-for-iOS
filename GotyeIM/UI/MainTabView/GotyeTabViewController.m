//
//  GotyeTabViewController.m
//  GotyeIM
//
//  Created by Peter on 14-9-28.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeTabViewController.h"
#import "GotyeUIUtil.h"

#import "GotyeMessageViewController.h"
#import "GotyeContactViewController.h"
#import "GotyeSettingViewController.h"

#import "GotyeAddFriendController.h"
#import "GotyeGroupCreateController.h"

#import "GotyeLoginController.h"

#import "GotyeOCAPI.h"

@interface GotyeTabViewController () <UITabBarControllerDelegate, GotyeOCDelegate>

@end

@implementation GotyeTabViewController

@synthesize viewMenu;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addChildViewController:[[GotyeMessageViewController alloc] init]];
    [self addChildViewController:[[GotyeContactViewController alloc] init]];
    [self addChildViewController:[[GotyeSettingViewController alloc] init]];
    
    [self.tabBar setTranslucent:NO];
    [self.tabBar setBarTintColor:Common_Color_Def_Gray];
    [self.tabBar setSelectedImageTintColor:[UIColor whiteColor]];
    [self.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"tab_button_select_back"]];
    
    rightButton = [[UIBarButtonItem alloc]
                   initWithImage:[UIImage imageNamed:@"nav_button_add"]
                   style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(showAddMenu:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self createMenuView];
    
    self.delegate = self;
    [GotyeOCAPI addListener:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(![GotyeOCAPI isOnline])
    {
        GotyeLoginController *loginController = [[GotyeLoginController alloc] init];
        [self presentViewController:loginController animated:NO completion:nil];
    }
    
    [self.tabBar setBarTintColor:Common_Color_Def_Gray];
    
    [self.selectedViewController viewWillAppear:animated];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if([viewController isKindOfClass:[GotyeSettingViewController class]])
        self.navigationItem.rightBarButtonItem = nil;
    else
        self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)createMenuView
{
    viewMenu = [[UIView alloc] initWithFrame:CGRectMake(198, 5, 116, 93)];
    
    UIButton *button0 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 116, 50)];
    [button0 setBackgroundImage:[UIImage imageNamed:@"nav_menu_button_0"] forState:UIControlStateNormal];
    [button0 setBackgroundImage:[UIImage imageNamed:@"nav_menu_button_0_down"] forState:UIControlStateHighlighted];
    [button0 setImage:[UIImage imageNamed:@"nav_menu_icon_0"] forState:UIControlStateNormal];
    [button0 setImageEdgeInsets:UIEdgeInsetsMake(7, 0, 0, 0)];
    [button0.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button0.titleLabel setTextColor:[UIColor whiteColor]];
    [button0 setTitle:@"添加好友" forState:UIControlStateNormal];
    [button0 setTitleEdgeInsets:UIEdgeInsetsMake(10, 8, 0, 0)];
    [button0 setAdjustsImageWhenHighlighted:NO];
    
    [button0 addTarget:self action:@selector(addFriendsClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 51, 116, 42)];
    [button1 setBackgroundImage:[UIImage imageNamed:@"nav_menu_button_1"] forState:UIControlStateNormal];
    [button1 setBackgroundImage:[UIImage imageNamed:@"nav_menu_button_1_down"] forState:UIControlStateHighlighted];
    [button1 setImage:[UIImage imageNamed:@"nav_menu_icon_1"] forState:UIControlStateNormal];
    [button1 setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 0)];
    [button1.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button1.titleLabel setTextColor:[UIColor whiteColor]];
    [button1 setTitle:@"发起群聊" forState:UIControlStateNormal];
    [button1 setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [button1 setAdjustsImageWhenHighlighted:NO];
    
    [button1 addTarget:self action:@selector(startGroupClick:) forControlEvents:UIControlEventTouchUpInside];

    [viewMenu addSubview:button0];
    [viewMenu addSubview:button1];
    
    [self.view addSubview:viewMenu];
    
    viewMenu.hidden = YES;
}

- (void)addFriendsClick:(id)sender
{
    GotyeAddFriendController *viewController = [[GotyeAddFriendController alloc] init];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    [self showAddMenu:self.navigationItem.rightBarButtonItem];
}

- (void)startGroupClick:(id)sender
{
    GotyeGroupCreateController *viewController = [[GotyeGroupCreateController alloc] init];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    [self showAddMenu:self.navigationItem.rightBarButtonItem];
}

- (void)showAddMenu:(id)sender
{
    CGRect frame = viewMenu.frame;
    if(viewMenu.hidden)
    {
        viewMenu.hidden = NO;
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(frame.size.width / 2, -frame.size.height / 2);
        transform = CGAffineTransformScale(transform, 0.01, 0.01);
        viewMenu.transform = transform;
        
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGAffineTransform transform = CGAffineTransformMakeTranslation(-frame.size.width / 20, frame.size.height / 20);
                             transform = CGAffineTransformScale(transform, 1.1, 1.1);
                             viewMenu.transform = transform;
                       }
                         completion:^(BOOL finished){
                             if (finished){
                                 [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveLinear
                                                  animations:^{
                                                      viewMenu.transform = CGAffineTransformIdentity;
                                                  }
                                                  completion:^(BOOL finished){
                                                      if (finished){
                                                          
                                                      }
                                                  }
                                  ];
                             }
                         }
         ];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
        button.tag = 10000;
        [button addTarget:self action:@selector(showAddMenu:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:button belowSubview:viewMenu];
    }
    else
    {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGAffineTransform transform = CGAffineTransformMakeTranslation(frame.size.width / 2, -frame.size.height / 2);
                             transform = CGAffineTransformScale(transform, 0.01, 0.01);
                             viewMenu.transform = transform;
                         }
                         completion:^(BOOL finished){
                             if (finished){
                                 viewMenu.transform = CGAffineTransformIdentity;
                                 viewMenu.hidden = YES;
                             }
                         }
         ];
        
        [(UIButton*)[self.view viewWithTag:10000] removeFromSuperview];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [GotyeUIUtil popToRootViewControllerForNavgaion:self.navigationController animated:NO];
    
    GotyeLoginController *loginController = [[GotyeLoginController alloc] init];
    [self presentViewController:loginController animated:YES completion:nil];
}

- (void)onLogout:(GotyeStatusCode)code
{
    if(code == GotyeStatusCodeOK)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"退出成功。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:NO forKey:AutoLoginKey];
        [userDefaults synchronize];
    }
    else if(code == GotyeStatusCodeForceLogout)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"你的账号已经在其他设备登录。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    else if(code == GotyeStatusCodeNetworkDisConnected)
    {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"网络错误中断。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];*/
    }
}

- (void)onGetProfile:(GotyeStatusCode)code user:(GotyeOCUser *)user
{
    if(code == GotyeStatusCodeOK)
    {
        [GotyeOCAPI downloadMedia:user.icon];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
