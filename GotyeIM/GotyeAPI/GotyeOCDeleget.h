//
//  GotyeDelegetOC.h
//  GotyeAPI
//
//  Created by Peter on 14/12/4.
//  Copyright (c) 2014年 Ailiao Technologies. All rights reserved.
//

#ifndef GotyeAPI_GotyeDelegetOC_h
#define GotyeAPI_GotyeDelegetOC_h

#import "GotyeOCChatTarget.h"
#import "GotyeOCMessage.h"
#import "GotyeOCNotify.h"
#import "GotyeOCStatusCode.h"

@protocol GotyeOCDelegate <NSObject>

@optional

-(void) onLogin:(GotyeStatusCode)code user:(GotyeOCUser*)user;
-(void) onReconnecting:(GotyeStatusCode)code user:(GotyeOCUser*)user;
-(void) onLogout:(GotyeStatusCode)code;
-(void) onGetProfile:(GotyeStatusCode)code user:(GotyeOCUser*)user;

-(void) onGetUserDetail:(GotyeStatusCode)code user:(GotyeOCUser*)user;
-(void) onModifyUserInfo:(GotyeStatusCode)code user:(GotyeOCUser*)user;
-(void) onSearchUserList:(GotyeStatusCode)code pageIndex:(unsigned)pageIndex curPageList:(NSArray*)curPageList allList:(NSArray*) allList;
-(void) onGetFriendList:(GotyeStatusCode)code friendlist:(NSArray*)friendlist;
-(void) onGetBlockedList:(GotyeStatusCode)code blockedlist:(NSArray*)blockedlist;
-(void) onAddFriend:(GotyeStatusCode)code user:(GotyeOCUser*)user;
-(void) onAddBlocked:(GotyeStatusCode)code user:(GotyeOCUser*)user;
-(void) onRemoveFriend:(GotyeStatusCode)code user:(GotyeOCUser*)user;
-(void) onRemoveBlocked:(GotyeStatusCode)code user:(GotyeOCUser*)user;

-(void) onGetRoomList:(GotyeStatusCode)code pageIndex:(unsigned)pageIndex curPageRoomList:(NSArray*)curPageRoomList allRoomList:(NSArray*)allRoomList;
-(void) onEnterRoom:(GotyeStatusCode)code room:(GotyeOCRoom*)room;
-(void) onLeaveRoom:(GotyeStatusCode)code room:(GotyeOCRoom*)room;
-(void) onGetRoomMemberList:(GotyeStatusCode)code room:(GotyeOCRoom*)room pageIndex:(unsigned)pageIndex curPageMemberList:(NSArray*)curPageMemberList allMemberList:(NSArray*)allMemberList;

-(void) onSearchGroupList:(GotyeStatusCode)code pageIndex:(unsigned)pageIndex curPageList:(NSArray*) curPageList allList:(NSArray*)allList;
-(void) onCreateGroup:(GotyeStatusCode)code group:(GotyeOCGroup*)group;
-(void) onJoinGroup:(GotyeStatusCode)code group:(GotyeOCGroup*)group;
-(void) onLeaveGroup:(GotyeStatusCode)code group:(GotyeOCGroup*)group;
-(void) onDismissGroup:(GotyeStatusCode)code group:(GotyeOCGroup*)group;
-(void) onKickOutUser:(GotyeStatusCode)code group:(GotyeOCGroup*)group user:(GotyeOCUser*)user;
-(void) onChangeGroupOwner:(GotyeStatusCode)code group:(GotyeOCGroup*)group user:(GotyeOCUser*)user;
-(void) onGetGroupList:(GotyeStatusCode)code grouplist:(NSArray*)grouplist;
-(void) onGetGroupDetail:(GotyeStatusCode)code group:(GotyeOCGroup*)group;
-(void) onGetGroupMemberList:(GotyeStatusCode)code group:(GotyeOCGroup*)group pageIndex:(unsigned)pageIndex curPageMemberList:(NSArray*)curPageMemberList allMemberList:(NSArray*)allMemberList;
-(void) onModifyGroupInfo:(GotyeStatusCode)code group:(GotyeOCGroup*)group;
-(void) onReceiveNotify:(GotyeOCNotify*)notify;
-(void) onSendNotify:(GotyeStatusCode)code notify:(GotyeOCNotify*)notify;

-(void) onUserJoinGroup:(GotyeOCGroup*)group user:(GotyeOCUser*)user;
-(void) onUserLeaveGroup:(GotyeOCGroup*)group user:(GotyeOCUser*)user;
-(void) onUserDismissGroup:(GotyeOCGroup*)group user:(GotyeOCUser*)user;
-(void) onUserKickedFromGroup:(GotyeOCGroup*)group kicked:(GotyeOCUser*)kicked actor:(GotyeOCUser*)actor;

-(void) onSendMessage:(GotyeStatusCode)code message:(GotyeOCMessage*)message;
-(void) onDecodeMessage:(GotyeStatusCode)code message:(GotyeOCMessage*)message;
-(void) onReceiveMessage:(GotyeOCMessage*)message downloadMediaIfNeed:(bool*)need;
-(void) onDownloadMediaInMessage:(GotyeStatusCode)code message:(GotyeOCMessage*)message;

-(void) onGetMessageList:(GotyeStatusCode)code msglist:(NSArray*)msglist downloadMediaIfNeed:(bool*)downloadMediaIfNeed;

-(void) onReport:(GotyeStatusCode)code message:(GotyeOCMessage*)message;
-(void) onStartTalk:(GotyeStatusCode)code target:(GotyeOCChatTarget*)target realtime:(bool)realtime;
-(void) onStopTalk:(GotyeStatusCode)code realtime:(bool)realtime message:(GotyeOCMessage*)message cancelSending:(bool*)cancelSending;
-(void) onDownloadMedia:(GotyeStatusCode)code media:(GotyeOCMedia*)media;
-(void) onPlayStart:(GotyeStatusCode)code message:(GotyeOCMessage*)message;
-(void) onRealPlayStart:(GotyeStatusCode)code speaker:(GotyeOCUser*)speaker room:(GotyeOCRoom*)room;
-(void) onPlaying:(long)position;
-(void) onPlayStop;

@end

#endif
