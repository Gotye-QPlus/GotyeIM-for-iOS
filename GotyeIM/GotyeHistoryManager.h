//
//  GotyeHistoryManager.h
//  GotyeIM
//
//  Created by Peter on 14-10-14.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "GotyeAPI.h"

USING_NS_GOTYEAPI;

#define History_key_type        @"HistoryType"
#define History_key_ID          @"HistoryID"
#define History_key_Content     @"HistoryContent"

#define Message_key_ID          @"msgID"
#define Message_key_Type        @"msgType"
#define Message_key_Content     @"msgContent"
#define Message_key_ContentEx   @"msgContentEx"
#define Message_key_Sender      @"msgSender"
#define Message_key_Date        @"msgDate"
#define Message_key_Duration    @"msgDuration"
#define Message_key_Read        @"msgRead"

#define Target_key_ID           @"TargetID"
#define Target_key_Type         @"TargetType"
#define Target_key_Name         @"TargetName"
#define Target_key_GroupOwner   @"TargetGroupOwner"
#define Target_key_IconURL      @"TargetIconURL"
#define Target_key_IconPath     @"TargetIconPath"

@interface GotyeHistoryManager : NSObject
{
    NSMutableDictionary *_historyDic;
    NSMutableArray *_historyOrder;
    NSMutableDictionary *_targetList;
    NSMutableArray *_friendsArray;
    
    NSString *historyDir;
}

+(instancetype) defaultManager;

-(void)setLoginUserName:(NSString*)userName;
-(void)addHistory:(GotyeMessage*)message;
-(void)removeMessage:(NSString*)historyKey;

-(void)setMessagesRead:(NSString*)historyKey;
-(void)removeInviteMessage:(NSInteger)index;

-(BOOL)addFriends:(NSString*)userName;
-(void)removeFriend:(NSString*)username;

@property (readonly, nonatomic) NSDictionary *historyDictionary;
@property (readonly, nonatomic) NSArray *historyOrder;
@property (readonly, nonatomic) NSDictionary *targetDictionary;
@property (readonly, nonatomic) NSMutableArray *friendsArray;
@property (readonly, nonatomic) NSString *historyDirectory;

@end
