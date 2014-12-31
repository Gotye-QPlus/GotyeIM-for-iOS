//
//  GotyeSettingManager.h
//  GotyeIM
//
//  Created by Peter on 14-10-24.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GotyeOCAPI.h"

#define Setting_key_NickName            @"displayNickname"
#define Setting_key_Stick               @"stickMessage"
#define Setting_key_NoDisturb           @"doNotDisturb"

@interface GotyeSettingManager : NSObject
{
    NSString *settingDir;
}

+(instancetype) defaultManager;

@property (readonly, nonatomic) NSString *settingDirectory;

-(void)setLoginUserName:(NSString*)userName;

-(NSMutableDictionary*)getSetting:(GotyeChatTargetType)type targetID:(NSString*)targetID;
-(void)saveSetting:(NSDictionary*)settingDic targetType:(GotyeChatTargetType)type targetID:(NSString*)targetID;

@end
