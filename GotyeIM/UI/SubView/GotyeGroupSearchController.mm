//
//  GotyeGroupSearchController.m
//  GotyeIM
//
//  Created by Peter on 14-10-29.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeGroupSearchController.h"

#import "GotyeUIUtil.h"
#import "GotyeSearchBar.h"

#import "GotyeDelegateManager.h"
#import "GotyeLoadingView.h"

@interface GotyeGroupSearchController () <GotyeUIDelegate>
{
    GotyeSearchBar *searchBar;
    GotyeLoadingView *loadingView;
}

@end

@implementation GotyeGroupSearchController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    
    searchBar = [[GotyeSearchBar alloc] init];
    [searchBar.textSearch addTarget:self action:@selector(searchClick:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.tableView.tableHeaderView = searchBar;
    
    loadingView = [[GotyeLoadingView alloc] init];
    loadingView.hidden = YES;
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

- (void)searchClick:(UITextField *)sender
{
    searchPageIndex = 0;
    requestSend.clear();
    apiist->reqSearchGroup(STDStringUTF8(sender.text), searchPageIndex);
}

- (void)applyClick:(UIButton*)sender
{
    GotyeGroup group = grouplistReceive[sender.tag];
    
    if(group.needAuthentication)
    {
        apiist->reqJoinGroup(group, "加我加我");
        [GotyeUIUtil showHUD:@"申请入群"];
    }
    else
    {
        apiist->joinGroup(group);
        [GotyeUIUtil showHUD:@"加入群"];
    }
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
            apiist->reqSearchGroup(STDStringUTF8(searchBar.textSearch.text), searchPageIndex);
        }
    }
}

#pragma mark - Gotye UI delegates

- (void)onSendNotify:(GotyeStatusCode)code notify:(gotyeapi::GotyeNotify)notify
{
    if(code == GotyeStatusCodeOK)
    {
        for (int i= 0; i< grouplistReceive.size(); i++) {
            if(grouplistReceive[i].id == notify.from.id)
            {
                requestSend[i] = true;
                
                [self.tableView reloadData];
                break;
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"请求发送失败"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];

    }
    
    [GotyeUIUtil hideHUD];
}

- (void)onJoinGroup:(GotyeStatusCode)code group:(gotyeapi::GotyeGroup)group
{
    if(code == GotyeStatusCodeOK)
    {
        for (int i= 0; i< grouplistReceive.size(); i++) {
            if(grouplistReceive[i].id == group.id)
            {
                requestSend[i] = true;
                
                [self.tableView reloadData];
                break;
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"请求发送失败"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    [GotyeUIUtil hideHUD];
}

- (void)onSearchGroupList:(GotyeStatusCode)code pageIndex:(unsigned int)pageIndex curPageList:(std::vector<GotyeGroup>)curPageList allList:(std::vector<GotyeGroup>)allList
{
    grouplistReceive = allList;
    
    [self.tableView reloadData];
    
    for(GotyeGroup group: curPageList)
    {
        apiist->downloadMedia(group.icon);
        requestSend.push_back(false);
    }
    
    loadingView.hidden = YES;
    haveMoreData = (curPageList.size() > 0);
}

-(void)onDownloadMedia:(GotyeStatusCode)code media:(gotyeapi::GotyeMedia)media
{
    for (int i=0; i<grouplistReceive.size(); i++)
    {
        if(grouplistReceive[i].icon.path.compare(media.path) == 0)
        {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return grouplistReceive.size();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *GroupSearchCellIdentifier = @"GroupSearchCellIdentifier";
    
    GotyeGroupSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupSearchCellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GotyeGroupSearchCell" owner:self options:nil] firstObject];
        
        [cell.buttonApply addTarget:self action:@selector(applyClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    GotyeGroup group = grouplistReceive[indexPath.row];
    
    cell.imageHead.image = [GotyeUIUtil getHeadImage:NSStringUTF8(group.icon.path) defaultIcon:@"head_icon_group"];
    
    cell.labelUsername.text = NSStringUTF8(group.name);
    
    cell.buttonApply.tag = indexPath.row;
    
    for(GotyeGroup mygroup:apiist->getLocalGroupList())
    {
        if(group.id == mygroup.id)
        {
            cell.labelSend.text = @"已加入";
            cell.labelSend.hidden = NO;
            cell.buttonApply.hidden = YES;
            return cell;
        }
    }
    
    cell.labelSend.hidden = !requestSend[indexPath.row];
    cell.buttonApply.hidden = requestSend[indexPath.row];
    
    if(group.needAuthentication)
    {
        [cell.buttonApply setTitle:@"申请" forState:UIControlStateNormal];
        [cell.buttonApply setBackgroundImage:[UIImage imageNamed:@"button_red"] forState:UIControlStateNormal];
        cell.labelSend.text = @"已申请";
    }
    else
    {
        [cell.buttonApply setTitle:@"加入" forState:UIControlStateNormal];
        [cell.buttonApply setBackgroundImage:[UIImage imageNamed:@"button_common"] forState:UIControlStateNormal];
        cell.labelSend.text = @"已加入";
    }
    
    return cell;
}


@end

@implementation GotyeGroupSearchCell

@end
