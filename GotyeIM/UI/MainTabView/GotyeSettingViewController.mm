//
//  GotyeSettingViewController.m
//  GotyeIM
//
//  Created by Peter on 14-9-28.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeSettingViewController.h"

#import "GotyeUIUtil.h"
#import "GotyeDelegateManager.h"
#import "GotyeSettingManager.h"

#import "GotyeLoginController.h"

#define HeadMaxSize 200

@interface GotyeSettingViewController () <GotyeUIDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation GotyeSettingViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.tabBarItem.image = [[UIImage imageNamed:@"tab_button_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_button_settings"];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    
    delegateist->addDelegate(self);
    
    globalSetting = [[GotyeSettingManager defaultManager] getSetting:apiist->getLoginUser().type targetID:[NSString stringWithFormat:@"%lld", apiist->getLoginUser().id]];
}

- (void)viewWillAppear:(BOOL)animated
{
    delegateist->addDelegate(self);
    
    self.tabBarController.navigationItem.title = @"设置";
    
    [self.tableView reloadData];
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

- (void)logoutClick:(id)sender
{
    apiist->logout();
}

- (void)clearCacheClick:(id)sender
{
    apiist->clearCache();
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"缓存已清除"
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)headSelectClick:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从手机相册选择", nil];
    
    [actionSheet showInView:self.view.window];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex!=[actionSheet cancelButtonIndex])
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
    
    GotyeLoginUser loginUser = apiist->getLoginUser();
    std::string tempPathStd = STDStringUTF8(tempPath);
    apiist->reqModifyUserInfo(loginUser, &tempPathStd);
}

