//
//  GotyeGroupSettingController.h
//  GotyeIM
//
//  Created by Peter on 14-10-20.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeAPI.h"

USING_NS_GOTYEAPI;

typedef enum {
	GroupSettingSectionInfo,
    GroupSettingSectionMember,
    GroupSettingSectionOwner,
    GroupSettingSectionNickname,
//    GroupSettingSectionMessage,
    GroupSettingSectionQuit,
    GroupSettingSectionMaxCount,
} GroupSettingSection;

@interface GotyeGroupSettingController : UITableViewController
{
    GotyeGroup groupTarget;

    UIView *headListView;
        
    NSMutableDictionary *groupSetting;
    
    std::vector<GotyeUser> groupUserlist;
}

-(id)initWithTarget:(GotyeGroup)target;

@end

@interface GotyeGroupNameInputController : UIViewController
{
    GotyeGroup groupTarget;

    UITextField *textInput;
}

-(id)initWithTarget:(GotyeGroup)target;

@end
