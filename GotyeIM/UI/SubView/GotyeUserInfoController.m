//
//  GotyeUserInfoController.m
//  GotyeIM
//
//  Created by Peter on 14-10-23.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeUserInfoController.h"

#import "GotyeOCAPI.h"

#import "GotyeUIUtil.h"
#import "GotyeChatViewController.h"

@interface GotyeUserInfoController () <GotyeOCDelegate>

@end

@implementation GotyeUserInfoController

@synthesize imageHead, labelID, labelUsername, buttonKickout, buttonAdd, buttonBlock, buttonMessage;

- (id)initWithTarget:(GotyeOCUser*)target groupID:(long long)gID
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
    
    if([[GotyeOCAPI getLoginUser].name isEqualToString:userTarget.name])
    {
        buttonAdd.enabled = NO;
        buttonMessage.enabled = NO;
    }
    
    [GotyeOCAPI getUserDetail:userTarget forceRequest:YES];
    
    [self setUserInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [GotyeOCAPI addListener:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [GotyeOCAPI removeListener:self];
}

- (void)onDownloadMedia:(GotyeStatusCode)code media:(GotyeOCMedia*)media
{
    if(code == GotyeStatusCodeOK)
    {
        [self setUserInfo];
    }
}

-(void)onGetUserDetail:(GotyeStatusCode)code user:(GotyeOCUser*)user
{
    if(code == GotyeStatusCodeOK)
    {
        if([user.name isEqualToString:userTarget.name])
        {
            userTarget = user;
            [GotyeOCAPI downloadMedia:userTarget.icon];
            [self setUserInfo];
        }
    }
}

- (void)setUserInfo
{
    labelUsername.text = userTarget.name;
    labelID.text = userTarget.nickname;
    imageHead.image = [GotyeUIUtil getHeadImage:userTarget.icon.path defaultIcon:@"head_icon_user"];
}

- (IBAction)addFriendClick:(id)sender
{
    [GotyeOCAPI reqAddFriend:userTarget];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addBlockClick:(id)sender
{
    [GotyeOCAPI reqAddBlocked:userTarget];
    
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
    GotyeOCGroup* group = [GotyeOCGroup groupWithId:groupID];
    [GotyeOCAPI kickoutGroupMember:group user:userTarget];
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

- (void)onKickOutUser:(GotyeStatusCode)code group:(GotyeOCGroup*)group user:(GotyeOCUser*)user
{
    if(code == GotyeStatusCodeOK)
    {
        GotyeOCGroup* group = [GotyeOCGroup groupWithId:groupID];
        [GotyeOCAPI reqGroupMemberList:group pageIndex:0];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