-(void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for(UIView *subView in actionSheet.subviews)
    {
        if([subView isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton*)subView;
            //            button.adjustsImageWhenHighlighted = NO;
            //            button.frame = CGRectMake(20, button.frame.origin.y, 280, button.frame.size.height);
            //            button.backgroundColor = [UIColor clearColor];
            //
            //            if(button.tag == actionSheet.numberOfButtons)
            //            {
            //                [button setBackgroundImage:[UIImage imageNamed:@"button_gray"] forState:UIControlStateNormal];
            //                [button setBackgroundImage:[UIImage imageNamed:@"button_gray_down"] forState:UIControlStateHighlighted];
            //            }
            //            else
            //            {
            //                [button setBackgroundImage:[UIImage imageNamed:@"button_red"] forState:UIControlStateNormal];
            //                [button setBackgroundImage:[UIImage imageNamed:@"button_red_down"] forState:UIControlStateHighlighted];
            //            }
            [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

- (void)swichChanged:(UISwitch*)sw
{
    UITableViewCell *cell = (UITableViewCell *)sw.superview.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if(indexPath.row == SettingSwitchTypeNotify)
        globalSetting[Setting_key_Stick] = [NSNumber numberWithBool:sw.isOn];
    else if(indexPath.row == SettingSwitchTypeGroupMute)
        globalSetting[Setting_key_NoDisturb] = [NSNumber numberWithBool:sw.isOn];
    
    [[GotyeSettingManager defaultManager] saveSetting:globalSetting targetType:apiist->getLoginUser().type targetID:[NSString stringWithFormat:@"%lld", apiist->getLoginUser().id]];
}

#pragma mark - Gotye UI delegates

- (void)onModifyUserInfo:(GotyeStatusCode)code user:(gotyeapi::GotyeUser)user
{
    [self.tableView reloadData];
}

- (void)onGetProfile:(GotyeStatusCode)code user:(GotyeLoginUser)user
{
    [self.tableView reloadData];
}

#pragma mark - table delegate & data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return SettingUserTypeMax;
//    else if(section == 1)
//        return SettingSwitchTypeMax;
    
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 0;
    
    return 21;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == SettingUserTypeHead)
        return 60;
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *GotyeSettingCellIdentifier = @"GotyeSettingCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GotyeSettingCellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *titleStr;
    UIView *contentView;
    
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case SettingUserTypeHead:
            {
                titleStr = @"头像";
                UIButton *headview = [[UIButton alloc] initWithFrame:CGRectMake(300 - 46, 7, 46, 46)];

                GotyeLoginUser loginUser = apiist->getLoginUser();
                UIImage *headImage = [GotyeUIUtil getHeadImage:NSStringUTF8(loginUser.icon.path) defaultIcon:@"head_icon_user"];
                [headview setBackgroundImage:headImage forState:UIControlStateNormal];
                
                [headview addTarget:self action:@selector(headSelectClick:) forControlEvents:UIControlEventTouchUpInside];
                
                contentView = headview;
            }
                break;
                
            case SettingUserTypeNickName:
            {
                titleStr = @"昵称";
                
                GotyeLoginUser loginUser = apiist->getLoginUser();
                
                UILabel *contentText = [[UILabel alloc] initWithFrame:CGRectMake(300 - 150, 15, 150, 20)];
                contentText.backgroundColor = [UIColor clearColor];
                contentText.textColor = [UIColor lightGrayColor];
                contentText.font = [UIFont systemFontOfSize:12];
                contentText.textAlignment = NSTextAlignmentRight;
                contentText.text = NSStringUTF8(loginUser.nickname);
                
                contentView = contentText;
            }
                break;
                
            case SettingUserTypeID:
            {
                titleStr = @"ID";
                
                GotyeLoginUser loginUser = apiist->getLoginUser();

                UILabel *contentText = [[UILabel alloc] initWithFrame:CGRectMake(300 - 150, 15, 150, 20)];
                contentText.backgroundColor = [UIColor clearColor];
                contentText.textColor = [UIColor lightGrayColor];
                contentText.font = [UIFont systemFontOfSize:12];
                contentText.textAlignment = NSTextAlignmentRight;
                contentText.text = NSStringUTF8(loginUser.name);//[NSString stringWithFormat:@"%lld", loginUser.id];
                
                contentView = contentText;
            }
                break;

            default:
                break;
        }
    }
//    else if(indexPath.section == 1)
//    {
//        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(300 - 49, 10, 49, 31)];
//            
//        switchView.onTintColor = Common_Color_Def_Gray;
//        switchView.thumbTintColor = Common_Color_Def_Nav;
//        if (indexPath.row == SettingSwitchTypeNotify)
//        {
//            titleStr = @"新消息通知";
//            switchView.on = [globalSetting[Setting_key_Stick] boolValue];
//        }
//        else
//        {
//            titleStr = @"群消息勿扰";
//            switchView.on = [globalSetting[Setting_key_NoDisturb] boolValue];
//        }
//        [switchView addTarget:self action:@selector(swichChanged:) forControlEvents:UIControlEventValueChanged];
//        
//        contentView = switchView;
//    }
    else if(indexPath.section == 1)
    {
        UIButton *quitButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 8, 280, 33)];
        [quitButton setBackgroundImage:[UIImage imageNamed:@"button_red"] forState:UIControlStateNormal];
        [quitButton setBackgroundImage:[UIImage imageNamed:@"button_red_down"] forState:UIControlStateHighlighted];
        [quitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [quitButton.titleLabel setTextColor:[UIColor whiteColor]];
        [quitButton setTitle:@"清除缓存" forState:UIControlStateNormal];
        
        [quitButton addTarget:self action:@selector(clearCacheClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:quitButton];
        cell.backgroundColor = [UIColor clearColor];
    }

    else if(indexPath.section == 2)
    {
        UIButton *quitButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 8, 280, 33)];
        [quitButton setBackgroundImage:[UIImage imageNamed:@"button_red"] forState:UIControlStateNormal];
        [quitButton setBackgroundImage:[UIImage imageNamed:@"button_red_down"] forState:UIControlStateHighlighted];
        [quitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [quitButton.titleLabel setTextColor:[UIColor whiteColor]];
        [quitButton setTitle:@"退出" forState:UIControlStateNormal];
        
        [quitButton addTarget:self action:@selector(logoutClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:quitButton];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.textLabel.text = titleStr;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    if(contentView != nil)
       [cell.contentView addSubview:contentView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == SettingUserTypeNickName)
    {
        GotyeNickNameInputController *viewController = [[GotyeNickNameInputController alloc] init];
        viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

#pragma mark - nick name input view

@implementation GotyeNickNameInputController

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
    std::string nickname = STDStringUTF8(textInput.text);
    GotyeUser  user = apiist->getLoginUser();
    user.nickname = nickname;
    apiist->reqModifyUserInfo(user);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textInputEnd:(id)sender
{
    [sender resignFirstResponder];
}

@end

