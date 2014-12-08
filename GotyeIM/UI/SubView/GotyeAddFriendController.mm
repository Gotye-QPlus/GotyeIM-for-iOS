//
//  GotyeAddFriendController.m
//  GotyeIM
//
//  Created by Peter on 14-9-29.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeAddFriendController.h"

#import "GotyeUIUtil.h"
#import "GotyeSearchBar.h"

#import "GotyeDelegateManager.h"
#import "GotyeLoadingView.h"

@interface GotyeAddFriendController () <GotyeUIDelegate>
{
    GotyeSearchBar *searchBar;
    GotyeLoadingView *loadingView;
}

@end

@implementation GotyeAddFriendController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.rowHeight = 60;
    
    self.navigationItem.title = @"添加好友";
    
    searchBar = [[GotyeSearchBar alloc] init];
    [searchBar.textSearch addTarget:self action:@selector(searchClick:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.tableView.tableHeaderView = searchBar;
    
    loadingView = [[GotyeLoadingView alloc] init];
    loadingView.hidden = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"nav_button_add"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(addInputClick:)];
}

-(void)loadView
{
    [super loadView];
}

- (void)viewWillAppear:(BOOL)animated
{
    delegateist->addDelegate(self);
}

- (void)viewWillDisappear:(BOOL)animated
{
    delegateist->removeDelegate(self);
}

- (void)searchClick:(UITextField *)sender
{
    searchPageIndex = 0;
    apiist->reqSearchUserList(searchPageIndex, STDStringUTF8(sender.text));
    
    [GotyeUIUtil showHUD:@"搜索中"];
}

- (void)addClick:(UIButton*)sender
{
    GotyeUser user = userlistReceive[sender.tag];
    
    apiist->reqAddFriend(user);
    
    [GotyeUIUtil showHUD:@"添加好友"];
}

- (void)addInputClick:(UIButton*)sender
{
    GotyeAddFriendInputController *viewController = [[GotyeAddFriendInputController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
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
            apiist->reqSearchUserList(searchPageIndex, STDStringUTF8(searchBar.textSearch.text));
        }
    }
}

#pragma mark - Gotye UI delegates

- (void)onSearchUserList:(GotyeStatusCode)code pageIndex:(unsigned int)pageIndex curPageList:(std::vector<GotyeUser>)curPageList allList:(std::vector<GotyeUser>)allList
{
    if(GotyeStatusCodeOK != code)
        return;
    
    userlistReceive = allList;
    
    [self.tableView reloadData];
    
    for(GotyeUser user: curPageList)
        apiist->downloadMedia(user.icon);
    
    loadingView.hidden = YES;
    haveMoreData = (curPageList.size() > 0);
    
    [GotyeUIUtil hideHUD];
}

-(void)onDownloadMedia:(GotyeStatusCode)code media:(gotyeapi::GotyeMedia)media
{
    for (int i=0; i<userlistReceive.size(); i++)
    {
        if(userlistReceive[i].icon.path.compare(media.path) == 0)
        {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

- (void)onAddFriend:(GotyeStatusCode)code user:(gotyeapi::GotyeUser)user
{
    NSString *msg;
    if(code == GotyeStatusCodeOK)
        msg = @"添加成功";
    else if(code == GotyeStatusCodeUserNotFound)
        msg = @"用户不存在";
    else
        msg = [NSString stringWithFormat:@"未知错误(%d)", code];

    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
    [GotyeUIUtil hideHUD];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - table delegate & data

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return userlistReceive.size();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AddFriendCellIdentifier = @"AddFriendCellIdentifier";
    
    GotyeAddFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:AddFriendCellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GotyeAddFriendCell" owner:self options:nil] firstObject];
        
        [cell.buttonAdd addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    GotyeUser user = userlistReceive[indexPath.row];
    
    cell.labelUsername.text = NSStringUTF8(user.name);
    cell.labelID.text = NSStringUTF8(user.nickname);
    cell.imageHead.image = [GotyeUIUtil getHeadImage:NSStringUTF8(user.icon.path) defaultIcon:@"head_icon_user"];
    
    cell.buttonAdd.tag = indexPath.row;

    return cell;
}

@end

@implementation GotyeAddFriendCell

@end

#pragma mark - nick name input view

@implementation GotyeAddFriendInputController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = Common_Color_Def_Gray;
    
    UIView *whiteBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 55)];
    whiteBack.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteBack];
    
    textInput = [[UITextField alloc] initWithFrame:CGRectMake(18, 10, ScreenWidth - 36, 35)];
    textInput.borderStyle = UITextBorderStyleNone;
    textInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    textInput.textColor = [UIColor blackColor];
    textInput.font = [UIFont systemFontOfSize:15];
    textInput.returnKeyType = UIReturnKeyDone;
    
    [textInput addTarget:self action:@selector(textInputEnd:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.view addSubview:textInput];
    
    [textInput becomeFirstResponder];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(quitClick:)];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick:)];
    
    self.navigationItem.title = @"加指定用户";
}

- (void)quitClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveClick:(id)sender
{
    if(apiist->reqAddFriend(STDStringUTF8(textInput.text)) == GotyeStatusCodeWaitingCallback)
        [GotyeUIUtil showHUD:@"添加好友"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textInputEnd:(id)sender
{
    [sender resignFirstResponder];
}

@end
