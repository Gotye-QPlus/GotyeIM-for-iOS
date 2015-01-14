//
//  GotyeOCAPI.h
//  GotyeAPI
//
//  Created by Peter on 14/12/4.
//  Copyright (c) 2014年 Ailiao Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GotyeOCMessage.h"
#import "GotyeOCNotify.h"
#import "GotyeOCChatTarget.h"
#import "GotyeOCDeleget.h"

@interface GotyeOCAPI : NSObject

/**
 * @summary: initialize api with appKey and packageName
 * @param appKey: your registered application key in Gotye ManagementSystem.
 * @param packageName: your application package name
 * @return: GotyeStatusCodeOK if succeeded, otherwise failure.
 */
+(status)init:(NSString*)appKey packageName:(NSString*)packageName;


/**
 * @summary: release all components and terminate all background threads.
 */
+(void)exit;

/**
 * @summary: register PUSH Service, for iOS only.
 * @param deviceToken: your device token.
 * @param certName: your certificate name.
 * @return: GotyeStatusCodeOK if succeeded, otherwise failure.
 */
+(bool)registerAPNS:(NSString*)deviceToken certName:(NSString*)certName;

/**
 * @summary: enable/disable apple push service
 * @param enabled: true if your app need push service, otherwise false.
 * @return: GotyeStatusCodeOK if succeeded, otherwise failure.
 */
+(bool)enableAPNS:(bool)enabled;

/**
 * @summary: update the unread message count saved in Gotye IM server.
 * @param decrement: how many messages hava been marked as read.
 */
+(void)updateUnreadMessageCount:(int)count;

/**
 * @summary: clear cache files.
 */
+(status)clearCache;

/**
 * @summary: register/remove an async callback.
 */
+(status)removeAllListeners;
+(status)addListener:(id<GotyeOCDelegate>)listener;
+(status)removeListener:(id<GotyeOCDelegate>)listener;

/**
 * @summary: sign in with username and password
 * @param username: the unique identifier of user
 * @param password: assign "nullptr" if no password
 * @return: GotyeStatusCodeWaitingCallback if succeeded, and the result will be passed via async callback
 * @callback: GotyeDelegate::onLogin
 */
+(status)login:(NSString*)username password:(NSString*)password;

/**
 * @summary: get current online status.
 * @return: True if online, otherwise offline.
 */
+(int)isOnline;

/**
 * @summary: get current login user profile.
 */
+(GotyeOCUser*)getLoginUser;

/**
 * @summary: request modifying the user information of current account
 * @param user: login user.
 * @param imagePath: the fullpath of new head icon file, assign "nullptr" if you don't want to modify.
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onModifyUserInfo
 */
+(status)reqModifyUserInfo:(GotyeOCUser*)user imagePath:(NSString*)imagePath;

/**
 * @summary: logout
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onLogout
 */
+(status)logout;

/**
 * @summary: init each user search after you changed the search keyword.
 * This interface will clear all datas in local user search result list and current page list.
 */
+(void)resetUserSearch;

/**
 * @summary: return the reference of local user search result list.
 */
+(NSArray*)getLocalUserSearchList;

/**
 * @summary: return the reference of local user search result list(current page).
 */
+(NSArray*)getLocalUserSearchCurPageList;

/**
 * @summary: search users by keyword (username/nickname/gender)
 * @param pageIndex: index of search result(16 users per page)
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onSearchUserList
 */
+(status)reqSearchUserList:(unsigned)pageIndex username:(NSString*)username nickname:(NSString*)nickname gender:(GotyeUserGender)gender;

/**
 * @summary: get the user detail information, this will sending a request if there is no cache information at local
 * or forceRequest is true.
 * @return: local detail information( if exists)
 * @callback: GotyeDelegate::onGetUserDetail
 */
+(GotyeOCUser*)getUserDetail:(GotyeOCChatTarget*)target forceRequest:(bool)forceRequest;

/**
 * @summary: get local friend list
 * @return: local friend list
 */
+(NSArray*)getLocalFriendList;

/**
 * @summary: get local blocked list
 * @return: local blocked list
 */
