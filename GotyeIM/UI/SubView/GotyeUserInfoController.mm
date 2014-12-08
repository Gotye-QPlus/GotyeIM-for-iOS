//
//  GotyeUserInfoController.m
//  GotyeIM
//
//  Created by Peter on 14-10-23.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeUserInfoController.h"

#import "GotyeDelegateManager.h"

#import "GotyeUIUtil.h"
#import "GotyeChatViewController.h"

@interface GotyeUserInfoController () <GotyeUIDelegate>

@end

@implementation GotyeUserInfoController

@synthesize imageHead, labelID, labelUsername, buttonKickout, buttonAdd, buttonBlock, buttonMessage;

- (id)initWithTarget:(gotyeapi::GotyeUser)target groupID:(long long)gID
{
    self = [super init];
    if (self) {
        userTarget = target;
        groupID = gID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"详细信息";
    
    if(groupID == 0)
        buttonKickout.hidden = YES;
    
    if(userTarget.isFriend)
        buttonAdd.enabled = NO;
    
    if(userTarget.isBlocked)
        buttonBlock.enabled = NO;
    
    if(apiist->getLoginUser().name.compare(userTarget.name) == 0)
    {
        buttonAdd.enabled = NO;
        buttonMessage.enabled = NO;
    }
    
    apiist->getUserDetail(userTarget, true);
    
    [self setUserInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    delegateist->addDelegate(self);
}

- (void)viewWillDisappear:(BOOL)animated
{
    delegateist->removeDelegate(self);
}

- (void)onDownloadMedia:(GotyeStatusCode)code media:(gotyeapi::GotyeMedia)media
{
    if(code == GotyeStatusCodeOK)
    {
        [self setUserInfo];
    }
}

-(void)onGetUserDetail:(GotyeStatusCode)code user:(GotyeUser)user
{
    if(code == GotyeStatusCodeOK)
    {
        if(user.name.compare(userTarget.name) == 0)
        {
            userTarget = user;
            apiist->downloadMedia(userTarget.icon);
            [self setUserInfo];
        }
    }
}

- (void)setUserInfo
{
    labelUsername.text = NSStringUTF8(userTarget.name);
    labelID.text = NSStringUTF8(userTarget.nickname); //[NSString stringWithFormat:@"ID:%lld",userTarget.id];
    imageHead.image = [GotyeUIUtil getHeadImage:NSStringUTF8(userTarget.icon.path) defaultIcon:@"head_icon_user"];
}

- (IBAction)addFriendClick:(id)sender
{
    apiist->reqAddFriend(userTarget);
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addBlockClick:(id)sender
{
    apiist->reqAddBlocked(userTarget);
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)talkToClick:(id)sender
{
    UINavigationController *navController = self.navigationController;
    [GotyeUIUtil popToRootViewControllerForNavgaion:navController animated:NO];
    
    GotyeChatViewController *viewController = [[GotyeChatViewController alloc] initWithTarget:userTarget];
    [navController pushViewController:viewController animated:YES];
}

- (IBAction)kickoutClick:(id)sender
{
    GotyeGroup group(groupID);
    apiist->kickoutGroupMember(group, userTarget);
}

- (IBAction)reportClick:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gotye UI delegates

- (void)onKickOutUser:(GotyeStatusCode)code group:(gotyeapi::GotyeGroup)group user:(gotyeapi::GotyeUser)user
{
    if(code == GotyeStatusCodeOK)
    {
        GotyeGroup group(groupID);
        apiist->reqGroupMemberList(group, 0);
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
