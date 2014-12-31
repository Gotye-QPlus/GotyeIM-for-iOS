//
//  GotyeGroupCreateController.m
//  GotyeIM
//
//  Created by Peter on 14-10-9.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeGroupCreateController.h"
#import "GotyeUIUtil.h"

#import "GotyeGroupSelUserController.h"
#import "GotyeOCAPI.h"

@interface GotyeGroupCreateController () <GotyeOCDelegate>

@end

@implementation GotyeGroupCreateController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"发起群聊";
}

- (void)viewWillAppear:(BOOL)animated
{
    [GotyeOCAPI addListener:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [GotyeOCAPI removeListener:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPublicClick:(UIButton*)sender
{
    sender.selected = !sender.isSelected;
}

- (IBAction)confirmClick:(id)sender
{
    GotyeOCGroup* group = [[GotyeOCGroup alloc] init];
    group.name = self.textName.text;
    group.ownerType = self.buttonPublic.isSelected ? GotyeGroupTypePublic : GotyeGroupTypePrivate;
    group.needAuthentication = self.buttonVerify.isSelected;
    
    [GotyeOCAPI createGroup:group];
}

#pragma mark - Gotye UI delegates

- (void)onCreateGroup:(GotyeStatusCode)code group:(GotyeOCGroup*)group
{
    if(code == GotyeStatusCodeOK)
    {
        UINavigationController *navController = self.navigationController;
        [navController popViewControllerAnimated:NO];
        
        GotyeGroupSelUserController *viewController = [[GotyeGroupSelUserController alloc] initWithGroup:group];
        [navController pushViewController:viewController animated:YES];
    }
}

@end
