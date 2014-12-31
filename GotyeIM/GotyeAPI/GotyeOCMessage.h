//
//  GotyeMessage.h
//  GotyeAPI
//
//  Created by Peter on 14/12/3.
//  Copyright (c) 2014年 Ailiao Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GotyeOCMedia.h"
#import "GotyeOCChatTarget.h"

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

typedef enum
{
	GotyeWhineModeDefault,              ///< original
	GotyeWhineModeFatherChristmas,      ///< father christmas
	GotyeWhineModeOptimus,              ///< optimus prime
	GotyeWhineModeDolphine,             ///< dolphin
	GotyeWhineModeBaby,                 ///< baby
	GotyeWhineModeSubwoofer             ///< subwoofer
}GotyeWhineMode;	///< enum whine mode

@interface GotyeOCMessage : NSObject

@property(nonatomic, assign) long long id;   ///< message identifier
@property(nonatomic, assign) unsigned date;  ///< the time since 1970/1/1 00:00:00, in seconds
@property(nonatomic, assign) long long dbID;      ////< unique id in database.

@property(nonatomic, copy) NSString* text;    ///< text content, for text message only.

@property(nonatomic, retain) GotyeOCMedia* media;   ///< saving audio/image/userdata information.
@property(nonatomic, retain) GotyeOCMedia* extra;   ///< saving extra data.

@property(nonatomic, assign) GotyeMessageType type;  ///< message type
@property(nonatomic, assign) GotyeMessageStatus status;  ///< message status
@property(nonatomic, retain) GotyeOCChatTarget* sender;
@property(nonatomic, retain) GotyeOCChatTarget* receiver;   ///< sender&receiver

-(bool) hasMedia; ///< check whether this message has media data or not.
-(bool) hasExtraData; ///< check whether this message has extra data or not.

+(instancetype)createMessage:(GotyeOCChatTarget*)receiver;///< default sender is yourself
+(instancetype)createMessage:(GotyeOCChatTarget*)sender  receiver:(GotyeOCChatTarget*)receiver;

+(instancetype)createTextMessage:(GotyeOCChatTarget*)receiver text:(NSString*)text;
+(instancetype)createTextMessage:(GotyeOCChatTarget*)sender receiver:(GotyeOCChatTarget*)receiver text:(NSString*)text;

+(instancetype)createImageMessage:(GotyeOCChatTarget*)receiver imagePath:(NSString*)imagePath;
+(instancetype)createImageMessage:(GotyeOCChatTarget*)sender receiver:(GotyeOCChatTarget*)receiver imagePath:(NSString*)imagePath;

+(instancetype)createAudioMessage:(GotyeOCChatTarget*)receiver audioPath:(NSString*)audioPath duration:(unsigned )duration;
+(instancetype)createAudioMessage:(GotyeOCChatTarget*)sender receiver:(GotyeOCChatTarget*)receiver audioPath:(NSString*)audioPath duration:(unsigned )duration;

+(instancetype)createUserDataMessage:(GotyeOCChatTarget*)receiver dataPath:(NSString*)dataPath;
+(instancetype)createUserDataMessage:(GotyeOCChatTarget*)sender receiver:(GotyeOCChatTarget*)receiver dataPath:(NSString*)dataPath;

+(instancetype)createUserDataMessage:(GotyeOCChatTarget*)receiver data:(const void*)data len:(unsigned)len;
+(instancetype)createUserDataMessage:(GotyeOCChatTarget*)sender receiver:(GotyeOCChatTarget*)receiver data:(const void*)data len:(unsigned)len;

-(void)putExtraData:(void*) data  len:(unsigned)len; ///< attach extra data to this message (< 1KB).
-(void)putExtraData:(NSString*)extraPath; ///< attach extra file to this message(filesize < 1KB).

@end
