/****************************************************************************
 Copyright(c) 2013-2014, Shanghai AiLiao Information Technology Co.,Ltd

 http://www.gotye.com.cn
 
 @author:	liugan
 @date:		2014-06-20
 @version:	v2.0
 @filename:	GotyeMessage.h
 @description:
 This header file declares gotye message class.
 Include "GotyeAPI.h" instead of this.
****************************************************************************/

#ifndef __GOTYE_MESSAGE_H__
#define __GOTYE_MESSAGE_H__

#include "GotyeChatTarget.h"

NS_GOTYEAPI_BEGIN
    
typedef enum
{
    GotyeMessageTypeText,   ///< text message
    GotyeMessageTypeImage,  ///< image message
    GotyeMessageTypeAudio,  ///< audio message
    GotyeMessageTypeUserData,  ///< user data
}GotyeMessageType;  ///< enum gotye message type

typedef enum
{
    GotyeMessageStatusCreated,
    GotyeMessageStatusUnread,
    GotyeMessageStatusRead,
    GotyeMessageStatusSending,
    GotyeMessageStatusSent,
    GotyeMessageStatusSendingFailed
}GotyeMessageStatus; ///< enum gotye message status.

/**
 * @summary: GotyeMessage encapsulates text/audio/image/userdata message used in GotyeAPI.
 */
struct GotyeMessage
{
    long long id;   ///< message identifier
    unsigned date;  ///< the time since 1970/1/1 00:00:00, in seconds
    long long dbID;      ////< unique id in database.
    
    std::string text;    ///< text content, for text message only.
    
    GotyeMedia media;   ///< saving audio/image/userdata information.
    GotyeMedia extra;   ///< saving extra data.
    
    GotyeMessageType type;  ///< message type
    GotyeMessageStatus status;  ///< message status
    GotyeChatTarget sender, receiver;   ///< sender&receiver

    bool hasMedia() const; ///< check whether this message has media data or not.
    bool hasExtraData() const; ///< check whether this message has extra data or not.
    
	static GotyeMessage createMessage(GotyeChatTarget receiver);///< default sender is yourself
    static GotyeMessage createMessage(GotyeChatTarget sender, GotyeChatTarget receiver);
    
    static GotyeMessage createTextMessage(GotyeChatTarget receiver, const std::string& text);
	static GotyeMessage createTextMessage(GotyeChatTarget sender, GotyeChatTarget receiver, const std::string& text);
	
	static GotyeMessage createImageMessage(GotyeChatTarget receiver, std::string& imagePath);
    static GotyeMessage createImageMessage(GotyeChatTarget sender, GotyeChatTarget receiver, std::string& imagePath);
	
	static GotyeMessage createAudioMessage(GotyeChatTarget receiver, std::string& audioPath, unsigned duration);
	static GotyeMessage createAudioMessage(GotyeChatTarget sender, GotyeChatTarget receiver, std::string& audioPath, unsigned duration);
    
    static GotyeMessage createUserDataMessage(GotyeChatTarget receiver, std::string& dataPath);
    static GotyeMessage createUserDataMessage(GotyeChatTarget sender, GotyeChatTarget receiver, std::string& dataPath);
    
    static GotyeMessage createUserDataMessage(GotyeChatTarget receiver, const void* data, unsigned len);
	static GotyeMessage createUserDataMessage(GotyeChatTarget sender, GotyeChatTarget receiver, const void* data, unsigned len);
    
    GotyeMessage& putExtraData(void* data, unsigned len); ///< attach extra data to this message (< 1KB).
    GotyeMessage& putExtraData(const std::string& extraPath); ///< attach extra file to this message(filesize < 1KB).
    
    GotyeMessage();
    GotyeMessage(long long dbId);
    GotyeMessage(GotyeChatTarget sender, GotyeChatTarget receiver, GotyeMessageType type = GotyeMessageTypeText);
    
    GotyeChatTarget getTarget() const;
    bool operator < (const GotyeMessage& other) const;
    
};
NS_GOTYEAPI_END

#endif/* defined(__GOTYE_MESSAGE_H__) */
