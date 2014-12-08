//
//  GotyeLoginController.m
//  GotyeIM
//
//  Created by Peter on 14-10-13.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeLoginController.h"

#import "GotyeUIUtil.h"

#import "GotyeDelegateManager.h"
#import "GotyeSettingManager.h"

@interface GotyeLoginController () <GotyeUIDelegate>

@end

@implementation GotyeLoginController

@synthesize textUsername;

-(IBAction)doneClick:(id)sender
{
    [sender resignFirstResponder];
}

-(IBAction)onBtnLoginClick:(id)sender
{
    std::string pwd = "";
    if(textUsername.text.length > 0)
    {
        if(apiist->login([textUsername.text UTF8String]) == GotyeStatusCodeWaitingCallback)
            [GotyeUIUtil showHUD:@"登录中" toView:self.view];
    }
}

- (void)onLogin:(GotyeStatusCode)code user:(GotyeLoginUser)user
{
    if(code == GotyeStatusCodeOK)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [[GotyeSettingManager defaultManager] setLoginUserName:NSStringUTF8(apiist->getLoginUser().name)];
        
        apiist->beginReceiveOfflineMessage();
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

- (void)viewWillAppear:(BOOL)animated
{
    delegateist->addDelegate(self);
}

- (void)viewDidDisappear:(BOOL)animated
{
    delegateist->removeDelegate(self);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
