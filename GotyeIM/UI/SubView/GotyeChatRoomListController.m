//
//  GotyeChatRoomController.m
//  GotyeIM
//
//  Created by Peter on 14-10-9.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeChatRoomListController.h"

#import "GotyeContactViewController.h"
#import "GotyeUIUtil.h"

#import "GotyeOCAPI.h"

#import "GotyeChatViewController.h"
#import "GotyeLoadingView.h"

@interface GotyeChatRoomListController () <GotyeOCDelegate>
{
    GotyeLoadingView *loadingView;
    
    BOOL enteringRoom;
}

@end

@implementation GotyeChatRoomListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    
    self.navigationItem.title = @"聊天室";
    
    roomlistReceive = [GotyeOCAPI getLocalRoomList];
    
    searchPageIndex = 0;
    [GotyeOCAPI reqRoomList:0];
    
    loadingView = [[GotyeLoadingView alloc] init];
    loadingView.hidden = YES;
    
    enteringRoom = NO;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(loadingView.hidden && scrollView.contentSize.height > scrollView.frame.size.height && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height +20)
    {
        loadingView.frame = CGRectMake(0, scrollView.contentSize.height, 320, 40);
        [scrollView insertSubview:loadingView atIndex:0];
        loadingView.hidden = NO;
        [loadingView showLoading:haveMoreData];
        
        if(haveMoreData)
        {
            searchPageIndex ++;
            [GotyeOCAPI reqRoomList:searchPageIndex];
        }
    }
}

#pragma mark - Gotye UI delegates

-(void)onGetRoomList:(GotyeStatusCode)code pageIndex:(unsigned int)pageIndex curPageRoomList:(NSArray *)curPageRoomList allRoomList:(NSArray *)allRoomList
{
    for(GotyeOCRoom* room in curPageRoomList)
        [GotyeOCAPI downloadMedia:room.icon];
    
    roomlistReceive = allRoomList;
    
    loadingView.hidden = YES;
    haveMoreData = (curPageRoomList.count > 0);
    
    [self.tableView reloadData];
}

-(void)onDownloadMedia:(GotyeStatusCode)code media:(GotyeOCMedia*)media
{
    for (int i=0; i<roomlistReceive.count; i++)
    {
        GotyeOCRoom *room = roomlistReceive[i];
        if([room.icon.path isEqualToString:media.path])
        {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

-(void)onEnterRoom:(GotyeStatusCode)code room:(GotyeOCRoom*)room
{
    if(code == GotyeStatusCodeOK)
    {
        if(self.navigationController.topViewController == self)
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
    return roomlistReceive.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ContactCellIdentifier = @"ContactCellIdentifier";
    
    GotyeContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GotyeContactCell" owner:self options:nil] firstObject];
    }
    
    GotyeOCRoom* room = roomlistReceive[indexPath.row];
    
    cell.imageHead.image = [GotyeUIUtil getHeadImage:room.icon.path defaultIcon:@"head_icon_room"];
    
    cell.labelUsername.text = room.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    
    GotyeOCRoom* room = roomlistReceive[indexPath.row];
    
    if(!enteringRoom && [GotyeOCAPI enterRoom:room] == GotyeStatusCodeWaitingCallback)
    {
        enteringRoom = YES;
        [GotyeUIUtil showHUD:@"进入聊天室"];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
