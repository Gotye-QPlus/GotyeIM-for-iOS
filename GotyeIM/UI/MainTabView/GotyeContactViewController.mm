//
//  GotyeContactViewController.m
//  GotyeIM
//
//  Created by Peter on 14-9-28.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeContactViewController.h"

#import "GotyeUIUtil.h"
#import "GotyeChatRoomListController.h"
#import "GotyeGroupListController.h"

#import "GotyeDelegateManager.h"
#import "GotyeChatViewController.h"

@interface GotyeContactViewController () <GotyeUIDelegate, GotyeContextMenuCellDataSource, GotyeContextMenuCellDelegate>

@end

@implementation GotyeContactViewController

@synthesize topView, buttonBlack, buttonContact;

- (id)init
{
    self = [super init];
    if (self) {
        self.tabBarItem.image = [[UIImage imageNamed:@"tab_button_contact"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_button_contact"];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.tableHeaderView = topView;
    self.tableView.sectionIndexColor = [UIColor lightGrayColor];
    
    [self btnContackClick:buttonContact];
}

- (void)viewWillAppear:(BOOL)animated
{
    delegateist->addDelegate(self);
    
    self.tabBarController.navigationItem.title = @"联系人";
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    delegateist->removeDelegate(self);
}

- (IBAction)btnContackClick:(id)sender
{
    buttonContact.selected = YES;
    buttonBlack.selected = NO;
    
    apiist->reqFriendList();
    [self.tableView reloadData];
}

- (IBAction)btnBlackClick:(id)sender
{
    buttonContact.selected = NO;
    buttonBlack.selected = YES;
    
    apiist->reqBlockedList();
    [self.tableView reloadData];
}

- (void)resetContactDictionary
{
    contactDic = [NSMutableDictionary dictionary];
    
    if(buttonContact.isSelected)
        userList = apiist->getLocalFriendList();
    else
        userList = apiist->getLocalBlockedList();
    
    for(GotyeUser user:userList)
    {
        NSString *username = NSStringUTF8(user.name);
        NSString *key = [[username substringToIndex:1] uppercaseString];
        
        NSMutableArray *sectionArray = contactDic[key];
        if(sectionArray == nil)
        {
            sectionArray = [NSMutableArray array];
            [contactDic setObject:sectionArray forKey:key];
        }
        
        [sectionArray addObject:username];
    }
    
    NSArray *keys = [contactDic allKeys];
    sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
}

#pragma mark - Gotye UI delegates

- (void)onGetFriendList:(GotyeStatusCode)code friendlist:(std::vector<GotyeUser>)friendlist
{
    if(code == GotyeStatusCodeOK)
    {
        for(GotyeUser user: friendlist)
            apiist->downloadMedia(user.icon);
        
        [self.tableView reloadData];
    }
}

- (void)onGetBlockedList:(GotyeStatusCode)code blockedlist:(std::vector<GotyeUser>)blockedlist
{
    if(code == GotyeStatusCodeOK)
    {
        for(GotyeUser user: blockedlist)
            apiist->downloadMedia(user.icon);
        
        [self.tableView reloadData];
    }
}

-(void)onDownloadMedia:(GotyeStatusCode)code media:(gotyeapi::GotyeMedia)media
{
    [self.tableView reloadData];
}

- (void)onRemoveFriend:(GotyeStatusCode)code user:(gotyeapi::GotyeUser)user
{
    if(code == GotyeStatusCodeOK)
    {
        NSString *key = sortedKeys[deletingItem.section-(buttonContact.isSelected ? 1 : 0)];
        NSArray *sectionArray = contactDic[key];

        if(sectionArray.count <= 1)
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:deletingItem.section] withRowAnimation:UITableViewRowAnimationMiddle];
        else
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:deletingItem]withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    [GotyeUIUtil hideHUD];
}

- (void)onRemoveBlocked:(GotyeStatusCode)code user:(gotyeapi::GotyeUser)user
{
    if(code == GotyeStatusCodeOK)
    {
        NSString *key = sortedKeys[deletingItem.section-(buttonContact.isSelected ? 1 : 0)];
        NSArray *sectionArray = contactDic[key];
        
        if(sectionArray.count <= 1)
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:deletingItem.section] withRowAnimation:UITableViewRowAnimationMiddle];
        else
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:deletingItem]withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    [GotyeUIUtil hideHUD];
}

-(void) onAddBlocked:(GotyeStatusCode)code user:(GotyeUser)user
{
    [GotyeUIUtil hideHUD];
}

