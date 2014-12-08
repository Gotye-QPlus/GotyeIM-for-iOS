/****************************************************************************
 Copyright(c) 2013-2014, Shanghai AiLiao Information Technology Co.,Ltd

 http://www.gotye.com.cn
 
 @author:	liugan
 @date:		2014-06-20
 @version:	v3.0
 @filename:	Gotye.h
 @description:
 This header file provides the base class definition with all async callbacks.
 Include "GotyeAPI.h" instead of this.
****************************************************************************/

#ifndef __GOTYE_DELEGATE_H__
#define __GOTYE_DELEGATE_H__

#include "Gotye.h"
#include "GotyeMessage.h"
#include "GotyeNotify.h"
#include "GotyeStatusCode.h"

NS_GOTYEAPI_BEGIN

/**
 * @summary: collection of all async callbacks, inherit from 
 * this class and override callbacks which you are interested
 * in if you wanna listen the callbacks from GotyeAPI.
 * @note:
 * All callbacks are called on main thread.
 */
class GotyeDelegate
{
public:
    /**
     * @summary: callback response to GotyeAPI::login
     * @param code: status code
     * @param user: your account
     * @see GotyeStatusCode.h
     */
    virtual void onLogin(GotyeStatusCode code, const GotyeLoginUser& user) Optional;
    
    /**
     * @summary: notification when api gets the login user details.
     */
    virtual void onGetProfile(GotyeStatusCode code, const GotyeLoginUser& user) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::logout
     * @param code: status code, there are 2 possible values:
     * GotyeStatusCodeOK - logout normally
     * GotyeStatusCodeForceLogout - Your account is signing up on other devices.
     */
    virtual void onLogout(GotyeStatusCode code) Optional;

    /**
     * @summary: callback response to GotyeAPI::reqModifyUserInfo
     * @param user: your account detail information
     */
    virtual void onModifyUserInfo(GotyeStatusCode code, const GotyeLoginUser& user) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqSearchUserList
     */
    virtual void onSearchUserList(GotyeStatusCode code, unsigned pageIndex, const std::vector<GotyeUser>& curPageList, const std::vector<GotyeUser>& allList) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::getUserDetail
     * @param code: status code
     * @param user: user detail information for the account you passed to GotyeAPI.
     */
    virtual void onGetUserDetail(GotyeStatusCode code, const GotyeUser& user) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqFriendList
     */
    virtual void onGetFriendList(GotyeStatusCode code, const std::vector<GotyeUser>& friendlist) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqBlockedList
     */
    virtual void onGetBlockedList(GotyeStatusCode code, const std::vector<GotyeUser>& blockedlist) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqAddFriend
     */
    virtual void onAddFriend(GotyeStatusCode code, const GotyeUser& user) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqFriendList
     */
    virtual void onAddBlocked(GotyeStatusCode code, const GotyeUser& user) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqFriendList
     */
    virtual void onRemoveFriend(GotyeStatusCode code, const GotyeUser& user) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqFriendList
     */
    virtual void onRemoveBlocked(GotyeStatusCode code, const GotyeUser& user) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqRoomList
     * @param pageIndex: page index passed in GotyeAPI::reqRoomList
     * @param roomlist: room list you requested.
     */
    virtual void onGetRoomList(GotyeStatusCode code, unsigned pageIndex, const std::vector<GotyeRoom>& curPageRoomList, const std::vector<GotyeRoom>& allRoomList) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::enterRoom
     * @param room: passed in GotyeAPI::enterRoom
     * @param lastMsgID: the last message id in the room.
     */
    virtual void onEnterRoom(GotyeStatusCode code, GotyeRoom& room) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::leaveRoom
     * @param room: passed in GotyeAPI::leaveRoom
     */
    virtual void onLeaveRoom(GotyeStatusCode code, GotyeRoom& room) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqRoomUserList
     * @param room: the room passed in GotyeAPI::reqRoomUserList
     * @param pageIndex: page index passed in GotyeAPI::reqRoomUserList
     * @param userlist: member list you requested.
     */
    virtual void onGetRoomMemberList(GotyeStatusCode code, GotyeRoom& room, unsigned pageIndex, const std::vector<GotyeUser>& curPageMemberList, const std::vector<GotyeUser>& allMemberList) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqSearchGroup
     * @param group: passed in GotyeAPI::reqSearchGroup
     */
    virtual void onSearchGroupList(GotyeStatusCode code, unsigned pageIndex, const std::vector<GotyeGroup>& curPageList, const std::vector<GotyeGroup>& allList) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::createGroup
     * @param group: passed in GotyeAPI::createGroup
     */
    virtual void onCreateGroup(GotyeStatusCode code, const GotyeGroup& group) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::joinGroup
     * @param groupID: passed in GotyeAPI::joinGroup
     */
    virtual void onJoinGroup(GotyeStatusCode code, const GotyeGroup& group) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::leaveGroup
     * @param groupID: passed in GotyeAPI::leaveGroup
     */
    virtual void onLeaveGroup(GotyeStatusCode code, const GotyeGroup& group) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::dismissGroup
     * @param groupID: passed in GotyeAPI::dismissGroup
     */
    virtual void onDismissGroup(GotyeStatusCode code, const GotyeGroup& group) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::kickoutUser
     * @param groupID: passed in GotyeAPI::kickoutUser
     */
    virtual void onKickoutGroupMember(GotyeStatusCode code, const GotyeGroup& group, const GotyeUser& user) Optional;

	/**
	* @summary: callback response to GotyeAPI::changeGroupOwner
	* @param groupID: passed in GotyeAPI::changeGroupOwner
	*/
	virtual void onChangeGroupOwner(GotyeStatusCode code, const GotyeGroup& group, const GotyeUser& user) Optional;
    
