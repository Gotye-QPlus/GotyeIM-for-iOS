//
//  GotyeOCNotify.h
//  GotyeAPI
//
//  Created by Peter on 14/12/4.
//  Copyright (c) 2014年 Ailiao Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GotyeOCChatTarget.h"

typedef enum {
    GotyeNotifyTypeGroupInvite,
    GotyeNotifyTypeJoinGroupRequest,
    GotyeNotifyTypeJoinGroupReply
}GotyeNotifyType;

@interface GotyeOCNotify : NSObject

@property(nonatomic, assign) long dbID;  ///< database ID
@property(nonatomic, assign) long date; ///< seconds since 1970.1.1 00:00
@property(nonatomic, assign) bool isRead;    ///< read or not.
@property(nonatomic, retain) GotyeOCChatTarget* sender;
@property(nonatomic, retain) GotyeOCChatTarget* receiver;
@property(nonatomic, retain) GotyeOCChatTarget* from; ///< source of notify. GotyeNotifyTypeGroupInvite is from some group, etc.
@property(nonatomic, assign) bool agree;

@property(nonatomic, assign) bool isSystemNotify;
@property(nonatomic, assign) GotyeNotifyType type;
@property(nonatomic, copy) NSString* text;   ///< notify content.

@end
