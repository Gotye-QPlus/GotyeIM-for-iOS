//
//  GotyeGroupSelUserController.m
//  GotyeIM
//
//  Created by Peter on 14-10-9.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeGroupSelUserController.h"

#import "GotyeContactViewController.h"

#import "GotyeUIUtil.h"

@interface GotyeGroupSelUserController ()

@end

#define TestCount 10

#define Target_key_Select   @"TargetSelect"

@implementation GotyeGroupSelUserController

- (id)initWithGroup:(GotyeOCGroup*)group
{
    self = [self init];
    if(self)
    {
        newGroup = group;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    
    self.navigationItem.title = @"发起群聊";
    
    confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 28)];
    
    [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    [confirmButton setBackgroundImage:[UIImage imageNamed:@"button_white"] forState:UIControlStateNormal];
    [confirmButton setBackgroundImage:[UIImage imageNamed:@"button_white_down"] forState:UIControlStateHighlighted];
    [confirmButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [confirmButton setTitleColor:Common_Color_Def_Nav forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:confirmButton];
    
    self.tableView.sectionIndexColor = [UIColor lightGrayColor];
    
    [self resetContactDictionary];
}

- (void)confirmClick:(id)sender
{
    for (int i=0; i<sortedKeys.count; i++)
    {
        NSString *key = sortedKeys[i];
        NSArray *sectionArray = contactDic[key];
        for (NSString *username in sectionArray)
        {
            if([checkDic[username] boolValue])
                [GotyeOCAPI inviteUserToGroup:[GotyeOCUser userWithName:username] group:newGroup inviteMessage:@"快来看看哦。"];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetContactDictionary
{
    contactDic = [NSMutableDictionary dictionary];
    checkDic = [NSMutableDictionary dictionary];
    
    friendList = [GotyeOCAPI getLocalFriendList];
    
    for(GotyeOCUser* user in friendList)
    {
        NSString *username = user.name;
        NSString *key = [[username substringToIndex:1] uppercaseString];
        
        NSMutableArray *sectionArray = contactDic[key];
        if(sectionArray == nil)
        {
            sectionArray = [NSMutableArray array];
            [contactDic setObject:sectionArray forKey:key];
        }
        
        [sectionArray addObject:username];
        checkDic[username] = [NSNumber numberWithBool:NO];
    }
    
    NSArray *keys = [contactDic allKeys];
    sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
    
    [self.tableView reloadData];
}

- (void)checkButtonClick:(UIButton*)sender
{
    sender.selected = !sender.isSelected;
    
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *key = sortedKeys[indexPath.section];
    NSArray *sectionArray = contactDic[key];
    NSString *username = sectionArray[indexPath.row];
    
    checkDic[username] = [NSNumber numberWithBool:sender.isSelected];
    
    int checkCount = 0;
    
    for (NSNumber *isCheckNum in checkDic.allValues)
    {
        if(isCheckNum.boolValue)
            checkCount ++;
    }
    
    if(checkCount > 0)
        [confirmButton setTitle:[NSString stringWithFormat:@"确认(%d)", checkCount] forState:UIControlStateNormal];
    else
        [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
}

#pragma mark - table delegate & data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sortedKeys.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = sortedKeys[section];
    NSArray *sectionArray = contactDic[key];
    return sectionArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *key = sortedKeys[section];
    return key;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sortedKeys;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ContactCellIdentifier = @"ContactCellIdentifier";
    
    GotyeContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GotyeContactCell" owner:self options:nil] firstObject];
        [cell.buttonCheck addTarget:self action:@selector(checkButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    }
    
    NSString *key = sortedKeys[indexPath.section];
    NSArray *sectionArray = contactDic[key];
    
    for(GotyeOCUser* user in friendList)
    {
        if([user.name isEqualToString:sectionArray[indexPath.row]])
        {
            NSString *username = user.name;
            
            cell.imageHead.image = [GotyeUIUtil getHeadImage:user.icon.path defaultIcon:@"head_icon_user"];
            cell.labelUsername.text = username;
//            cell.showNickName = YES;
//            cell.labelNickname.text = user.nickname);
            
            cell.buttonCheck.hidden = NO;
            cell.buttonCheck.selected = [checkDic[username] boolValue];
            
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