#pragma mark - table delegate & data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self resetContactDictionary];
    
    return sortedKeys.count + (buttonContact.isSelected ? 1 : 0);
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(buttonContact.isSelected && section == 0)
        return 2;
    
    NSString *key = sortedKeys[section - (buttonContact.isSelected ? 1 : 0)];
    NSArray *sectionArray = contactDic[key];
    return sectionArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(buttonContact.isSelected && section == 0)
        return nil;
    
    NSString *key = sortedKeys[section - (buttonContact.isSelected ? 1 : 0)];
    return key;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *titleArray = [NSMutableArray arrayWithArray:sortedKeys];
    
    if(buttonContact.isSelected)
        [titleArray insertObject:@"" atIndex:0];
    
    return titleArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ContactCellIdentifier = @"ContactCellIdentifier";
    
    GotyeContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GotyeContactCell" owner:self options:nil] firstObject];
    }
    
    UIImage *headImage;
    NSString *titleStr;
    
    cell.showNickName = NO;
    if(buttonContact.isSelected && indexPath.section == 0 && indexPath.row == 0)
    {
        headImage= [UIImage imageNamed:@"head_icon_room"];
        titleStr = @"聊天室";
        cell.dataSource = nil;
        cell.delegate = nil;
    }
    else if(buttonContact.isSelected && indexPath.section == 0 && indexPath.row == 1)
    {
        headImage= [UIImage imageNamed:@"head_icon_group"];
        titleStr = @"群聊";
        cell.dataSource = nil;
        cell.delegate = nil;
    }
    else
    {
        NSString *key = sortedKeys[indexPath.section- (buttonContact.isSelected?1:0)];
        NSArray *sectionArray = contactDic[key];
        
        for(GotyeUser user:userList)
        {
            if([NSStringUTF8(user.name) isEqualToString:sectionArray[indexPath.row]])
            {
                headImage= [GotyeUIUtil getHeadImage:NSStringUTF8(user.icon.path) defaultIcon:@"head_icon_user"];
                titleStr = NSStringUTF8(user.name);
                
                cell.labelUsername.text = titleStr;
//                cell.labelNickname.text = NSStringUTF8(user.nickname);
//                cell.showNickName = YES;
                
                break;
            }
        }
        cell.dataSource = self;
        cell.delegate = self;
    }
    
    cell.imageHead.image = headImage;
    cell.labelUsername.text = titleStr;
    
    cell.tag = indexPath.row + 1;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        GotyeChatRoomListController *viewController = [[GotyeChatRoomListController alloc] init];
        [self.tabBarController.navigationController pushViewController:viewController animated:YES];
    }
    else if(indexPath.section == 0 && indexPath.row == 1)
    {
        GotyeGroupListController *viewController = [[GotyeGroupListController alloc] init];
        [self.tabBarController.navigationController pushViewController:viewController animated:YES];
    }
    else
    {
        NSString *key = sortedKeys[indexPath.section-(buttonContact.isSelected ? 1 : 0)];
        NSArray *sectionArray = contactDic[key];
        
        for(GotyeUser user:userList)
        {
            if([NSStringUTF8(user.name) isEqualToString:sectionArray[indexPath.row]])
            {
                GotyeChatViewController *viewController = [[GotyeChatViewController alloc] initWithTarget:user];
                [self.tabBarController.navigationController pushViewController:viewController animated:YES];
                
                break;
            }
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark * GotyeContextMenuCell data source

- (NSUInteger)numberOfButtonsInContextMenuCell:(GotyeContextMenuCell *)cell
{
    return (buttonContact.isSelected ? 2 : 1);
}

- (UIButton *)contextMenuCell:(GotyeContextMenuCell *)cell buttonAtIndex:(NSUInteger)index
{
    GotyeContactCell *msgCell = [cell isKindOfClass:[GotyeContactCell class]] ? (GotyeContactCell *)cell : nil;
    switch (index) {
        case 0: return msgCell.buttonDelete;
        case 1: return msgCell.buttonBlock;
        default: return nil;
    }
}

- (GotyeContextMenuCellButtonVerticalAlignmentMode)contextMenuCell:(GotyeContextMenuCell *)cell alignmentForButtonAtIndex:(NSUInteger)index
{
    return GotyeContextMenuCellButtonVerticalAlignmentModeCenter;
}

#pragma mark * GotyeContextMenuCell delegate

- (void)contextMenuCell:(GotyeContextMenuCell *)cell buttonTappedAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0: {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            NSString *key = sortedKeys[indexPath.section-(buttonContact.isSelected ? 1 : 0)];
            NSArray *sectionArray = contactDic[key];
            NSString *username = sectionArray[indexPath.row];
            
            for(GotyeUser user:userList)
            {
                if([NSStringUTF8(user.name) isEqualToString:username])
                {
                    if(buttonContact.isSelected)
                    {
                        apiist->reqRemoveFriend(user);
                        
                        [GotyeUIUtil showHUD:@"删除好友"];
                    }
                    else
                    {
                        apiist->reqRemoveBlocked(user);
                        
                        [GotyeUIUtil showHUD:@"移出黑名单"];
                    }
                    break;
                }
            }
            
            deletingItem = indexPath;
            
        }
            break;
        case 1: {
            
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            NSString *key = sortedKeys[indexPath.section-(buttonContact.isSelected ? 1 : 0)];
            NSArray *sectionArray = contactDic[key];
            NSString *username = sectionArray[indexPath.row];
            
            for(GotyeUser user:userList)
            {
                if([NSStringUTF8(user.name) isEqualToString:username])
                {
                    apiist->reqAddBlocked(user);
                    [GotyeUIUtil showHUD:@"加入黑名单"];
                    break;
                }
            }
        }
            break;
    }
}

@end

@implementation GotyeContactCell

- (void)setShowNickName:(BOOL)showNickName
{
    _showNickName = showNickName;
    
    CGRect frame = self.labelUsername.frame;
    frame.origin.y = _showNickName ? 10 : 20;
    self.labelUsername.frame = frame;
    
    self.labelNickname.hidden = !_showNickName;
}

@end
