//
//  GotyeSettingViewController.h
//  GotyeIM
//
//  Created by Peter on 14-9-28.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	SettingUserTypeHead,
    SettingUserTypeNickName,
    SettingUserTypeID,
    SettingUserTypeMax,
} SettingUserType;

typedef enum {
	SettingSwitchTypeNotify,
    SettingSwitchTypeGroupMute,
    SettingSwitchTypeMax,
} SettingSwitchType;

@interface GotyeSettingViewController : UITableViewController
{
    NSMutableDictionary *globalSetting;
}

@end

@interface GotyeNickNameInputController : UIViewController
{
    UITextField *textInput;
}

@end