+(NSArray*)getLocalBlockedList;

/**
 * @summary:request friend list
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onGetFriendList
 */
+(status)reqFriendList;

/**
 * @summary: request the blocked list from Gotye server.
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onGetBlockedList
 */
+(status)reqBlockedList;

/**
 * @summary: add the specified friend to friend list.
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onAddFriend
 */
+(status)reqAddFriend:(GotyeOCUser*)who;

/**
 * @summary: add the specified user to blocked list.
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onAddBlocked
 */
+(status)reqAddBlocked:(GotyeOCUser*)who;

/**
 * @summary: remove the specified friend from friend list.
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onRemoveFriend
 */
+(status)reqRemoveFriend:(GotyeOCUser*)who;

/**
 * @summary: remove the specified user from blocked list.
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onRemoveBlocked
 */
+(status)reqRemoveBlocked:(GotyeOCUser*)who;

/**
 * @summary: request room list for pageIndex
 * @param pageIndex: page index, starts with 0
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onGetRoomList
 */
+(status)reqRoomList:(unsigned)pageIndex;

/**
 * @summary: get the local roomlist reference.
 */
+(NSArray*)getLocalRoomList;

/**
 * @summary: clear local cached room list.
 */
+(void)clearLocalRoomList;

/**
 * @summary: get room detail information.
 */
+(GotyeOCRoom*)getRoomDetail:(GotyeOCChatTarget*)target;

/**
 * @summary: check if you are in the indicated room or not.
 * @param room: which room you wanna check
 * @return: true if you are in the room, false otherwise.
 */
+(bool)isInRoom:(GotyeOCRoom*)room;

/**
 * @summary: enter the indicated room.
 * @param room: which room
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onEnterRoom
 */
+(status)enterRoom:(GotyeOCRoom*)room;

/**
 * @summary: leave the indicated room.
 * @param room: which room
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onLeaveRoom
 */
+(status)leaveRoom:(GotyeOCRoom*)room;

/**
 * @summary: check if the indicated room supports realtime voice or not.
 */
+(bool)supportRealtime:(GotyeOCChatTarget*)target;

/**
 * @summary: request member list in indicated room with pageIndex
 * @param pageIndex: page index, starts with 0
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onGetRoomUserList
 */
+(status)reqRoomMemberList:(GotyeOCRoom*)room pageIndex:(unsigned)pageIndex;

/**
 * @summary: init each group search after you changed the search keyword.
 * This interface will clear all datas in local group search result list and current page list.
 */
+(void)resetGroupSearch;

/**
 * @summary: get the local reference of group search result list.
 */
+(NSArray*)getLocalGroupSearchList;

/**
 * @summary: get the local reference of group search result list(current page).
 */
+(NSArray*)getLocalGroupSearchCurPageList;

/**
 * @summary: search group by groupname.
 */
+(status)reqSearchGroup:(NSString*)groupname pageIndex:(unsigned)pageIndex;

/**
 * @summary: get the group detail information.
 */
+(GotyeOCGroup*)getGroupDetail:(GotyeOCChatTarget*)target forceRequest:(bool)forceRequest;

/**
 * @summary: create group with some parameters.
 * @param group: base information of group to create.
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onCreateGroup
 */
+(status)createGroup:(GotyeOCGroup*)group;

/**
 * @summary: enter the indicated group.
 * @param group: which group
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onJoinGroup
 */
+(status)joinGroup:(GotyeOCGroup*)group;

/**
 * @summary: leave the indicated group.
 * @param group: which group
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onLeaveGroup
 */
+(status)leaveGroup:(GotyeOCGroup*)group;

/**
 * @summary: dismiss the indicated group.
 * @param group: which group
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onDismissGroup
 */
+(status)dismissGroup:(GotyeOCGroup*)group;

/**
 * @summary: kickout specified user in group.
 * @param group: which group
 * @param username: which user to kick
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onKickoutGroupMember
 */
+(status)kickoutGroupMember:(GotyeOCGroup*)group user:(GotyeOCUser*)user;

/**
 * @summary: change specified user to group owner.
 * @param group: which group
 * @param username: which user
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onChangeGroupOwner
 */
