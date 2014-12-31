//
//  GotyeGroupSettingController.m
//  GotyeIM
//
//  Created by Peter on 14-10-20.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeGroupSettingController.h"
#import "GotyeOCAPI.h"
#import "GotyeSettingManager.h"
#import "GotyeUIUtil.h"
#import "GotyeGroupSelUserController.h"
#import "GotyeGroupDismissController.h"
#import "GotyeUserInfoController.h"

#define IconSize            50
#define IconGap             10
#define IconXOffset         15
#define IconNameHeight      10

#define ActionButtonHeight  44

#define HeadMaxSize 200

@interface GotyeGroupSettingController () <GotyeOCDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation GotyeGroupSettingController

- (id)initWithTarget:(GotyeOCGroup*)target
{
    self = [self init];
    if(self)
    {
        groupTarget = target;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    headListView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    
    [GotyeOCAPI getGroupDetail:groupTarget forceRequest:YES];
    
    groupSetting = [[GotyeSettingManager defaultManager] getSetting:groupTarget.type targetID:[NSString stringWithFormat:@"%lld", groupTarget.id]];
    
    [self resetAllIcons];
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

- (void)headClick:(UIButton*)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从手机相册选择", nil];
    
    actionSheet.tag = 1000;
    [actionSheet showInView:self.view.window];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1000 && buttonIndex!=[actionSheet cancelButtonIndex])
    {
        if(buttonIndex == 1)
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            
            imagePicker.delegate = self;
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            imagePicker.allowsEditing = YES;
            
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        else if(buttonIndex == 0)
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                
                imagePicker.delegate = self;
                
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
                imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                imagePicker.allowsEditing = YES;
                
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
        }
    }
    else if(buttonIndex!=[actionSheet cancelButtonIndex])
    {
        if(buttonIndex == 0)
        {
            [GotyeOCAPI leaveGroup:groupTarget];
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if(image.size.width > HeadMaxSize)
        image = [GotyeUIUtil scaleImage:image toSize:CGSizeMake(HeadMaxSize, HeadMaxSize)];
    
    NSData *jpgTempImage = [GotyeUIUtil ConpressImageToJPEGData:image maxSize:ImageFileSizeMax];
    NSString *tempPath = [[GotyeSettingManager defaultManager].settingDirectory stringByAppendingString:@"temp.jpg"];
    [jpgTempImage writeToFile:tempPath atomically:YES];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //GotyeOCUser* loginUser = [GotyeOCAPI getLoginUser];
    [GotyeOCAPI reqModifyGroupInfo:groupTarget imagePath:tempPath];
}

- (void)userClick:(UIButton*)sender
{
    long long groupID = [[GotyeOCAPI getLoginUser].name isEqualToString:groupTarget.ownerAccount] ? groupTarget.id : 0;
    GotyeUserInfoController *viewController = [[GotyeUserInfoController alloc] initWithTarget:groupUserlist[sender.tag-1] groupID:groupID];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)inviteUserClick:(id)sender
{
    GotyeGroupSelUserController *viewController = [[GotyeGroupSelUserController alloc] initWithGroup:groupTarget];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)leaveClick:(id)sender
{
    GotyeOCUser* loginuser = [GotyeOCAPI getLoginUser];
    if([loginuser.name isEqualToString:groupTarget.ownerAccount] && groupUserlist.count > 1)
    {
        NSMutableArray* groupUserlistCopy = [NSMutableArray arrayWithArray:groupUserlist];
        
        for(int i = 0; i<groupUserlistCopy.count; i++)
        {
            GotyeOCUser* user = groupUserlistCopy[i];
            if([user.name isEqualToString:loginuser.name])
            {
                [groupUserlistCopy removeObjectAtIndex:i];
            }
        }
        GotyeGroupDismissController *viewController = [[GotyeGroupDismissController alloc] initWithTarget:groupTarget userList:groupUserlistCopy];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else
    {
        NSString *exitButtonTitle = @"确定退出";
        if([loginuser.name isEqualToString:groupTarget.ownerAccount])
            exitButtonTitle = @"确定解散";
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:exitButtonTitle, nil];
        
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        
        [actionSheet showInView:self.view];
    }
}

-(void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for(UIView *subView in actionSheet.subviews)
    {
        if([subView isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton*)subView;
            [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

- (void)resetHeadIcon:(NSInteger)headIconIndex
{
    UIButton *button = (UIButton*)[headListView viewWithTag:headIconIndex + 1];
    GotyeOCUser* user = groupUserlist[headIconIndex];
    UIImage *headImage= [GotyeUIUtil getHeadImage:user.icon.path defaultIcon:@"head_icon_user"];
    
    UIImageView *buttonIcon = (UIImageView *)button.subviews[button.subviews.count - 1];
    buttonIcon.image = headImage;
}

- (void)swichChanged:(UISwitch*)sw
{
    UITableViewCell *cell = (UITableViewCell *)sw.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if(indexPath.section == GroupSettingSectionNickname)
    {
        groupSetting[Setting_key_NickName] = [NSNumber numberWithBool:sw.isOn];
        [self swichNickName];
    }
//    else if(indexPath.section == GroupSettingSectionMessage && indexPath.row == 0)
//        groupSetting[Setting_key_Stick] = [NSNumber numberWithBool:sw.isOn];
//    else if(indexPath.section == GroupSettingSectionMessage && indexPath.row == 1)
//        groupSetting[Setting_key_NoDisturb] = [NSNumber numberWithBool:sw.isOn];
    
    [[GotyeSettingManager defaultManager] saveSetting:groupSetting targetType:groupTarget.type targetID:[NSString stringWithFormat:@"%lld", groupTarget.id]];
}

- (void)swichNickName
{
    BOOL showNickName = [groupSetting[Setting_key_NickName] boolValue];
    NSInteger IconRow = (groupUserlist.count + 1 + 4) / 5;
    for(int i = 0; i<groupUserlist.count; i++)
    {
        GotyeOCUser* user = groupUserlist[i];
        UIButton *button = (UIButton*)[headListView viewWithTag:i + 1];
        
        NSInteger row = i / 5;
        NSInteger col = i % 5;
        
        button.frame = CGRectMake(IconXOffset + (IconSize + IconGap) * col, IconGap + (IconSize + IconGap + (showNickName ? IconNameHeight : 0)) * row, IconSize, IconSize + IconNameHeight);
        
        [button setTitle:(showNickName ? user.name: @"") forState:UIControlStateNormal];
    }
    headListView.frame = CGRectMake(0, 0, 320, IconGap + (IconSize + IconGap + (showNickName ? IconNameHeight : 0)) * IconRow);
    
    [self.tableView reloadData];
}

- (void)resetAllIcons
{
    for (UIView *view in [headListView subviews]) {
        [view removeFromSuperview];
    }
    
    BOOL showNickName = [groupSetting[Setting_key_NickName] boolValue];
    NSInteger IconRow = (groupUserlist.count + 1 + 4) / 5;
    headListView.frame = CGRectMake(0, 0, 320, IconGap + (IconSize + IconGap + (showNickName ? IconNameHeight : 0)) * IconRow);
    
    for(int i = 0; i<groupUserlist.count; i++)
    {
        GotyeOCUser* user = groupUserlist[i];
        
        NSInteger row = i / 5;
        NSInteger col = i % 5;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(IconXOffset + (IconSize + IconGap) * col, IconGap + (IconSize + IconGap + (showNickName ? IconNameHeight : 0)) * row, IconSize, IconSize + IconNameHeight)];
        button.tag = i + 1;
        [button addTarget:self action:@selector(userClick:) forControlEvents:UIControlEventTouchUpInside];
        
        button.titleEdgeInsets = UIEdgeInsetsMake(IconSize, 0, 0, 0);
        [button.titleLabel setFont:[UIFont systemFontOfSize:11]];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        NSString *displayName = [groupSetting[Setting_key_NickName] boolValue] ? user.name: @"";
        [button setTitle:displayName forState:UIControlStateNormal];
        
        UIImageView *buttonIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IconSize, IconSize)];
        [button addSubview:buttonIcon];

        [headListView addSubview:button];
        
        [GotyeOCAPI downloadMedia:user.icon];
        
        [self resetHeadIcon:i];
    }
    
    NSInteger row = groupUserlist.count / 5;
    NSInteger col = groupUserlist.count % 5;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(IconXOffset + (IconSize + IconGap) * col, IconGap + (IconSize + IconGap) * row, IconSize, IconSize)];
    button.tag = groupUserlist.count + 1;
    [button setBackgroundImage:[UIImage imageNamed:@"head_icon_add"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inviteUserClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [headListView addSubview:button];
}

#pragma mark - Gotye UI delegates

- (void)onGetGroupDetail:(GotyeStatusCode)code group:(GotyeOCGroup*)group
{
    if(code == GotyeStatusCodeOK)
    {
        if(group.id == groupTarget.id)
        {
            groupTarget = group;
            [GotyeOCAPI downloadMedia:group.icon];
            [GotyeOCAPI reqGroupMemberList:groupTarget pageIndex:0];
        }
    }
}

- (void)onGetGroupMemberList:(GotyeStatusCode)code group:(GotyeOCGroup*)group pageIndex:(unsigned int)pageIndex curPageMemberList:(NSArray*)curPageMemberList allMemberList:(NSArray*)allMemberList
{
    groupUserlist = allMemberList;
    
    [self resetAllIcons];

    [self.tableView reloadData];
}

- (void)onDownloadMedia:(GotyeStatusCode)code media:(GotyeOCMedia*)media
{
    if(code == GotyeStatusCodeOK)
    {
        for(int i = 0; i<groupUserlist.count; i++)
        {
            GotyeOCUser* user = groupUserlist[i];
            if([user.icon.path isEqualToString:media.path])
            {
               [self resetHeadIcon:i];
                break;
            }
        }
    }
}

- (void)onLeaveGroup:(GotyeStatusCode)code group:(GotyeOCGroup*)group
{
    if(group.id == groupTarget.id && code == GotyeStatusCodeOK)
    {
        [GotyeUIUtil popToRootViewControllerForNavgaion:self.navigationController animated:YES];
    }
}

- (void)onModifyGroupInfo:(GotyeStatusCode)code group:(GotyeOCGroup*)group
{
    if(code == GotyeStatusCodeOK)
    {
        groupTarget = group;
        
        [self.tableView reloadData];
        
        UIViewController *viewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
        viewController.navigationItem.title = group.name;
    }
}

- (void)onUserJoinGroup:(GotyeOCGroup*)group user:(GotyeOCUser*)user
{
    [GotyeOCAPI reqGroupMemberList:groupTarget pageIndex:0];
}

- (void)onUserLeaveGroup:(GotyeOCGroup*)group user:(GotyeOCUser*)user
{
    [GotyeOCAPI reqGroupMemberList:groupTarget pageIndex:0];
}

- (void)onUserKickedFromGroup:(GotyeOCGroup*)group kicked:(GotyeOCUser*)kicked actor:(GotyeOCUser*)actor
{
    [GotyeOCAPI reqGroupMemberList:groupTarget pageIndex:0];
}

- (void)onUserDismissGroup:(GotyeOCGroup*)group user:(GotyeOCUser*)user
{
    [GotyeOCAPI deleteSession:group];
    [GotyeUIUtil popToRootViewControllerForNavgaion:self.navigationController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return GroupSettingSectionMaxCount;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 0;
    
    return 21;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == GroupSettingSectionMember)
        return headListView.frame.size.height;
    
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(section == GroupSettingSectionMessage)
//        return 2;
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SettingCellIdentifier = @"SettingCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingCellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    NSString *titleStr;
    
    switch (indexPath.section) {
        case GroupSettingSectionInfo:
        {
            titleStr = groupTarget.name;
            
            UIButton *groupIcon = [[UIButton alloc] initWithFrame:CGRectMake(300 - IconSize, 5, IconSize, IconSize)];
            UIImage  *iconImage = [GotyeUIUtil getHeadImage:groupTarget.icon.path defaultIcon:@"head_icon_group"];
            
            [groupIcon setBackgroundImage:iconImage forState:UIControlStateNormal];
            if([[GotyeOCAPI getLoginUser].name isEqualToString:groupTarget.ownerAccount])
                [groupIcon addTarget:self action:@selector(headClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:groupIcon];
        }
            break;
            
        case GroupSettingSectionMember:
            [cell.contentView addSubview:headListView];
            break;
            
        case GroupSettingSectionOwner:
        {
            titleStr = @"群主";
            
            UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(300 - IconSize - 210, 5, 200, IconSize)];
            bubbleText.backgroundColor = [UIColor clearColor];
            bubbleText.textColor = [UIColor lightGrayColor];
            bubbleText.font = [UIFont systemFontOfSize:15];
            bubbleText.textAlignment = NSTextAlignmentRight;
            bubbleText.text = groupTarget.ownerAccount;
            
            [cell.contentView addSubview:bubbleText];
            
            GotyeOCUser* owner = [GotyeOCAPI getUserDetail:[GotyeOCUser userWithName:groupTarget.ownerAccount] forceRequest:NO];
            
            UIImageView *ownerHead = [[UIImageView alloc] initWithFrame:CGRectMake(300 - IconSize, 5, IconSize, IconSize)];
            ownerHead.image = [GotyeUIUtil getHeadImage:owner.icon.path defaultIcon:@"head_icon_user"];
            
            [cell.contentView addSubview:ownerHead];
        }
            break;
            
        case GroupSettingSectionNickname:
        {
            titleStr = @"显示用户昵称";
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(300 - 49, 10, 49, 31)];
            
            switchView.onTintColor = Common_Color_Def_Gray;
            switchView.thumbTintColor = Common_Color_Def_Nav;
            
            switchView.on = [groupSetting[Setting_key_NickName] boolValue];
            [switchView addTarget:self action:@selector(swichChanged:) forControlEvents:UIControlEventValueChanged];
            
            [cell addSubview:switchView];
        }

            break;
            
//        case GroupSettingSectionMessage:
//        {
//            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(300 - 49, 10, 49, 31)];
//            
//            switchView.onTintColor = Common_Color_Def_Gray;
//            switchView.thumbTintColor = Common_Color_Def_Nav;
//            if (indexPath.row == 0)
//            {
//                titleStr = @"聊天置顶";
//                switchView.on = [groupSetting[Setting_key_Stick] boolValue];
//            }
//            else
//            {
//                titleStr = @"群消息免打扰";
//                switchView.on = [groupSetting[Setting_key_NoDisturb] boolValue];
//            }
//            [switchView addTarget:self action:@selector(swichChanged:) forControlEvents:UIControlEventValueChanged];
//            
//            [cell addSubview:switchView];
//        }
//            break;
            
//        case 4:
//            titleStr = @"举报群";
//            break;
            
        case GroupSettingSectionQuit:
        {
            UIButton *quitButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 8, 280, 43)];
            [quitButton setBackgroundImage:[UIImage imageNamed:@"button_red"] forState:UIControlStateNormal];
            [quitButton setBackgroundImage:[UIImage imageNamed:@"button_red_down"] forState:UIControlStateHighlighted];
            [quitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [quitButton.titleLabel setTextColor:[UIColor whiteColor]];
            
            if([[GotyeOCAPI getLoginUser].name isEqualToString:groupTarget.ownerAccount])
                [quitButton setTitle:@"解散群" forState:UIControlStateNormal];
            else
                [quitButton setTitle:@"退出群" forState:UIControlStateNormal];
            
            [quitButton addTarget:self action:@selector(leaveClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:quitButton];
            cell.backgroundColor = [UIColor clearColor];
        }
            break;
            
        default:
            break;
    }
    
    cell.textLabel.text = titleStr;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == GroupSettingSectionInfo && [[GotyeOCAPI getLoginUser].name isEqualToString:groupTarget.ownerAccount])
    {
        GotyeGroupNameInputController *viewController = [[GotyeGroupNameInputController alloc] initWithTarget:groupTarget];
        viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

#pragma mark - nick name input view

@implementation GotyeGroupNameInputController

- (id)initWithTarget:(GotyeOCGroup*)target
{
    self = [self init];
    if(self)
    {
        groupTarget = target;
    }
    return self;
}

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
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick:)];
    
    self.navigationItem.title = @"昵称";
}

- (void)quitClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveClick:(id)sender
{
    groupTarget.name = textInput.text;
    groupTarget.ownerType = GotyeGroupTypePublic;
    
    [GotyeOCAPI reqModifyGroupInfo:groupTarget imagePath:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textInputEnd:(id)sender
{
    [sender resignFirstResponder];
}

@end
