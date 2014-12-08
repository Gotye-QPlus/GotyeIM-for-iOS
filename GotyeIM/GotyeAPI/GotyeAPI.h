/****************************************************************************
 Copyright(c) 2013-2014, Shanghai AiLiao Information Technology Co.,Ltd

 http://www.gotye.com.cn
 
 @author:	liugan
 @date:		2014-06-20
 @version:	v3.0
 @filename:	GotyeAPI.h
 @description:
 This header file encapsulates almost all the interfaces into class GotyeAPI.
 Including only this is recommended while integrating.
****************************************************************************/

#ifndef __GOTYEAPI_H__
#define __GOTYEAPI_H__

#include <vector>
#include "GotyeDelegate.h"
#include "GotyeWhineMode.h"
#include "GotyeNotify.h"

NS_GOTYEAPI_BEGIN

/**
 * @summary: collection of basic interfaces
 * @note: calling interface on main thread is safe and recommended
 */
class GotyeAPI
{
    
public:
    
    /**
     * @summary: get the instance of GotyeAPI, using macro "apiist" instead.
     */
    static GotyeAPI* getInstance();
    
    /**
     * @summary: initialize api with appKey and packageName
     * @param appKey: your registered application key in Gotye ManagementSystem.
     * @param packageName: your application package name
     * @return: GotyeStatusCodeOK if succeeded, otherwise failure.
     */
    status init(const std::string& appKey, const std::string& packageName);
    
    /**
     * @summary: register PUSH Service, for iOS only.
     * @param deviceToken: your device token.
     * @param certName: your certificate name.
     * @return: GotyeStatusCodeOK if succeeded, otherwise failure.
     */
    bool registerAPNS(const std::string& deviceToken, const std::string& certName) IIOS;
    
    /**
     * @summary: enable/disable apple push service
     * @param enabled: true if your app need push service, otherwise false.
     * @return: GotyeStatusCodeOK if succeeded, otherwise failure.
     */
    bool enableAPNS(bool enabled) IIOS;
    
    /**
     * @summary: update the unread message count saved in Gotye IM server.
     * @param decrement: how many messages hava been marked as read.
     */
    void updateUnreadMessageDecrement(int decrement) IIOS;
    
    /**
     * @summary: clear cache files.
     */
    status clearCache();
    
    /**
     * @summary: set the instance of JavaVM, for Android only.
     * @param jvm: JavaVM pointer
     */
    void setJVM(void *jvm) IANDROID;
    
    /**
     * @summary: PLUG this loop into the loop of main thread
     * to listen aync callbacks from GotyeAPI.
     * @note: It's very IMPORTANT, otherwise you won't get
     * any async callback from GotyeAPI.
     */
    void mainLoop() IANDROID;

    /**
     * @summary: register/remove an async callback.
     */
    status removeAllListeners();
    status addListener(const GotyeDelegate& listener);
    status removeListener(const GotyeDelegate& listener);
    
    /**
     * @summary: sign in with username and password
     * @param username: the unique identifier of user
     * @param password: assign "nullptr" if no password
     * @return: GotyeStatusCodeWaitingCallback if succeeded, and the result will be passed via async callback
     * @callback: GotyeDelegate::onLogin
     */
    status login(const std::string& username, const std::string* password = nullptr);
    
    /**
     * @summary: get current online status.
     * @return: True if online, otherwise offline.
     */
    bool isOnline();
    
    /**
     * @summary: get current login user profile.
     */
    GotyeLoginUser& getLoginUser();
    
    /**
     * @summary: request modifying the user information of current account
     * @param user: login user.
     * @param imagePath: the fullpath of new head icon file, assign "nullptr" if you don't want to modify.
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onModifyUserInfo
     */
    status reqModifyUserInfo(GotyeUser &user, std::string* imagePath = nullptr);
    
    /**
     * @summary: logout
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onLogout
     */
    status logout();
    
    /**
     * @summary: init each user search after you changed the search keyword.
     * This interface will clear all datas in local user search result list and current page list.
     */
    void resetUserSearch();
    
    /**
     * @summary: return the reference of local user search result list.
     */
    const std::vector<GotyeUser>& getLocalUserSearchList();
    
    /**
     * @summary: return the reference of local user search result list(current page).
     */
    const std::vector<GotyeUser>& getLocalUserSearchCurPageList();
    
