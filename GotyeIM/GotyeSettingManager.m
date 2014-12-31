//
//  GotyeSettingManager.m
//  GotyeIM
//
//  Created by Peter on 14-10-24.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeSettingManager.h"

static GotyeSettingManager *_settingInstance = nil;

#define Setting_Dir             @"/setting/"

@implementation GotyeSettingManager

+(instancetype) defaultManager
{
    if(_settingInstance == nil)
    {
        _settingInstance = [[self alloc] init];
    }
    
    return _settingInstance;
}

-(NSString*)settingDirectory
{
    return settingDir;
}

- (void)setLoginUserName:(NSString*)userName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    settingDir = [paths[0] stringByAppendingFormat:@"%@%@/", Setting_Dir, userName];
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:settingDir])
    {
        [manager createDirectoryAtPath:settingDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

-(NSMutableDictionary*)getSetting:(GotyeChatTargetType)type targetID:(NSString*)targetID
{
    NSString *settingPath = [NSString stringWithFormat:@"%@setting_%d_%@.plist", settingDir, type, targetID];
    NSMutableDictionary *settingDic = [NSMutableDictionary dictionaryWithContentsOfFile:settingPath];
    if(settingDic == nil)
    {
        settingDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], Setting_key_NickName,
                             [NSNumber numberWithBool:NO], Setting_key_NoDisturb,
                             [NSNumber numberWithBool:NO], Setting_key_Stick, nil];
        
        [settingDic writeToFile:settingPath atomically:YES];
    }
    
    return settingDic;
}

-(void)saveSetting:(NSDictionary*)settingDic targetType:(GotyeChatTargetType)type targetID:(NSString*)targetID
{
    NSString *settingPath = [NSString stringWithFormat:@"%@setting_%d_%@.plist", settingDir, type, targetID];
    
    [settingDic writeToFile:settingPath atomically:YES];
}

@end
