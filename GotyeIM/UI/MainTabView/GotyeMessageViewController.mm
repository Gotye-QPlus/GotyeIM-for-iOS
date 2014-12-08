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

#import "GotyeDelegateManager.h"

#import "GotyeChatViewController.h"

@interface GotyeMessageViewController () <GotyeContextMenuCellDataSource, GotyeContextMenuCellDelegate, GotyeUIDelegate>
{
    BOOL enteringRoom;
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
    
    delegateist->addDelegate(self);
    self.tabBarController.navigationItem.title = @"消息";
    
    enteringRoom = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    delegateist->addDelegate(self);
    self.tabBarController.navigationItem.title = @"消息";
    
    for(GotyeChatTarget target : apiist->getSessionList())
    {
        switch (target.type) {
            case GotyeChatTargetTypeUser:
            {
                GotyeUser user = apiist->getUserDetail(target);
                apiist->downloadMedia(user.icon);
            }
                break;
                
            case GotyeChatTargetTypeRoom:
            {
                GotyeRoom room = apiist->getRoomDetail(target);
                apiist->downloadMedia(room.icon);
            }
                break;
                
            case GotyeChatTargetTypeGroup:
            {
                GotyeGroup group = apiist->getGroupDetail(target);
                apiist->downloadMedia(group.icon);
            }
                break;
        }
    }

    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    delegateist->removeDelegate(self);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gotye UI delegates

-(void)onLogin:(GotyeStatusCode)code user:(gotyeapi::GotyeLoginUser)user
{
    if(code == GotyeStatusCodeOK)
        [self.tableView reloadData];
}

-(void)onReceiveMessage:(gotyeapi::GotyeMessage)message downloadMediaIfNeed:(bool *)downloadMediaIfNeed
{
    [self.tableView reloadData];
    
    *downloadMediaIfNeed = true;
}

-(void)onReceiveNotify:(gotyeapi::GotyeNotify)notify
{
    [self.tableView reloadData];
}

-(void)onGetMessageList:(GotyeStatusCode)code msglist:(std::vector<GotyeMessage>)msglist downloadMediaIfNeed:(bool *)downloadMediaIfNeed
{
    if(code == GotyeStatusCodeOK)
        [self.tableView reloadData];
    
    *downloadMediaIfNeed = true;
}

- (void)onGetUserInfo:(GotyeStatusCode)code user:(gotyeapi::GotyeUser)user
{
    if(code == GotyeStatusCodeOK)
        [self.tableView reloadData];
}

- (void)onGetGroupInfo:(GotyeStatusCode)code group:(gotyeapi::GotyeGroup)group
{
    if(code == GotyeStatusCodeOK)
        [self.tableView reloadData];
}

- (void)onDownloadMedia:(GotyeStatusCode)code media:(gotyeapi::GotyeMedia)media
{
    if(code == GotyeStatusCodeOK)
        [self.tableView reloadData];
}

-(void)onEnterRoom:(GotyeStatusCode)code room:(gotyeapi::GotyeRoom)room
{
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
    NSInteger notifyCount = apiist->getNotifyList().size();
    NSInteger count = apiist->getSessionList().size() + (notifyCount > 0 ? 1 : 0);
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
    
    if(indexPath.row >= apiist->getSessionList().size())
    {
        cell.labelUsername.text = @"通知";
        cell.imageHead.image = [UIImage imageNamed:@"head_icon_group"];
        cell.labelMessage.text = [NSString stringWithFormat:@"收到%d个通知", (int)apiist->getNotifyList().size()];
        
        cell.dataSource = nil;
        cell.delegate = nil;
        
        return cell;
    }
    
    cell.dataSource = self;
    cell.delegate = self;

    GotyeChatTarget target = apiist->getSessionList()[indexPath.row];
    GotyeMessage lastMessage = apiist->getLastMessage(target);
    
    int newCount = apiist->getUnreadMessageCount(target);
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
        contentStr = NSStringUTF8(lastMessage.text);
    
    switch (target.type) {
        case GotyeChatTargetTypeUser:
        {
            GotyeUser user = apiist->getUserDetail(target);
            
            cell.labelUsername.text = NSStringUTF8(user.name);
            cell.labelMessage.text = contentStr;
            
            UIImage *headImage = [GotyeUIUtil getHeadImage:NSStringUTF8(user.icon.path) defaultIcon:@"head_icon_user"];
            
            cell.imageHead.image = headImage;
        }
            break;
            
        case GotyeChatTargetTypeRoom:
        {
            GotyeRoom room = apiist->getRoomDetail(target);
            GotyeUser user = apiist->getUserDetail(lastMessage.sender);
            
            cell.labelUsername.text = NSStringUTF8(room.name);
            
            cell.labelMessage.text = [NSString stringWithFormat:@"%@:%@", NSStringUTF8(user.name), contentStr];
            cell.imageHead.image = [GotyeUIUtil getHeadImage:NSStringUTF8(room.icon.path) defaultIcon:@"head_icon_room"];

        }
            break;
            
        case GotyeChatTargetTypeGroup:
        {
            GotyeGroup group = apiist->getGroupDetail(target);
            GotyeUser user = apiist->getUserDetail(lastMessage.sender);
            
            cell.labelUsername.text = NSStringUTF8(group.name);
            
            cell.labelMessage.text = [NSString stringWithFormat:@"%@:%@", NSStringUTF8(user.name), contentStr];
            cell.imageHead.image = [GotyeUIUtil getHeadImage:NSStringUTF8(group.icon.path) defaultIcon:@"head_icon_room"];
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
    if(indexPath.row >= apiist->getSessionList().size())
    {
        GotyeNotifyController *viewController = [[GotyeNotifyController alloc] init];
        [self.tabBarController.navigationController pushViewController:viewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    GotyeChatTarget target = apiist->getSessionList()[indexPath.row];
    
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
            GotyeRoom room((unsigned)target.id);
            if(!enteringRoom && apiist->enterRoom(room) == GotyeStatusCodeWaitingCallback)
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
            GotyeChatTarget target = apiist->getSessionList()[indexPath.row];
            apiist->deleteSession(target);
            
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];

        }
            break;
    }
}

@end

@implementation GotyeMessageCell

@end