    /**
     * @summary: search users by keyword (username/nickname/gender)
     * @param pageIndex: index of search result(16 users per page)
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onSearchUserList
     */
    status reqSearchUserList(unsigned pageIndex = 0, const std::string& username = "", const std::string& nickname="", GotyeUserGender gender = SEX_IGNORE);
    
    /**
     * @summary: get the user detail information, this will sending a request if there is no cache information at local
     * or forceRequest is true.
     * @return: local detail information( if exists)
     * @callback: GotyeDelegate::onGetUserDetail
     */
    GotyeUser getUserDetail(const GotyeChatTarget& target, bool forceRequest = false);
    
    /**
     * @summary: get local friend list
     * @return: local friend list
     */
    const std::vector<GotyeUser>& getLocalFriendList();
    
    /**
     * @summary: get local blocked list
     * @return: local blocked list
     */
    const std::vector<GotyeUser>& getLocalBlockedList();
    
    /**
     * @summary:request friend list
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onGetFriendList
     */
    status reqFriendList();
    
    /**
     * @summary: request the blocked list from Gotye server.
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onGetBlockedList
     */
    status reqBlockedList();
    
    /**
     * @summary: add the specified friend to friend list.
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onAddFriend
     */
    status reqAddFriend(const GotyeUser& who);
    
    /**
     * @summary: add the specified user to blocked list.
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onAddBlocked
     */
    status reqAddBlocked(const GotyeUser& who);
    
    /**
     * @summary: remove the specified friend from friend list.
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onRemoveFriend
     */
    status reqRemoveFriend(const GotyeUser& who);
    
    /**
     * @summary: remove the specified user from blocked list.
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onRemoveBlocked
     */
    status reqRemoveBlocked(const GotyeUser& who);
    
    /**
     * @summary: request room list for pageIndex
     * @param pageIndex: page index, starts with 0
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onGetRoomList
     */
    status reqRoomList(unsigned pageIndex = 0);
    
    /**
     * @summary: get the local roomlist reference.
     */
    const std::vector<GotyeRoom>& getLocalRoomList();
    
    /**
     * @summary: clear local cached room list.
     */
    void clearLocalRoomList();
    
    /**
     * @summary: get room detail information.
     */
    GotyeRoom getRoomDetail(const GotyeChatTarget& target);
    
    /**
     * @summary: check if you are in the indicated room or not.
     * @param room: which room you wanna check
     * @return: true if you are in the room, false otherwise.
     */
    bool isInRoom(const GotyeRoom& room);
    
    /**
     * @summary: enter the indicated room.
     * @param room: which room
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onEnterRoom
     */
    status enterRoom(const GotyeRoom& room);
    
    /**
     * @summary: leave the indicated room.
     * @param room: which room
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onLeaveRoom
     */
    status leaveRoom(const GotyeRoom& room);
    
    /**
     * @summary: check if the indicated room supports realtime voice or not.
     */
    bool supportRealtime(const GotyeChatTarget& target);
    
    /**
     * @summary: request member list in indicated room with pageIndex
     * @param pageIndex: page index, starts with 0
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onGetRoomUserList
     */
    status reqRoomMemberList(const GotyeRoom& room, unsigned pageIndex);
    
    /**
     * @summary: init each group search after you changed the search keyword.
     * This interface will clear all datas in local group search result list and current page list.
     */
    void resetGroupSearch();
    
    /**
     * @summary: get the local reference of group search result list.
     */
    const std::vector<GotyeGroup>& getLocalGroupSearchList();
    
    /**
     * @summary: get the local reference of group search result list(current page).
     */
    const std::vector<GotyeGroup>& getLocalGroupSearchCurPageList();
    
    /**
     * @summary: search group by groupname.
     */
    status reqSearchGroup(const std::string& groupname, unsigned pageIndex);
    
    /**
     * @summary: get the group detail information.
     */
    GotyeGroup getGroupDetail(const GotyeChatTarget& target, bool forceRequest = false);
    
    /**
     * @summary: create group with some parameters.
     * @param group: base information of group to create.
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onCreateGroup
     */
    status createGroup(const GotyeGroup& group);
    
    /**
     * @summary: enter the indicated group.
     * @param group: which group
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onJoinGroup
     */
    status joinGroup(GotyeGroup& group);
    
    /**
     * @summary: leave the indicated group.
     * @param group: which group
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onLeaveGroup
     */
    status leaveGroup(GotyeGroup& group);
    
    /**
     * @summary: dismiss the indicated group.
     * @param group: which group
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onDismissGroup
     */
    status dismissGroup(GotyeGroup& group);
    
