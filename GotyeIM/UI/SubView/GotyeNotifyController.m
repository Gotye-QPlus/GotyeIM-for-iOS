//
//  GotyeNotifyController.m
//  GotyeIM
//
//  Created by Peter on 14-9-29.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeNotifyController.h"

#import "GotyeUIUtil.h"
#import "GotyeOCAPI.h"

@interface GotyeNotifyController () <GotyeContextMenuCellDataSource, GotyeContextMenuCellDelegate, GotyeOCDelegate>

@end

@implementation GotyeNotifyController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    
    self.navigationItem.title = @"通知";
    
    notifylist = [GotyeOCAPI getNotifyList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [GotyeOCAPI addListener:self];
    
    [GotyeOCAPI clearNotifyUnreadStatus];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [GotyeOCAPI removeListener:self];
}

- (void)confirmClick:(UIButton*)sender
{
    GotyeOCNotify* notify = notifylist[sender.tag];
    
    if(notify.type == GotyeNotifyTypeGroupInvite || (notify.type == GotyeNotifyTypeJoinGroupReply && notify.agree))
    {
        GotyeOCGroup* group = [GotyeOCGroup groupWithId:notify.from.id];
        [GotyeOCAPI joinGroup:group];
        processingIndex = sender.tag;
        
        [GotyeUIUtil showHUD:@"加入群"];
    }
    else if(notify.type == GotyeNotifyTypeJoinGroupRequest)
    {
        [GotyeOCAPI replyJoinGroup:notify respMessage:@"同意！" agree:YES];
        
        processingIndex = sender.tag;
        [GotyeUIUtil showHUD:@"正在回复"];
    }
}

#pragma mark - Gotye UI delegates

- (void)onReceiveNotify:(GotyeOCNotify*)notify
{
    [self.tableView reloadData];
}

- (void)onSendNotify:(GotyeStatusCode)code notify:(GotyeOCNotify*)notify
{
    if(code == GotyeStatusCodeOK)
    {
        [self deleteNotify:processingIndex];
        processingIndex = -1;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"请求回复失败"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [GotyeUIUtil hideHUD];
}

- (void)onJoinGroup:(GotyeStatusCode)code group:(GotyeOCGroup*)group
{
    if(code == GotyeStatusCodeOK || code == GotyeStatusCodeRepeatOper)
    {
        [self deleteNotify:processingIndex];
        processingIndex = -1;
    }
    
    [GotyeUIUtil hideHUD];
}

- (void)deleteNotify:(NSInteger)index
{
    if(index < 0 || index >= notifylist.count)
        return;
    
    GotyeOCNotify* notify = notifylist[index];
    [GotyeOCAPI deleteNotify:notify];
    
    notifylist = [GotyeOCAPI getNotifyList];
            
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]withRowAnimation:UITableViewRowAnimationMiddle];
    [self.tableView reloadData];
    
    if(notifylist.count == 0)
        [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - table delegate & data

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return notifylist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSUInteger row = [indexPath row];
    
    static NSString *GotyeNotifyCellIdentifier = @"GotyeNotifyCellIdentifier";
    
    GotyeNotifyCell *cell = [tableView dequeueReusableCellWithIdentifier:GotyeNotifyCellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GotyeNotifyCell" owner:self options:nil] firstObject];
        
        cell.dataSource = self;
        cell.delegate = self;
        
        [cell.buttonConfirm addTarget:self action:@selector(confirmClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    GotyeOCNotify* notify = notifylist[indexPath.row];
    
    NSString *groupName = notify.from.name;
    NSString *senderName = notify.sender.name;

    cell.buttonConfirm.tag = indexPath.row;

    cell.labelUsername.text = senderName;
    
    [cell.buttonReject setTitle:@"拒绝" forState:UIControlStateNormal];
    switch (notify.type) {
        case GotyeNotifyTypeGroupInvite:
            cell.labelMessage.text = [NSString stringWithFormat:@"邀请你加入%@", groupName];
            cell.buttonConfirm.hidden = NO;
            [cell.buttonConfirm setTitle:@"同意" forState:UIControlStateNormal];
            break;
            
        case GotyeNotifyTypeJoinGroupRequest:
            cell.labelMessage.text = [NSString stringWithFormat:@"申请加入%@", groupName];
            cell.buttonConfirm.hidden = NO;
            [cell.buttonConfirm setTitle:@"同意" forState:UIControlStateNormal];
            break;
            
        case GotyeNotifyTypeJoinGroupReply:
            cell.labelMessage.text = [NSString stringWithFormat:@"%@了你加入%@的申请", notify.agree?@"同意":@"拒绝", groupName];
            cell.buttonConfirm.hidden = !notify.agree;
            [cell.buttonConfirm setTitle:@"加入" forState:UIControlStateNormal];
            if(!notify.agree)
                [cell.buttonReject setTitle:@"删除" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    GotyeOCUser* sender = [GotyeOCAPI getUserDetail:notify.sender forceRequest:NO];
    cell.imageHead.image = [GotyeUIUtil getHeadImage:sender.icon.path defaultIcon:@"head_icon_user"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark * GotyeContextMenuCell data source

- (NSUInteger)numberOfButtonsInContextMenuCell:(GotyeContextMenuCell *)cell
{
    return 1;
}

- (UIButton *)contextMenuCell:(GotyeContextMenuCell *)cell buttonAtIndex:(NSUInteger)index
{
    GotyeNotifyCell *msgCell = [cell isKindOfClass:[GotyeNotifyCell class]] ? (GotyeNotifyCell *)cell : nil;
    switch (index) {
        case 0: return msgCell.buttonReject;
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
            GotyeOCNotify* notify = notifylist[indexPath.row];
            if(notify.type == GotyeNotifyTypeJoinGroupRequest)
            {
                [GotyeOCAPI replyJoinGroup:notify respMessage:@"不要！" agree:NO];
                
                processingIndex = indexPath.row;
                [GotyeUIUtil showHUD:@"正在回复"];
                break;
            }
            
            [self deleteNotify:indexPath.row];
        } break;
    }
}

@end

@implementation GotyeNotifyCell

@end
