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

#import "GotyeDelegateManager.h"

#import "GotyeChatViewController.h"
#import "GotyeLoadingView.h"

@interface GotyeChatRoomListController () <GotyeUIDelegate>
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
    
    roomlistReceive = &apiist->getLocalRoomList();
    
    searchPageIndex = 0;
    apiist->reqRoomList(0);
    
    loadingView = [[GotyeLoadingView alloc] init];
    loadingView.hidden = YES;
    
    enteringRoom = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    delegateist->addDelegate(self);
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
            apiist->reqRoomList(searchPageIndex);
        }
    }
}

#pragma mark - Gotye UI delegates

-(void)onGetRoomList:(GotyeStatusCode)code pageIndex:(unsigned int)pageIndex curPageRoomList:(std::vector<GotyeRoom>)curPageRoomList allRoomList:(std::vector<GotyeRoom>)allRoomList
{
    [self.tableView reloadData];
    
    for(GotyeRoom room: curPageRoomList)
        apiist->downloadMedia(room.icon);
    
    loadingView.hidden = YES;
    haveMoreData = (curPageRoomList.size() > 0);
}

-(void)onDownloadMedia:(GotyeStatusCode)code media:(gotyeapi::GotyeMedia)media
{
    for (int i=0; i<roomlistReceive->size(); i++)
    {
        if((*roomlistReceive)[i].icon.path.compare(media.path) == 0)
        {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

-(void)onEnterRoom:(GotyeStatusCode)code room:(gotyeapi::GotyeRoom)room
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
    return roomlistReceive->size();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ContactCellIdentifier = @"ContactCellIdentifier";
    
    GotyeContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GotyeContactCell" owner:self options:nil] firstObject];
    }
    
    GotyeRoom room = (*roomlistReceive)[indexPath.row];
    
    cell.imageHead.image = [GotyeUIUtil getHeadImage:NSStringUTF8(room.icon.path) defaultIcon:@"head_icon_room"];
    
    cell.labelUsername.text = NSStringUTF8(room.name);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    
    GotyeRoom room = (*roomlistReceive)[indexPath.row];
    
    if(!enteringRoom && apiist->enterRoom(room) == GotyeStatusCodeWaitingCallback)
    {
        enteringRoom = YES;
        [GotyeUIUtil showHUD:@"进入聊天室"];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
