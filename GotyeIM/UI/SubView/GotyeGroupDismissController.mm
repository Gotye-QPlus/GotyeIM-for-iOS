//
//  GotyeGroupDismissController.m
//  GotyeIM
//
//  Created by Peter on 14-10-23.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeGroupDismissController.h"
#import "GotyeDelegateManager.h"
#import "GotyeUIUtil.h"

#define IconSize            50
#define IconGap             10
#define IconXOffset         15
#define IconNameHeight      10

@interface GotyeGroupDismissController () <GotyeUIDelegate>

@end

@implementation GotyeGroupDismissController

@synthesize headListView, changeButton, dismissButton;

- (id)initWithTarget:(gotyeapi::GotyeGroup)target userList:(std::vector<GotyeUser>)list
{
    self = [super init];
    if (self) {
        groupTarget = target;
        groupUserlist = list;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = Common_Color_Def_Gray;
    
    NSInteger IconRow = (groupUserlist.size() + 4) / 5;
    headListView.frame = CGRectMake(0, headListView.frame.origin.y, ScreenWidth, IconGap + (IconSize + IconGap + IconNameHeight) * IconRow);
    
    for(int i = 0; i<groupUserlist.size(); i++)
    {
        GotyeUser user = groupUserlist[i];
        
        NSInteger row = i / 5;
        NSInteger col = i % 5;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(IconXOffset + (IconSize + IconGap) * col, IconGap + (IconSize + IconGap + IconNameHeight) * row, IconSize, IconSize + IconNameHeight)];
        button.tag = i + 1;
        
        UIImage *headImage= [GotyeUIUtil getHeadImage:NSStringUTF8(user.icon.path) defaultIcon:@"head_icon_user"];
        UIImageView *buttonIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IconSize, IconSize)];
        buttonIcon.image = headImage;
        [button insertSubview:buttonIcon belowSubview:button.imageView];
        
        [button setImage:[UIImage imageNamed:@"corner_icon_select"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(headIconClick:) forControlEvents:UIControlEventTouchUpInside];

        button.imageEdgeInsets = UIEdgeInsetsMake(-5, 40, 40, -5);
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, IconSize, IconSize, IconNameHeight)];
        [titleLabel setFont:[UIFont systemFontOfSize:11]];
        [titleLabel setTextColor:[UIColor lightGrayColor]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        titleLabel.text = NSStringUTF8(user.name);
        [button addSubview:titleLabel];
        
        [headListView addSubview:button];
        
        if(i == 0)
            button.selected = YES;
    }

    CGRect frame = changeButton.frame;
    frame.origin.y = headListView.frame.origin.y + headListView.frame.size.height + 20;
    changeButton.frame = frame;
    
    frame.origin.y += 20 + frame.size.height;
    dismissButton.frame = frame;
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

- (void)headIconClick:(UIButton*)sender
{
    for(UIButton *btn in headListView.subviews)
    {
        if(btn == sender)
            btn.selected = YES;
        else
            btn.selected = NO;
    }
}

- (IBAction)changeownerClick:(id)sender
{
    for(UIButton *btn in headListView.subviews)
    {
        if(btn.isSelected)
        {
            std::string username = groupUserlist[btn.tag - 1].name;
            apiist->changeGroupOwner(groupTarget, username);
        }
    }
}

- (IBAction)dismissClick:(id)sender
{
    apiist->dismissGroup(groupTarget);
}

#pragma mark - Gotye UI delegates

- (void)onChangeGroupOwner:(GotyeStatusCode)code group:(gotyeapi::GotyeGroup)group user:(gotyeapi::GotyeUser)user
{
    if(code == GotyeStatusCodeOK)
    {
        apiist->leaveGroup(groupTarget);
    }
}

- (void)onDismissGroup:(GotyeStatusCode)code group:(gotyeapi::GotyeGroup)group
{
    if(code == GotyeStatusCodeOK)
    {
        [GotyeUIUtil popToRootViewControllerForNavgaion:self.navigationController animated:YES];
        
        apiist->deleteSession(group);
    }
}

- (void)onLeaveGroup:(GotyeStatusCode)code group:(gotyeapi::GotyeGroup)group
{
    if(code == GotyeStatusCodeOK)
    {
        [GotyeUIUtil popToRootViewControllerForNavgaion:self.navigationController animated:YES];
        
        apiist->deleteSession(group);
    }
}

@end
