//
//  GotyeDelegateManager.h
//  GotyeIM
//
//  Created by Peter on 14-10-13.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#include "GotyeAPI.h"

USING_NS_GOTYEAPI;

#define delegateist GotyeDelegateManager::getInstance()

@protocol GotyeUIDelegate <NSObject>

@optional

-(void) onLogin:(GotyeStatusCode)code user:(GotyeLoginUser)user;
-(void) onLogout:(GotyeStatusCode)code;
-(void) onGetProfile:(GotyeStatusCode)code user:(GotyeLoginUser)user;

-(void) onGetUserDetail:(GotyeStatusCode)code user:(GotyeUser)user;
-(void) onModifyUserInfo:(GotyeStatusCode)code user:(GotyeUser)user;
-(void) onSearchUserList:(GotyeStatusCode)code pageIndex:(unsigned)pageIndex curPageList:(std::vector<GotyeUser>)curPageList allList:(std::vector<GotyeUser>) allList;
-(void) onGetFriendList:(GotyeStatusCode)code friendlist:(std::vector<GotyeUser>)friendlist;
-(void) onGetBlockedList:(GotyeStatusCode)code blockedlist:(std::vector<GotyeUser>)blockedlist;
-(void) onAddFriend:(GotyeStatusCode)code user:(GotyeUser)user;
-(void) onAddBlocked:(GotyeStatusCode)code user:(GotyeUser)user;
-(void) onRemoveFriend:(GotyeStatusCode)code user:(GotyeUser)user;
-(void) onRemoveBlocked:(GotyeStatusCode)code user:(GotyeUser)user;

-(void) onGetRoomList:(GotyeStatusCode)code pageIndex:(unsigned)pageIndex curPageRoomList:(std::vector<GotyeRoom>)curPageRoomList allRoomList:(std::vector<GotyeRoom>)allRoomList;
-(void) onEnterRoom:(GotyeStatusCode)code room:(GotyeRoom)room;
-(void) onLeaveRoom:(GotyeStatusCode)code room:(GotyeRoom)room;
-(void) onGetRoomMemberList:(GotyeStatusCode)code room:(GotyeRoom)room pageIndex:(unsigned)pageIndex curPageMemberList:(std::vector<GotyeUser>)curPageMemberList allMemberList:(std::vector<GotyeUser>)allMemberList;

-(void) onSearchGroupList:(GotyeStatusCode)code pageIndex:(unsigned)pageIndex curPageList:(std::vector<GotyeGroup>) curPageList allList:(std::vector<GotyeGroup>)allList;
-(void) onCreateGroup:(GotyeStatusCode)code group:(GotyeGroup)group;
-(void) onJoinGroup:(GotyeStatusCode)code group:(GotyeGroup)group;
-(void) onLeaveGroup:(GotyeStatusCode)code group:(GotyeGroup)group;
-(void) onDismissGroup:(GotyeStatusCode)code group:(GotyeGroup)group;
-(void) onKickOutUser:(GotyeStatusCode)code group:(GotyeGroup)group user:(GotyeUser)user;
-(void) onChangeGroupOwner:(GotyeStatusCode)code group:(GotyeGroup)group user:(GotyeUser)user;
-(void) onGetGroupList:(GotyeStatusCode)code grouplist:(std::vector<GotyeGroup>)grouplist;
-(void) onGetGroupDetail:(GotyeStatusCode)code group:(GotyeGroup)group;
-(void) onGetGroupMemberList:(GotyeStatusCode)code group:(GotyeGroup)group pageIndex:(unsigned)pageIndex curPageMemberList:(std::vector<GotyeUser>)curPageMemberList allMemberList:(std::vector<GotyeUser>)allMemberList;
-(void) onModifyGroupInfo:(GotyeStatusCode)code group:(GotyeGroup)group;
-(void) onReceiveNotify:(GotyeNotify)notify;
-(void) onSendNotify:(GotyeStatusCode)code notify:(GotyeNotify)notify;

-(void) onUserJoinGroup:(GotyeGroup)group user:(GotyeUser)user;
-(void) onUserLeaveGroup:(GotyeGroup)group user:(GotyeUser)user;
-(void) onUserDismissGroup:(GotyeGroup)group user:(GotyeUser)user;
-(void) onUserKickedFromGroup:(GotyeGroup)group kicked:(GotyeUser)kicked actor:(GotyeUser)actor;

-(void) onSendMessage:(GotyeStatusCode)code message:(GotyeMessage)message;
-(void) onDecodeMessage:(GotyeStatusCode)code message:(GotyeMessage)message;
-(void) onReceiveMessage:(GotyeMessage)message downloadMediaIfNeed:(bool*)downloadMediaIfNeed;
-(void) onDownloadMediaInMessage:(GotyeStatusCode)code message:(GotyeMessage)message;

-(void) onGetMessageList:(GotyeStatusCode)code msglist:(std::vector<GotyeMessage>)msglist downloadMediaIfNeed:(bool*)downloadMediaIfNeed;

-(void) onReport:(GotyeStatusCode)code message:(GotyeMessage)message;
-(void) onStartTalk:(GotyeStatusCode)code target:(GotyeChatTarget)target realtime:(bool)realtime;
-(void) onStopTalk:(GotyeStatusCode)code realtime:(bool)realtime message:(GotyeMessage)message cancelSending:(bool*)cancelSending;
-(void) onDownloadMedia:(GotyeStatusCode)code media:(GotyeMedia)media;
-(void) onPlayStart:(GotyeStatusCode)code message:(GotyeMessage)message;
-(void) onRealPlayStart:(GotyeStatusCode)code speaker:(GotyeUser)speaker room:(GotyeRoom)room;
-(void) onPlaying:(long)position;
-(void) onPlayStop;