    /**
     * @summary: kickout specified user in group.
     * @param group: which group
     * @param username: which user to kick
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onKickoutGroupMember
     */
    status kickoutGroupMember(GotyeGroup& group, const GotyeUser& user);

	/**
	* @summary: change specified user to group owner.
	* @param group: which group
	* @param username: which user
	* @return: GotyeStatusCodeWaitingCallback if succeeded
	* @callback: GotyeDelegate::onChangeGroupOwner
	*/
	status changeGroupOwner(GotyeGroup& group, const GotyeUser& user);
    
    /**
     * @summary: get the local reference of group list.
     */
    const std::vector<GotyeGroup>& getLocalGroupList();

    /**
     * @summary: request the group list from server.
     * @callback: GotyeDelegate::onGetGroupList
     */
    status reqGroupList();
    
    /**
     * @summary: request modifing the indicated group.
     * @callback: GotyeDelegate::onModifyGroupInfo
     */
    status reqModifyGroupInfo(GotyeGroup &group, std::string *imagePath = nullptr);
    
    /**
     * @summary: request group user list in specified group for pageIndex
     * @param group: which group
     * @param pageIndex: page index, starts with 0
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onGetGroupMemberList
     */
    status reqGroupMemberList(GotyeGroup& group, unsigned pageIndex);
    
    /**
     * @summary: invite user to specified group
     * @param username: user to invite
     * @param group: which group
     * @param inviteMessage: message of invite
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onReceiveNotify when receive other's invite
     */
    status inviteUserToGroup(const GotyeUser& user,const GotyeGroup& group, const std::string& inviteMessage);
    
    /**
     * @summary: request joining the specified group
     * @param group: which group
     * @param applyMessage: message of apply
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onReceiveNotify when receive other's apply
     */
    status reqJoinGroup(const GotyeGroup& group, const std::string& applyMessage);

    /**
     * @summary: response apply to specified group
     * @param notify: apply notify
     * @param respMessage: message of response
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onReceiveNotify when receive response of your apply
     */
    status replyJoinGroup(const GotyeNotify& applyNotify, const std::string& respMessage, bool agree);

    /**
     * @summary: get the local session list.
     */
    const std::vector<GotyeChatTarget>& getSessionList();
    
    /**
     * @summary: active a session.
     */
    void activeSession(const GotyeChatTarget& target);
    
    /**
     * @summary: deactive a session
     */
    void deactiveSession(const GotyeChatTarget& target);
    
    /**
     * @summary: delete a session
     */
    void deleteSession(const GotyeChatTarget& target);
    
    /**
     * @summary: mark session as top, this will change the order of the indicated session to 1st.
     */
    void markSessionIsTop(const GotyeChatTarget& target, bool isTop);
    
    /**
     * @summary: get the detail session information with indicated target.
     * @param target: with who
     * @param messageList: get local message list pointer.
     * @param memberList: get local member list pointer with indicated target(validate for GotyeRoom or GotyeGroup).
     * @param curPageMemberList:  get local current page member list pointer with indicated target(validate for GotyeRoom or GotyeGroup).
     * @param pageIndex: get the current page index of member list.
     * @return: true when session is valid.
     */
    bool getSessionInfo(const GotyeChatTarget& target, std::vector<GotyeMessage> **messageList, std::vector<GotyeUser> **memberList = nullptr, std::vector<GotyeUser>** curPageMemberList = nullptr, unsigned *pageIndex = nullptr);
    
    /**
     * @summary: get the local notify list.
     */
    std::vector<GotyeNotify>& getNotifyList() const;
    
    /**
     * @summary: mark a notify as read/unread.
     */
    bool markNofityIsRead(const GotyeNotify& notify, bool isRead);
    
    /**
     * @summary: mark all notifies as read.
     */
    void clearNotifyUnreadStatus();
    
    /**
     * @summary: delete some notifies.
     */
    void deleteNotifys(const std::vector<GotyeNotify>& notifys);
    
    /**
     * @summary: delete the indicated notify.
     */
    void deleteNotify(const GotyeNotify& notify);
    
    /**
     * @summary: get unread notify count.
     */
    int getUnreadNotifyCount();
    
    /**
     * @summary: set the message increment for loading message from the local database, default is 10.
     */
    void setMessageReadIncrement(unsigned increment = DEFAULT_COUNT);
    
    /**
     * @summary: set the message increment for requesting message from the Gotye server, default is 10.
     */
    void setMessageRequestIncrement(unsigned increment = DEFAULT_COUNT);
    
