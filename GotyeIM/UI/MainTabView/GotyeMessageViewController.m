//
//  GotyeTableViewController.m
//  GotyeIM
//
//  Created by Peter on 14-9-29.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeMessageViewController.h"

#import "GotyeNotifyController.h"

#import "GotyeUIUtil.h"

#import "GotyeOCAPI.h"

#import "GotyeChatViewController.h"

@interface GotyeMessageViewController () <GotyeContextMenuCellDataSource, GotyeContextMenuCellDelegate, GotyeOCDelegate>
{
    BOOL enteringRoom;
    
    BOOL isTabTop;
    
    NSArray *notifyList;
    NSArray *sessionList;
}

@end

@implementation GotyeMessageViewController 

- (id)init
{
    self = [super init];
    if (self) {
        self.tabBarItem.image = [[UIImage imageNamed:@"tab_button_message"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_button_message"];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
//    self.tableView.tableHeaderView = viewSearch;
    
    [GotyeOCAPI addListener:self];
    self.tabBarController.navigationItem.title = @"消息";
    
    enteringRoom = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    isTabTop = YES;
    [GotyeOCAPI addListener:self];
    self.tabBarController.navigationItem.title = @"消息";
    
    for(GotyeOCChatTarget* target in sessionList)
    {
        switch (target.type) {
            case GotyeChatTargetTypeUser:
            {
                GotyeOCUser* user = [GotyeOCAPI getUserDetail:target forceRequest:NO];
                [GotyeOCAPI downloadMedia:user.icon];
            }
                break;
                
            case GotyeChatTargetTypeRoom:
            {
                GotyeOCRoom* room = [GotyeOCAPI getRoomDetail:target];
                [GotyeOCAPI downloadMedia:room.icon];
            }
                break;
                
            case GotyeChatTargetTypeGroup:
            {
                GotyeOCGroup* group = [GotyeOCAPI getGroupDetail:target forceRequest:NO];
                [GotyeOCAPI downloadMedia:group.icon];
            }
                break;
        }
    }
    
    notifyList = [GotyeOCAPI getNotifyList];
    sessionList = [GotyeOCAPI getSessionList];

    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    isTabTop= NO;
    //[GotyeOCAPI removeListener:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gotye UI delegates

-(void)onLogin:(GotyeStatusCode)code user:(GotyeOCUser *)user
{
    if(code == GotyeStatusCodeOK || code == GotyeStatusCodeOfflineLoginOK || code == GotyeStatusCodeReloginOK)
    {
        [self.tableView reloadData];
    }
    self.tableView.tableHeaderView = nil;
}

-(void)onLogout:(GotyeStatusCode)code
{
    if(code == GotyeStatusCodeNetworkDisConnected)
    {
        self.tableView.tableHeaderView = self.viewNetworkFail;
        self.labelNetwork.text = @"未连接";
    }
}

-(void)onReconnecting:(GotyeStatusCode)code user:(GotyeOCUser *)user
{
    self.labelNetwork.text = @"连接中...";
}

-(void)onReceiveMessage:(GotyeOCMessage *)message downloadMediaIfNeed:(bool *)downloadMediaIfNeed
{
    if(!isTabTop)
        return;
    
    [self.tableView reloadData];
    
    sessionList = [GotyeOCAPI getSessionList];
    *downloadMediaIfNeed = true;
}

-(void)onReceiveNotify:(GotyeOCNotify *)notify
{
    if(!isTabTop)
        return;
    
    notifyList = [GotyeOCAPI getNotifyList];
    [self.tableView reloadData];
}

-(void)onGetMessageList:(GotyeStatusCode)code msglist:(NSArray *)msglist downloadMediaIfNeed:(bool *)downloadMediaIfNeed
{
    if(!isTabTop)
        return;
    
    if(code == GotyeStatusCodeOK)
        [self.tableView reloadData];
    
    sessionList = [GotyeOCAPI getSessionList];
    *downloadMediaIfNeed = true;
}

- (void)onGetUserInfo:(GotyeStatusCode)code user:(GotyeOCUser*)user
{
    if(!isTabTop)
        return;
    
    if(code == GotyeStatusCodeOK)
        [self.tableView reloadData];
}

- (void)onGetGroupInfo:(GotyeStatusCode)code group:(GotyeOCGroup*)group
{
    if(!isTabTop)
        return;
    
    if(code == GotyeStatusCodeOK)
        [self.tableView reloadData];
}

- (void)onDownloadMedia:(GotyeStatusCode)code media:(GotyeOCMedia*)media
{
    if(!isTabTop)
        return;
    
    if(code == GotyeStatusCodeOK)
        [self.tableView reloadData];
}

-(void)onEnterRoom:(GotyeStatusCode)code room:(GotyeOCRoom *)room
{
    if(!isTabTop)
        return;
    
    if(code == GotyeStatusCodeOK)
    {
        if(self.navigationController.topViewController == self.tabBarController)
        {
            GotyeChatViewController*viewController = [[GotyeChatViewController alloc] initWithTarget:room];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    else
    {
        NSString *errorStr;
        
        if(code == GotyeStatusCodeRoomIsFull)
            errorStr = @"房间已满";
        else if(code == GotyeStatusCodeRoomNotExist)
            errorStr = @"房间不存在";
        else if(code == GotyeStatusCodeAlreadyInRoom)
            errorStr = @"重复进入房间请求";
        else
            errorStr = [NSString stringWithFormat:@"未知错误(%d)", code];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:errorStr
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [GotyeUIUtil hideHUD];
    enteringRoom = NO;
}


#pragma mark - table delegate & data

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger notifyCount = notifyList.count;
    NSInteger count = sessionList.count + (notifyCount > 0 ? 1 : 0);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MessageCellIdentifier = @"MessageCellIdentifier";
    
    GotyeMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GotyeMessageCell" owner:self options:nil] firstObject];
    }
    
    if(indexPath.row >= sessionList.count)
    {
        cell.labelUsername.text = @"通知";
        cell.imageHead.image = [UIImage imageNamed:@"head_icon_group"];
        cell.labelMessage.text = [NSString stringWithFormat:@"收到%d个通知", (int)notifyList.count];
        
        cell.dataSource = nil;
        cell.delegate = nil;
        
        return cell;
    }
    
    cell.dataSource = self;
    cell.delegate = self;

    GotyeOCChatTarget* target = sessionList[indexPath.row];
    GotyeOCMessage* lastMessage = [GotyeOCAPI getLastMessage:target];
    
    int newCount = [GotyeOCAPI getUnreadMessageCount:target];
    if(newCount > 0)
    {
        cell.buttonNewCount.hidden = NO;
        [cell.buttonNewCount setTitle:[NSString stringWithFormat:@"%d", newCount] forState:UIControlStateNormal];
    }
    else
        cell.buttonNewCount.hidden = YES;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *msgDate = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:lastMessage.date]];
    
    [formatter setDateFormat:@"MM-dd"];
    NSString *curDate = [formatter stringFromDate:[NSDate date]];
    if([curDate compare:[msgDate substringToIndex:5]] == NSOrderedSame)
        cell.labelTime.text = [msgDate substringFromIndex:6];
    else
        cell.labelTime.text = [msgDate substringToIndex:5];
//
    NSString *contentStr;
    NSInteger msgType = lastMessage.type;
    if(msgType == GotyeMessageTypeImage)
        contentStr = @"[图片]";
    else if(msgType == GotyeMessageTypeAudio)
        contentStr = @"[语音]";
    else
        contentStr = lastMessage.text;
    
    switch (target.type) {
        case GotyeChatTargetTypeUser:
        {
            GotyeOCUser* user = [GotyeOCAPI getUserDetail:target forceRequest:NO];
            
            cell.labelUsername.text = user.name;
            cell.labelMessage.text = contentStr;
            
            UIImage *headImage = [GotyeUIUtil getHeadImage:user.icon.path defaultIcon:@"head_icon_user"];
            
            cell.imageHead.image = headImage;
        }
            break;
            
        case GotyeChatTargetTypeRoom:
        {
            GotyeOCRoom* room = [GotyeOCAPI getRoomDetail:target];
            GotyeOCUser* user = [GotyeOCAPI getUserDetail:lastMessage.sender forceRequest:NO];
            
            cell.labelUsername.text = room.name;
            
            cell.labelMessage.text = [NSString stringWithFormat:@"%@:%@", user.name, contentStr];
            cell.imageHead.image = [GotyeUIUtil getHeadImage:room.icon.path defaultIcon:@"head_icon_room"];

        }
            break;
            
        case GotyeChatTargetTypeGroup:
        {
            GotyeOCGroup* group = [GotyeOCAPI getGroupDetail:target forceRequest:NO];
            GotyeOCUser* user = [GotyeOCAPI getUserDetail:lastMessage.sender forceRequest:NO];
            
            cell.labelUsername.text = group.name;
            
            cell.labelMessage.text = [NSString stringWithFormat:@"%@:%@", user.name, contentStr];
            cell.imageHead.image = [GotyeUIUtil getHeadImage:group.icon.path defaultIcon:@"head_icon_room"];
        }
            break;
            
//        case 3:
//        {
//            cell.labelUsername.text = @"群邀请";
//            cell.imageHead.image = [UIImage imageNamed:@"head_icon_group"];
//            cell.labelMessage.text = [NSString stringWithFormat:@"%d位好友邀请你群聊", messageArray.count];
//        }
            break;
            
        default:
            break;
    }
    
    cell.tag = indexPath.row + 1;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row >= sessionList.count)
    {
        GotyeNotifyController *viewController = [[GotyeNotifyController alloc] init];
        [self.tabBarController.navigationController pushViewController:viewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    GotyeOCChatTarget* target = sessionList[indexPath.row];
    
    switch (target.type) {
        case GotyeChatTargetTypeGroup:
        case GotyeChatTargetTypeUser:
        {
            GotyeChatViewController*viewController = [[GotyeChatViewController alloc] initWithTarget:target];
            [self.tabBarController.navigationController pushViewController:viewController animated:YES];
        }
            break;
            
        case GotyeChatTargetTypeRoom:
        {
            GotyeOCRoom* room = [GotyeOCRoom roomWithId:(unsigned)target.id];
            if(!enteringRoom && [GotyeOCAPI enterRoom:room] == GotyeStatusCodeWaitingCallback)
            {
                enteringRoom = YES;
                [GotyeUIUtil showHUD:@"进入聊天室"];
            }
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark * GotyeContextMenuCell data source

- (NSUInteger)numberOfButtonsInContextMenuCell:(GotyeContextMenuCell *)cell
{
    return 1;
}

- (UIButton *)contextMenuCell:(GotyeContextMenuCell *)cell buttonAtIndex:(NSUInteger)index
{
    GotyeMessageCell *msgCell = [cell isKindOfClass:[GotyeMessageCell class]] ? (GotyeMessageCell *)cell : nil;
    switch (index) {
        case 0: return msgCell.buttonDelete;
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
        case 0:
        {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            GotyeOCChatTarget* target = sessionList[indexPath.row];
            [GotyeOCAPI deleteSession:target];
            
            notifyList = [GotyeOCAPI getNotifyList];
            sessionList = [GotyeOCAPI getSessionList];
            
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];

        }
            break;
    }
}

@end

@implementation GotyeMessageCell

@end
