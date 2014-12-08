/****************************************************************************
 Copyright(c) 2013-2014, Shanghai AiLiao Information Technology Co.,Ltd

 http://www.gotye.com.cn
 
 @author:	liugan
 @date:		2014-06-20
 @version:	v3.0
 @filename:	GotyeChatTarget.h
 @description:
 This header file provides definitions of chat target(friend/room).
 Include "GotyeAPI.h" instead of this.
****************************************************************************/

#ifndef __GOTYE_CHATTARGET_H__
#define __GOTYE_CHATTARGET_H__

#include "GotyeMedia.h"

NS_GOTYEAPI_BEGIN
    
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

//base struct of GotyeUser&GotyeRoom&GotyeGroup
struct GotyeChatTarget
{
    GotyeChatTargetType type;   ///< chat target type
    
    long long id;    ///< the unique identifier
    std::string name;    ///< room/group name for GotyeRoom or username(UNIQUE) for GotyeUser.
    unsigned tag;   ///< reserved
    
    std::string info; ///< extra information
    bool hasGotDetail;
    
    GotyeMedia icon;    ///< the icon of GotyeRoom/GotyeUser. Using GotyeAPI::downloadMedia to download the image if needed.
    
    GotyeChatTarget();
    GotyeChatTarget(std::string username);
    GotyeChatTarget(const char* username);
    GotyeChatTarget(long long uid, GotyeChatTargetType t);
    
    bool operator==(const GotyeChatTarget& rTarget) const;

};
    
struct GotyeUser:public GotyeChatTarget
{
    std::string nickname;
    GotyeUserGender gender;

    bool isBlocked;
    bool isFriend;
    
    GotyeUser();
    GotyeUser(const char* username); ///< recommended
    GotyeUser(std::string username); ///< recommended
    
    bool operator==(const GotyeUser& rUser) const;
};

typedef GotyeUser GotyeLoginUser;

    
struct GotyeRoom:public GotyeChatTarget
{
    bool isTop; ///< top or not
    
    unsigned capacity; ///< the maxinum member count
    unsigned onlineNumber;  ///< how many members currently online
    
    GotyeRoom();
    GotyeRoom(unsigned roomId);   ///<recommended
    
    bool operator==(const GotyeRoom& rRoom) const;
};

struct GotyeGroup:public GotyeChatTarget
{
    GotyeGroupType ownerType; ///< public = 0 private = 1
    std::string ownerAccount; ///<owner account of this group
    bool needAuthentication;
    
    unsigned capacity; ///< the maxinum member count
    
    GotyeGroup();
    GotyeGroup(long long groupId); ///<recommended
    
    bool operator==(const GotyeGroup& rGroup) const;
};

NS_GOTYEAPI_END

#endif/* defined(__GOTYE_CHATTARGET_H__) */