+(status)changeGroupOwner:(GotyeOCGroup*)group user:(GotyeOCUser*)user;

/**
 * @summary: get the local reference of group list.
 */
+(NSArray*)getLocalGroupList;

/**
 * @summary: request the group list from server.
 * @callback: GotyeDelegate::onGetGroupList
 */
+(status)reqGroupList;

/**
 * @summary: request modifing the indicated group.
 * @callback: GotyeDelegate::onModifyGroupInfo
 */
+(status)reqModifyGroupInfo:(GotyeOCGroup*)group imagePath:(NSString*)imagePath;

/**
 * @summary: request group user list in specified group for pageIndex
 * @param group: which group
 * @param pageIndex: page index, starts with 0
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onGetGroupMemberList
 */
+(status)reqGroupMemberList:(GotyeOCGroup*)group pageIndex:(unsigned)pageIndex;

/**
 * @summary: invite user to specified group
 * @param username: user to invite
 * @param group: which group
 * @param inviteMessage: message of invite
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onReceiveNotify when receive other's invite
 */
+(status)inviteUserToGroup:(GotyeOCUser*)user group:(GotyeOCGroup*)group inviteMessage:(NSString*)inviteMessage;

/**
 * @summary: request joining the specified group
 * @param group: which group
 * @param applyMessage: message of apply
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onReceiveNotify when receive other's apply
 */
+(status)reqJoinGroup:(GotyeOCGroup*)group applyMessage:(NSString*)applyMessage;

/**
 * @summary: response apply to specified group
 * @param notify: apply notify
 * @param respMessage: message of response
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onReceiveNotify when receive response of your apply
 */
+(status)replyJoinGroup:(GotyeOCNotify*)applyNotify respMessage:(NSString*)respMessage agree:(bool)agree;

/**
 * @summary: get the local session list.
 */
+(NSArray*)getSessionList;

/**
 * @summary: active a session.
 */
+(void)activeSession:(GotyeOCChatTarget*)target;

/**
 * @summary: deactive a session
 */
+(void)deactiveSession:(GotyeOCChatTarget*)target;

/**
 * @summary: delete a session
 */
+(void)deleteSession:(GotyeOCChatTarget*)target alsoRemoveMessages:(BOOL)remove;

/**
 * @summary: mark session as top, this will change the order of the indicated session to 1st.
 */
+(void)markSessionIsTop:(GotyeOCChatTarget*)target :(bool)isTop;

/**
 * @summary: get the detail session information with indicated target.
 * @param target: with who
 * @param messageList: get local message list pointer.
 * @param memberList: get local member list pointer with indicated target(validate for GotyeRoom or GotyeGroup).
 * @param curPageMemberList:  get local current page member list pointer with indicated target(validate for GotyeRoom or GotyeGroup).
 * @param pageIndex: get the current page index of member list.
 * @return: true when session is valid.
 */
+(bool)getSessionInfo:(GotyeOCChatTarget*)target messageList:(NSMutableArray*)messageList memberList:(NSMutableArray*)memberList curPageMemberList:(NSMutableArray*)curPageMemberList  pageIndex:(unsigned*)pageIndex;

/**
 * @summary: get the local notify list.
 */
+(NSArray*)getNotifyList;

/**
 * @summary: mark a notify as read/unread.
 */
+(bool)markNofityIsRead:(GotyeOCNotify*)notify isRead:(bool)isRead;

/**
 * @summary: mark all notifies as read.
 */
+(void)clearNotifyUnreadStatus;

/**
 * @summary: delete some notifies.
 */
+(void)deleteNotifys:(NSArray*)notifys;

/**
 * @summary: delete the indicated notify.
 */
+(void)deleteNotify:(GotyeOCNotify*)notify;

/**
 * @summary: get unread notify count.
 */
+(int)getUnreadNotifyCount;


+(void)enableTextFilter:(bool)enabled inType:(GotyeChatTargetType)type;

/**
 * @summary: set the message increment for loading message from the local database, default is 10.
 */
+(void)setMessageReadIncrement:(unsigned)increment;

/**
 * @summary: set the message increment for requesting message from the Gotye server, default is 10.
 */
