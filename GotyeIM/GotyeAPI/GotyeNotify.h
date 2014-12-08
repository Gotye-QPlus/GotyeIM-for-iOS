//
//  GotyeNotify.h
//  GotyeAPI
//
//  Created by ouyang on 14/10/30.
//  Copyright (c) 2014年 Ailiao Technologies. All rights reserved.
//

#ifndef GotyeAPI_GotyeNotify_h
#define GotyeAPI_GotyeNotify_h

#include "GotyeChatTarget.h"

NS_GOTYEAPI_BEGIN


typedef enum {
    GotyeNotifyTypeGroupInvite,
    GotyeNotifyTypeJoinGroupRequest,
    GotyeNotifyTypeJoinGroupReply
}GotyeNotifyType;

struct GotyeNotify {
    long dbID;  ///< database ID
    long date; ///< seconds since 1970.1.1 00:00
    bool isRead;    ///< read or not.
    GotyeChatTarget sender;
    GotyeChatTarget receiver;
    GotyeChatTarget from; ///< source of notify. GotyeNotifyTypeGroupInvite is from some group, etc.
    bool agree;
    
    bool isSystemNotify;
    GotyeNotifyType type;
    std::string text;   ///< notify content.
    
    GotyeNotify(GotyeNotifyType type):dbID(0), date(0), isRead(false), isSystemNotify(false), type(type), text(""){};
    GotyeNotify():dbID(0), date(0), isRead(false), isSystemNotify(false), type(GotyeNotifyTypeGroupInvite), text(""){};
};

NS_GOTYEAPI_END

#endif
