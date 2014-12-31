//
//  GotyeOCChatTarget.h
//  GotyeAPI
//
//  Created by Peter on 14/12/3.
//  Copyright (c) 2014年 Ailiao Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GotyeOCMedia.h"

typedef enum
{
    GotyeChatTargetTypeUser,    ///< friend
    GotyeChatTargetTypeRoom,    ///< room
    GotyeChatTargetTypeGroup,   ///< group
}GotyeChatTargetType;   ///< enum chat target type

typedef enum
{
    GotyeUserGenderMale,    ///< male
    GotyeUserGenderFemale,  ///< female
    GotyeUserGenderNotSet   ///< not set
}GotyeUserGender;   ///< enum user gender

typedef enum {
    GotyeGroupTypePublic,
    GotyeGroupTypePrivate
}GotyeGroupType;

@interface GotyeOCChatTarget : NSObject

@property(nonatomic, assign) GotyeChatTargetType type;   ///< chat target type

@property(nonatomic, assign) long long id;    ///< the unique identifier
@property(nonatomic, copy) NSString* name;    ///< room/group name for GotyeRoom or username(UNIQUE) for GotyeUser.
@property(nonatomic, assign) unsigned tag;   ///< reserved

@property(nonatomic, copy) NSString* info; ///< extra information
@property(nonatomic, assign) bool hasGotDetail;

@property(nonatomic, retain) GotyeOCMedia* icon;    ///< the icon of GotyeRoom/GotyeUser. Using GotyeAPI::downloadMedia to download the image if needed.

@end

@interface GotyeOCUser : GotyeOCChatTarget

@property(nonatomic, copy) NSString* nickname;
@property(nonatomic, assign) GotyeUserGender gender;

@property(nonatomic, assign) bool isBlocked;
@property(nonatomic, assign) bool isFriend;

+(instancetype)userWithName:(NSString*)name;

@end

@interface GotyeOCRoom : GotyeOCChatTarget

@property(nonatomic, assign) bool isTop; ///< top or not

@property(nonatomic, assign) unsigned capacity; ///< the maxinum member count
@property(nonatomic, assign) unsigned onlineNumber;  ///< how many members currently online

+(instancetype)roomWithId:(long long)roomid;

@end

@interface GotyeOCGroup : GotyeOCChatTarget

@property(nonatomic, assign) GotyeGroupType ownerType; ///< public = 0 private = 1
@property(nonatomic, copy) NSString* ownerAccount; ///<owner account of this group
@property(nonatomic, assign) bool needAuthentication;

@property(nonatomic, assign) unsigned capacity; ///< the maxinum member count

+(instancetype)groupWithId:(long long)groupid;

@end