+(void)setMessageRequestIncrement:(unsigned)increment;

/**
 * @summary: begin receiving offline messages from server.
 */
+(void)beginReceiveOfflineMessage;

/**
 * @summary: get the message list with indicated target.
 * @param target: with who
 * @param more: api will load more messages from database or server if more is true, otherwise not.
 */
+(NSArray*)getMessageList:(GotyeOCChatTarget*)target more:(bool)more;

/**
 * @summary: mark all messages as read with indicated target.
 */
+(void)markMessagesAsRead:(GotyeOCChatTarget*)target isRead:(bool)isRead;

/**
 * @summary: mark a message as read.
 */
+(bool)markOneMessageAsRead:(GotyeOCMessage*)message isRead:(bool)isRead;

/**
 * @summary: delete messages with indicated target.
 */
+(void)deleteMessages:(GotyeOCChatTarget*)target msglist:(NSArray*)msglist;

/**
 * @summary: delete message with indicated target.
 */
+(void)deleteMessage:(GotyeOCChatTarget*)target msg:(GotyeOCMessage*)msg;

/**
 * @summary: clear all messages with indicated target.
 */
+(void)clearMessages:(GotyeOCChatTarget*)target;

/**
 * @summary: get the unread message count with indicated target.
 * @param target: with who
 */
+(int)getUnreadMessageCount:(GotyeOCChatTarget*)target;

/**
 * @summary: get the unread message count.
 */
+(int)getTotalUnreadMessageCount;

/**
 * @summary: get unread message count of the indicated type list(GotyeChatTargetTypeUser/GotyeChatTargetTypeRoom/GotyeChatTargetTypeGroup)
 * @param types: type list
 * @return: message count
 */
+(int)getUnreadMessageCountOfTypes:(NSArray*)types;

/**
 * @summary: get the last message with the indicated target
 * @param target: with who
 * @return: message object
 */
+(GotyeOCMessage*)getLastMessage:(GotyeOCChatTarget*)target;

/**
 * @summary: send message
 * @param message: message pointer
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onSendMessage
 */
+(status)sendMessage:(GotyeOCMessage*)message;

/**
 * @summary: download media content(audio/image) in the indicated message.
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onDownloadMediaInMessage
 */
+(status)downloadMediaInMessage:(GotyeOCMessage*)message;

/**
 * @summary: decode the amr file into a PCM file.
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onDecodeMessage
 */
+(status)decodeAudioMessage:(GotyeOCMessage*)message;

/**
 * @summary: report the indicated message
 * @param type: the type you have defined in gotye managementSystem
 * @param content: description of the message
 * @param message: which message you wanna report
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onReport
 */
+(status)report:(int)type content:(NSString*)content message:(GotyeOCMessage*)message;

/**
 * @summary: play audio message
 * @return: GotyeStatusCodeOK if succeeded
 * @callback: GotyeDelegate::onPlayStart, GotyeDelegate::onPlaying, GotyeDelegate::onPlayStop
 */
+(status)playMessage:(GotyeOCMessage*)message;

/**
 * @summary: stop playing audio.
 * @return: GotyeStatusCodeOK if succeeded.
 */
+(status)stopPlay;

/**
 * @summary: download media(audio/image).
 * @param media: media you want to download
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onDownloadMedia
 */
+(status)downloadMedia:(GotyeOCMedia*)media;

/**
 * @summary: start talk
 * @param target: with who
 * @param mode: whine mode
 * @param realtime: realtime or not.
 * @param maxDuration: maximum recording duration(millisecond,should <= 60000), default is 10000ms
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onStartTalk
 */
+(status)startTalk:(GotyeOCChatTarget*)target mode:(GotyeWhineMode)mode realtime:(bool)realtime maxDuration:(unsigned)maxDuration;

/**
 * @summary: stop talk manually
 * @return: GotyeStatusCodeWaitingCallback if succeeded
 * @callback: GotyeDelegate::onStopTalk
 */
+(status)stopTalk;

/**
 * @summary: get the current version information of GotyeAPI
 */
+(NSString*)getVersion;

@end