@end

class GotyeDelegateManager : public GotyeDelegate
{
public:
    static GotyeDelegateManager* getInstance();
    
    void addDelegate(id<GotyeUIDelegate> delegate);
    void removeDelegate(id<GotyeUIDelegate> delegate);
    void removeAllDelegate();
    
private:
    GotyeDelegateManager(); ///<ctor
    virtual ~GotyeDelegateManager(){};    ///<dtor
    
    virtual void onLogin(GotyeStatusCode code, const GotyeLoginUser& user);
    virtual void onLogout(GotyeStatusCode code) ;
    virtual void onGetProfile(GotyeStatusCode code, const GotyeLoginUser& user);
    
    virtual void onGetUserDetail(GotyeStatusCode code, const GotyeUser& user);
    virtual void onModifyUserInfo(GotyeStatusCode code, const GotyeLoginUser& user) ;
    virtual void onSearchUserList(GotyeStatusCode code, unsigned pageIndex, const std::vector<GotyeUser>& curPageList, const std::vector<GotyeUser>& allList);
    virtual void onGetFriendList(GotyeStatusCode code, const std::vector<GotyeUser>& friendlist);
    virtual void onGetBlockedList(GotyeStatusCode code, const std::vector<GotyeUser>& blockedlist);
    virtual void onAddFriend(GotyeStatusCode code, const GotyeUser& user);
    virtual void onAddBlocked(GotyeStatusCode code, const GotyeUser& user);
    virtual void onRemoveFriend(GotyeStatusCode code, const GotyeUser& user);
    virtual void onRemoveBlocked(GotyeStatusCode code, const GotyeUser& user);
    
    virtual void onGetRoomList(GotyeStatusCode code, unsigned pageIndex, const std::vector<GotyeRoom>& curPageRoomList, const std::vector<GotyeRoom>& allRoomList);
    virtual void onEnterRoom(GotyeStatusCode code, GotyeRoom& room) ;
    virtual void onLeaveRoom(GotyeStatusCode code, GotyeRoom& room) ;
    virtual void onGetRoomMemberList(GotyeStatusCode code, GotyeRoom& room, unsigned pageIndex, const std::vector<GotyeUser>& curPageMemberList, const std::vector<GotyeUser>& allMemberList);
    
    virtual void onSearchGroupList(GotyeStatusCode code, unsigned pageIndex, const std::vector<GotyeGroup>& curPageList, const std::vector<GotyeGroup>& allList);
    virtual void onCreateGroup(GotyeStatusCode code, const GotyeGroup& group);
    virtual void onJoinGroup(GotyeStatusCode code, const GotyeGroup& group);
    virtual void onLeaveGroup(GotyeStatusCode code, const GotyeGroup& group);
    virtual void onDismissGroup(GotyeStatusCode code, const GotyeGroup& group);
    virtual void onKickoutGroupMember(GotyeStatusCode code, const GotyeGroup& group, const GotyeUser& user);
	virtual void onChangeGroupOwner(GotyeStatusCode code, const GotyeGroup& group, const GotyeUser& user);
    virtual void onGetGroupList(GotyeStatusCode code, const std::vector<GotyeGroup>& grouplist) ;
    virtual void onGetGroupDetail(GotyeStatusCode code, const GotyeGroup& group);
    virtual void onGetGroupMemberList(GotyeStatusCode code, const GotyeGroup& group, unsigned pageIndex, const std::vector<GotyeUser>& curPageMemberList, const std::vector<GotyeUser>& allMemberList);
    virtual void onModifyGroupInfo(GotyeStatusCode code, const GotyeGroup& group);
    virtual void onSendNotify(GotyeStatusCode code, const GotyeNotify &notify);
    virtual void onReceiveNotify(const GotyeNotify &notify) ;
    
    virtual void onUserJoinGroup(const GotyeGroup& group, const GotyeUser& user);
    virtual void onUserLeaveGroup(const GotyeGroup& group, const GotyeUser& user);
    virtual void onUserDismissGroup(const GotyeGroup& group, const GotyeUser& user);
    virtual void onUserKickedFromGroup(const GotyeGroup& group, const GotyeUser& kicked, const GotyeUser& actor);

    virtual void onSendMessage(GotyeStatusCode code, const GotyeMessage& message);
    virtual void onDecodeMessage(GotyeStatusCode code, const GotyeMessage& message);
    virtual void onReceiveMessage(const GotyeMessage& message, bool* downloadMediaIfNeed);
    virtual void onDownloadMediaInMessage(GotyeStatusCode code, const GotyeMessage& message);
    
    virtual void onGetMessageList(GotyeStatusCode code, const std::vector<GotyeMessage>& msglist, bool* downloadMediaIfNeed);
    virtual void onReport(GotyeStatusCode code, const GotyeMessage& message);
    
    virtual void onStartTalk(GotyeStatusCode code, GotyeChatTarget target, bool realtime) ;
    virtual void onStopTalk(GotyeStatusCode code, bool realtime, const GotyeMessage& message, bool *cancelSending);
    virtual void onDownloadMedia(GotyeStatusCode code, GotyeMedia& media) ;
    virtual void onPlayStart(GotyeStatusCode code, const GotyeMessage &message);
    virtual void onRealPlayStart(GotyeStatusCode code, const GotyeUser& speaker, const GotyeRoom& room);
    virtual void onPlaying(long position);
    virtual void onPlayStop() ;
    
private:
    NSMutableArray *delegateArray;
};
