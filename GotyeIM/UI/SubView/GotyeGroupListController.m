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

#import "GotyeOCAPI.h"

#import "GotyeChatViewController.h"

#import "GotyeGroupSearchController.h"

@interface GotyeGroupListController () <GotyeOCDelegate>

@end

#define TestCount 10

@implementation GotyeGroupListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    
    self.navigationItem.title = @"我的群组";
    
    grouplistReceive = [GotyeOCAPI getLocalGroupList];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"nav_button_search"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(groupSearchClick:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [GotyeOCAPI addListener:self];
    
    [GotyeOCAPI reqGroupList];
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

- (void)groupSearchClick:(UIButton*)sender
{
    GotyeGroupSearchController *viewController = [[GotyeGroupSearchController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Gotye UI delegates

- (void)onGetGroupList:(GotyeStatusCode)code grouplist:(NSArray *)grouplist
{
    grouplistReceive = grouplist;
    
    [self.tableView reloadData];
    
    for(GotyeOCGroup* group in grouplist)
        [GotyeOCAPI downloadMedia:group.icon];
}

-(void)onDownloadMedia:(GotyeStatusCode)code media:(GotyeOCMedia*)media
{
    for (int i=0; i<grouplistReceive.count; i++)
    {
        GotyeOCGroup* group = grouplistReceive[i];
        if([group.icon.path isEqualToString:media.path])
        {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

#pragma mark - table delegate & data

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return grouplistReceive.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ContactCellIdentifier = @"ContactCellIdentifier";
    
    GotyeContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GotyeContactCell" owner:self options:nil] firstObject];
    }
    
    GotyeOCGroup* group = grouplistReceive[indexPath.row];

    cell.imageHead.image = [GotyeUIUtil getHeadImage:group.icon.path defaultIcon:@"head_icon_group"];
    
    cell.labelUsername.text = group.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GotyeOCGroup* group = grouplistReceive[indexPath.row];
    
    GotyeChatViewController*viewController = [[GotyeChatViewController alloc] initWithTarget:group];
    [self.navigationController pushViewController:viewController animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
