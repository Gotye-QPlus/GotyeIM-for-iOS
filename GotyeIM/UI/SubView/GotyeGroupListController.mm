//
//  GotyeGroupListController.m
//  GotyeIM
//
//  Created by Peter on 14-10-9.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeGroupListController.h"

#import "GotyeContactViewController.h"
#import "GotyeUIUtil.h"

#import "GotyeDelegateManager.h"

#import "GotyeChatViewController.h"

#import "GotyeGroupSearchController.h"

@interface GotyeGroupListController () <GotyeUIDelegate>

@end

#define TestCount 10

@implementation GotyeGroupListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    
    self.navigationItem.title = @"我的群组";
    
    grouplistReceive = &apiist->getLocalGroupList();
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"nav_button_search"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(groupSearchClick:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    delegateist->addDelegate(self);
    
    apiist->reqGroupList();
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

- (void)groupSearchClick:(UIButton*)sender
{
    GotyeGroupSearchController *viewController = [[GotyeGroupSearchController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Gotye UI delegates

- (void)onGetGroupList:(GotyeStatusCode)code grouplist:(std::vector<GotyeGroup>)grouplist
{
    [self.tableView reloadData];
    
    for(GotyeGroup group: grouplist)
        apiist->downloadMedia(group.icon);
}

-(void)onDownloadMedia:(GotyeStatusCode)code media:(gotyeapi::GotyeMedia)media
{
    for (int i=0; i<grouplistReceive->size(); i++)
    {
        if((*grouplistReceive)[i].icon.path.compare(media.path) == 0)
        {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

#pragma mark - table delegate & data

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return grouplistReceive->size();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ContactCellIdentifier = @"ContactCellIdentifier";
    
    GotyeContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GotyeContactCell" owner:self options:nil] firstObject];
    }
    
    GotyeGroup group = (*grouplistReceive)[indexPath.row];

    cell.imageHead.image = [GotyeUIUtil getHeadImage:NSStringUTF8(group.icon.path) defaultIcon:@"head_icon_group"];
    
    cell.labelUsername.text = NSStringUTF8(group.name);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GotyeGroup group = (*grouplistReceive)[indexPath.row];
    
    GotyeChatViewController*viewController = [[GotyeChatViewController alloc] initWithTarget:group];
    [self.navigationController pushViewController:viewController animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