    /**
     * @summary: notify when someone has joined in some group.
     */
    virtual void onUserJoinGroup(const GotyeGroup& group, const GotyeUser& user) Optional;
    
    /**
     * @summary: notify when someone has left  some group.
     */
    virtual void onUserLeaveGroup(const GotyeGroup& group, const GotyeUser& user) Optional;
    
    /**
     * @summary: notify when the group owner has dismissed some group.
     */
    virtual void onUserDismissGroup(const GotyeGroup& group, const GotyeUser& user) Optional;
    
    /**
     * @summary: notify when someone has been kicked out in some group.
     */
    virtual void onUserKickedFromGroup(const GotyeGroup& group, const GotyeUser& kicked, const GotyeUser& actor) Optional;

    /**
     * @summary: callback response to GotyeAPI::reqGroupList
     * @param pageIndex: page index passed in GotyeAPI::reqGroupList
     * @param grouplist: group list you requested.
     */
    virtual void onGetGroupList(GotyeStatusCode code, const std::vector<GotyeGroup>& grouplist) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqModifyGroupInfo
     */
    virtual void onModifyGroupInfo(GotyeStatusCode code, const GotyeGroup& group) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::getGroupDetail
     * @param code: status code
     * @param groupID: group detail information for the groupID you passed to GotyeAPI.
     */
    virtual void onGetGroupDetail(GotyeStatusCode code, const GotyeGroup& group) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::reqGroupMemberList
     * @param groupID: the group passed in GotyeAPI::reqGroupMemberList
     * @param pageIndex: page index passed in GotyeAPI::reqGroupMemberList
     * @param curPageMemberList: member list(current page) you requested.
     * @param allMemberList: all member list.
     */
    virtual void onGetGroupMemberList(GotyeStatusCode code, const GotyeGroup& group, unsigned pageIndex, const std::vector<GotyeUser>& curPageMemberList, const std::vector<GotyeUser>& allMemberList) Optional;

    
    virtual void onSendNotify(GotyeStatusCode code, const GotyeNotify &notify) Optional;
    
    /**
     * @summary: notification when rececive notify
     * @param notify: new arrived notify
     */
    virtual void onReceiveNotify(const GotyeNotify &notify) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::sendMessage
     * @param message: message passed in GotyeAPI::sendMessage
     */
    virtual void onSendMessage(GotyeStatusCode code, const GotyeMessage& message) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::decodeAudioMessage
     * @param message: message passed in GotyeAPI::sendMessage
     */
    virtual void onDecodeMessage(GotyeStatusCode code, const GotyeMessage& message) Optional;
    
    /**
     * @summary: notification for receiving message
     * @param message: new arrived message
     * @param downloadMediaIfNeed: let *downloadMediaInfNeed be true if you wanna
     * download media content in message automatically, default is false.
     */
    virtual void onReceiveMessage(const GotyeMessage& message, bool* downloadMediaIfNeed) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::report
     * @param message: message you wanna report
     */
    virtual void onReport(GotyeStatusCode code, const GotyeMessage& message) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::downloadMediaInMessage
     * @param message: media message passed in GotyeAPI::downloadMediaInMessage
     */
    virtual void onDownloadMediaInMessage(GotyeStatusCode code, const GotyeMessage& message) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::getMessageList
     * @param msglist: history/offline message list you requested.
     * @param downloadMediaIfNeed: let *downloadMediaIfNeed be true if you wanna download media contents for all messages
     * automatically, the default value is false.
     */
    virtual void onGetMessageList(GotyeStatusCode code, const std::vector<GotyeMessage>& msglist, bool* downloadMediaIfNeed) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::startTalk
     * @param target: with who.
     * @param realtime: realtime or not.
     */
    virtual void onStartTalk(GotyeStatusCode code, GotyeChatTarget target, bool realtime) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::stopTalk
     * @param message: the audio message api created for you(only for non-realtime)
     * @param cancelSending: let *cancelSending be true if you wanna cancel sending operation, default is
     * false, only for non-realtime.
     */
    virtual void onStopTalk(GotyeStatusCode code, bool realtime, const GotyeMessage& message, bool *cancelSending) Optional;
    
    /**
     * @summary: callback response to GotyeAPI::downloadMedia
     * @param media: passed in GotyeAPI::downloadMedia
     */
    virtual void onDownloadMedia(GotyeStatusCode code, GotyeMedia& media) Optional;
    
    /**
     * @summary: callback response to audio playback
     * @param realtime: the audio data playback is realtime or not.
     * @param source: if realtime is true, source represents a std::string pointer
     *  containing the userId who is currently talking; otherwise represents a
     *  GotyeMessage pointer which you passed into GotyeAPI::playMessage
     * @param room: valid only when realtime is true.
     */
    virtual void onPlayStart(GotyeStatusCode code, const GotyeMessage &message) Optional;
    
    /**
     * @summary: realtime playing start.
     * @param speaker: who is currently speaking.
     * @param room: in which room.
     */
    virtual void onRealPlayStart(GotyeStatusCode code, const GotyeUser& speaker, const GotyeRoom& room) Optional;
    
    /**
     * @summary: callback response to audio playback.
     * @param postion: current playing position(millisecond)
     */
    virtual void onPlaying(long position) Optional;
    
    /**
     * @summary: playback stopped
     */
    virtual void onPlayStop() Optional;
    
public:
    virtual ~GotyeDelegate(){}///<dtor
    
};

NS_GOTYEAPI_END

#endif/* defined(__GOTYE_DELEGATE_H__) */
