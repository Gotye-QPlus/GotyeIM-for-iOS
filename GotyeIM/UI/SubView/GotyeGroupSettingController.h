//
//  GotyeGroupSettingController.h
//  GotyeIM
//
//  Created by Peter on 14-10-20.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeOCAPI.h"


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
    GotyeOCGroup* groupTarget;

    UIView *headListView;
        
    NSMutableDictionary *groupSetting;
    
    NSArray* groupUserlist;
}

-(id)initWithTarget:(GotyeOCGroup*)target;

@end

@interface GotyeGroupNameInputController : UIViewController
{
    GotyeOCGroup* groupTarget;

    UITextField *textInput;
}

-(id)initWithTarget:(GotyeOCGroup*)target;

@end
