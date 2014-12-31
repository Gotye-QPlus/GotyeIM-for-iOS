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

#import "GotyeOCAPI.h"
#import "GotyeLoadingView.h"

@interface GotyeGroupSearchController () <GotyeOCDelegate>
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
    
    requestSend = [[NSMutableArray alloc] init];
    
    grouplistlocal = [GotyeOCAPI getLocalGroupList];
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

- (void)searchClick:(UITextField *)sender
{
    searchPageIndex = 0;
    [requestSend removeAllObjects];
    [GotyeOCAPI reqSearchGroup:sender.text pageIndex:searchPageIndex];
}

- (void)applyClick:(UIButton*)sender
{
    GotyeOCGroup* group = grouplistReceive[sender.tag];
    
    if(group.needAuthentication)
    {
        [GotyeOCAPI reqJoinGroup:group applyMessage:@"加我加我"];
        [GotyeUIUtil showHUD:@"申请入群"];
    }
    else
    {
        [GotyeOCAPI joinGroup:group];
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
            [GotyeOCAPI reqSearchGroup:searchBar.textSearch.text pageIndex:searchPageIndex];
        }
    }
}

#pragma mark - Gotye UI delegates

- (void)onSendNotify:(GotyeStatusCode)code notify:(GotyeOCNotify *)notify
{
    if(code == GotyeStatusCodeOK)
    {
        for (int i= 0; i< grouplistReceive.count; i++)
        {
            GotyeOCGroup *group = grouplistReceive[i];
            if(group.id == notify.from.id)
            {
                [requestSend replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
                
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

- (void)onJoinGroup:(GotyeStatusCode)code group:(GotyeOCGroup*)group
{
    if(code == GotyeStatusCodeOK)
    {
        for (int i= 0; i< grouplistReceive.count; i++)
        {
            GotyeOCGroup *groupinlist = grouplistReceive[i];
            if(groupinlist.id == group.id)
            {
                [requestSend replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
                
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

- (void)onSearchGroupList:(GotyeStatusCode)code pageIndex:(unsigned int)pageIndex curPageList:(NSArray *)curPageList allList:(NSArray *)allList
{
    grouplistReceive = allList;
    
    for(int i =0; i<curPageList.count; i++)
        [requestSend addObject:[NSNumber numberWithBool:NO]];
    
    [self.tableView reloadData];
    
    for(GotyeOCGroup* group in curPageList)
        [GotyeOCAPI downloadMedia:group.icon];

    loadingView.hidden = YES;
    haveMoreData = (curPageList.count > 0);
}

-(void)onDownloadMedia:(GotyeStatusCode)code media:(GotyeOCMedia*)media
{
    for (int i=0; i<grouplistReceive.count; i++)
    {
        GotyeOCGroup *groupinlist = grouplistReceive[i];
        if([groupinlist.icon.path isEqualToString:media.path])
        {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return grouplistReceive.count;
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
    
    GotyeOCGroup* group = grouplistReceive[indexPath.row];
    
    cell.imageHead.image = [GotyeUIUtil getHeadImage:group.icon.path defaultIcon:@"head_icon_group"];
    
    cell.labelUsername.text = group.name;
    
    cell.buttonApply.tag = indexPath.row;
    
    for(GotyeOCGroup* mygroup in grouplistlocal)
    {
        if(group.id == mygroup.id)
        {
            cell.labelSend.text = @"已加入";
            cell.labelSend.hidden = NO;
            cell.buttonApply.hidden = YES;
            return cell;
        }
    }
    
    NSNumber* send = requestSend[indexPath.row];
    cell.labelSend.hidden = ![send boolValue];
    cell.buttonApply.hidden = [send boolValue];
    
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
