//
//  GotyeChatRoomSettingController.h
//  GotyeIM
//
//  Created by Peter on 14-10-24.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeOCAPI.h"


typedef enum {
    RoomSettingSectionMember,
    RoomSettingSectionNickname,
//    RoomSettingSectionMessage,
    RoomSettingSectionMaxCount,
} RoomSettingSection;

@interface GotyeChatRoomSettingController : UITableViewController
{
    GotyeOCRoom* roomTarget;
    
    UIView *headListView;

    NSMutableDictionary *roomSetting;
    
    NSArray* roomUserlist;
}

-(id)initWithTarget:(GotyeOCRoom*)target;

@end
