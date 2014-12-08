//
//  GotyeChatRoomSettingController.h
//  GotyeIM
//
//  Created by Peter on 14-10-24.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeAPI.h"

USING_NS_GOTYEAPI;

typedef enum {
    RoomSettingSectionMember,
    RoomSettingSectionNickname,
//    RoomSettingSectionMessage,
    RoomSettingSectionMaxCount,
} RoomSettingSection;

@interface GotyeChatRoomSettingController : UITableViewController
{
    GotyeRoom roomTarget;
    
    UIView *headListView;

    NSMutableDictionary *roomSetting;
    
    std::vector<GotyeUser> roomUserlist;
}

-(id)initWithTarget:(GotyeRoom)target;

@end