    /**
     * @summary: begin receiving offline messages from server.
     */
    void beginReceiveOfflineMessage();
    
    /**
     * @summary: get the message list with indicated target.
     * @param target: with who
     * @param more: api will load more messages from database or server if more is true, otherwise not.
     */
    const std::vector<GotyeMessage>& getMessageList(const GotyeChatTarget& target, bool more = false);
    
    /**
     * @summary: mark all messages as read with indicated target.
     */
    void markMessagesAsRead(const GotyeChatTarget& target, bool isRead);
    
    /**
     * @summary: mark a message as read.
     */
    bool markOneMessageAsRead(const GotyeMessage& message, bool isRead);
    
    /**
     * @summary: delete messages with indicated target.
     */
    void deleteMessages(const GotyeChatTarget& target, const std::vector<GotyeMessage>& msglist);
    
    /**
     * @summary: delete message with indicated target.
     */
    void deleteMessage(const GotyeChatTarget& target, const GotyeMessage& msg);
    
    /**
     * @summary: clear all messages with indicated target.
     */
    void clearMessages(const GotyeChatTarget& target);
    
    /**
     * @summary: get the unread message count with indicated target.
     * @param target: with who
     */
    int getUnreadMessageCount(const GotyeChatTarget& target);
    
    /**
     * @summary: get the unread message count.
     */
    int getTotalUnreadMessageCount();
    
    /**
     * @summary: get unread message count of the indicated type list(GotyeChatTargetTypeUser/GotyeChatTargetTypeRoom/GotyeChatTargetTypeGroup)
     * @param types: type list
     * @return: message count
     */
    int getUnreadMessageCountOfTypes(std::vector<GotyeChatTargetType>& types);
    
    /**
     * @summary: get the last message with the indicated target
     * @param target: with who
     * @return: message object
     */
    GotyeMessage& getLastMessage(const GotyeChatTarget& target) const;
    
    /**
     * @summary: send message
     * @param message: message pointer
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onSendMessage
     */
    status sendMessage(GotyeMessage& message);
    
    /**
     * @summary: download media content(audio/image) in the indicated message.
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onDownloadMediaInMessage
     */
    status downloadMediaInMessage(GotyeMessage& message);
    
    /**
     * @summary: decode the amr file into a PCM file.
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onDecodeMessage
     */
    status decodeAudioMessage(const GotyeMessage& message);
    
    /**
     * @summary: report the indicated message
     * @param type: the type you have defined in gotye managementSystem
     * @param content: description of the message
     * @param message: which message you wanna report
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onReport
     */
    status report(int type, const std::string& content,const GotyeMessage& message);
    
    /**
     * @summary: play audio message
     * @return: GotyeStatusCodeOK if succeeded
     * @callback: GotyeDelegate::onPlayStart, GotyeDelegate::onPlaying, GotyeDelegate::onPlayStop
     */
    status playMessage(const GotyeMessage& message);
    
    /**
     * @summary: stop playing audio.
     * @return: GotyeStatusCodeOK if succeeded.
     */
    status stopPlay();
    
    /**
     * @summary: download media(audio/image).
     * @param media: media you want to download
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onDownloadMedia
     */
    status downloadMedia(const GotyeMedia& media);
    
    /**
     * @summary: start talk
     * @param target: with who
     * @param mode: whine mode
     * @param realtime: realtime or not.
     * @param maxDuration: maximum recording duration(millisecond,should <= 60000), default is 10000ms
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onStartTalk
     */
    status startTalk(const GotyeChatTarget& target, GotyeWhineMode mode = GotyeWhineModeDefault, bool realtime = false, unsigned maxDuration = REC_DEFAULTDURATION);
    
    /**
     * @summary: stop talk manually
     * @return: GotyeStatusCodeWaitingCallback if succeeded
     * @callback: GotyeDelegate::onStopTalk
     */
    status stopTalk();
    
    /**
     * @summary: get the current version information of GotyeAPI
     */
    std::string getVersion() const;

    
private:
    GotyeAPI(); ///<ctor
    virtual ~GotyeAPI();    ///<dtor
    
private:
    std::vector<GotyeFunc0> mCallbacks;
    std::vector<GotyeDelegate*> mListeners;

private:
    void enableInternalMainLoop(bool enable);
    void dispatchEvent(int eventCode, ...);
    void performOnMainThread(const GotyeFunction<void ()> &function);
    
};

NS_GOTYEAPI_END

#endif/* defined(__GOTYEAPI_H__) */
