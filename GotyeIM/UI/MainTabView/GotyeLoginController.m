//
//  GotyeLoginController.m
//  GotyeIM
//
//  Created by Peter on 14-10-13.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeLoginController.h"

#import "GotyeUIUtil.h"

#import "GotyeOCAPI.h"
#import "GotyeSettingManager.h"

@interface GotyeLoginController () <GotyeOCDelegate>

@end

@implementation GotyeLoginController

@synthesize textUsername, textPassword;

-(IBAction)doneClick:(id)sender
{
    [sender resignFirstResponder];
}

-(IBAction)onBtnLoginClick:(id)sender
{
    if(textUsername.text.length > 0)
    {
        NSString *password = textPassword.text.length > 0 ? textPassword.text : nil;
        
        if([GotyeOCAPI login:textUsername.text password:password] == GotyeStatusCodeWaitingCallback)
            [GotyeUIUtil showHUD:@"登录中" toView:self.view];
    }
}

- (void)onLogin:(GotyeStatusCode)code user:(GotyeOCUser *)user
{
    if(code == GotyeStatusCodeOK || code == GotyeStatusCodeOfflineLoginOK || code == GotyeStatusCodeReloginOK)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [[GotyeSettingManager defaultManager] setLoginUserName:[GotyeOCAPI getLoginUser].name];
        
        [GotyeOCAPI beginReceiveOfflineMessage];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:textUsername.text forKey:LoginUserNameKey];
        [userDefaults setObject:textPassword.text forKey:LoginPasswordKey];
        [userDefaults setBool:YES forKey:AutoLoginKey];
        [userDefaults synchronize];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"登录失败"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [GotyeUIUtil hideHUD:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [GotyeOCAPI addListener:self];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    textUsername.text = [userDefaults stringForKey:LoginUserNameKey];
    textPassword.text = [userDefaults stringForKey:LoginPasswordKey];
    
    BOOL autologin = [userDefaults boolForKey:AutoLoginKey];
    if(autologin)
    {
        //[self onBtnLoginClick:nil];
        
        [self performSelector:@selector(onBtnLoginClick:) withObject:nil afterDelay:0.2];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [GotyeOCAPI removeListener:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
