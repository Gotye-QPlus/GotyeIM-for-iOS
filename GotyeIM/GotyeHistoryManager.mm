//
//  GotyeHistoryManager.m
//  GotyeIM
//
//  Created by Peter on 14-10-14.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeHistoryManager.h"
#import "GotyeUIUtil.h"

#include "GotyeDelegateManager.h"

#define History_Dir             @"/history/"
#define History_OrderFile       @"order.plist"
#define History_TargetFile      @"target.plist"
#define History_FriendsFile     @"friends.plist"

static GotyeHistoryManager *_historyInstance = nil;

@interface GotyeHistoryManager () <GotyeUIDelegate>

@end

@implementation GotyeHistoryManager

+(instancetype)defaultManager
{
    if(_historyInstance == nil)
    {
        _historyInstance = [[self alloc] init];
    }
    
    return _historyInstance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        _historyDic = [NSMutableDictionary dictionary];
        _targetList = [NSMutableDictionary dictionary];

//        delegateist->addDelegate(self);
    }
    return self;
}

-(NSDictionary*)historyDictionary
{
    return _historyDic;
}

-(NSArray*)historyOrder
{
    return _historyOrder;
}

-(NSDictionary*)targetDictionary
{
    return _targetList;
}

-(NSMutableArray*)friendsArray
{
    return _friendsArray;
}

-(NSString*)historyDirectory
{
    return historyDir;
}

- (void)setLoginUserName:(NSString*)userName
{
    [_historyDic removeAllObjects];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    historyDir = [paths[0] stringByAppendingFormat:@"%@%@/", History_Dir, userName];
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:historyDir])
    {
        [manager createDirectoryAtPath:historyDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    else
    {
        NSArray *array = [manager contentsOfDirectoryAtPath:historyDir error:nil];
        for (NSString *filename in array) {
            if([[filename substringToIndex:8] isEqualToString:@"history_"])
            {
                NSString *path = [historyDir stringByAppendingString:filename];
                NSMutableDictionary *messageDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
                
                if(messageDictionary != nil)
                {
                    [_historyDic setObject:messageDictionary forKey:[filename substringToIndex:filename.length - 6]];
                }
            }
        }
        
        NSString *path = [historyDir stringByAppendingString:History_OrderFile];
        _historyOrder = [NSMutableArray arrayWithContentsOfFile:path];
        
        if(_historyOrder == nil)
            _historyOrder = [NSMutableArray array];
        
        path = [historyDir stringByAppendingString:History_TargetFile];
        _targetList = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        
        if(_targetList == nil)
            _targetList = [NSMutableDictionary dictionary];
        
        path = [historyDir stringByAppendingString:History_FriendsFile];
        _friendsArray = [NSMutableArray arrayWithContentsOfFile:path];
        
        if(_friendsArray == nil)
            _friendsArray = [NSMutableArray array];
    }
}

-(void)addHistory:(GotyeMessage*)message
{
    NSString *historyFile;
    NSString *targetID;
    
    NSString *selfID = NSStringUTF8(apiist->getLoginUser().name);
    
    switch (message->receiver.type) {
        case GotyeChatTargetTypeUser:
            targetID = NSStringUTF8(message->sender.name);
            if([targetID isEqualToString:selfID])
                targetID = NSStringUTF8(message->receiver.name);
            break;
            
        case GotyeChatTargetTypeGroup:
            targetID = [NSString stringWithFormat:@"%lld", message->receiver.id];
            break;
            
        case GotyeChatTargetTypeRoom:
            targetID = [NSString stringWithFormat:@"%lld", message->receiver.id];
            break;
            
        default:
            return;
            break;
    }
    
    historyFile = [NSString stringWithFormat:@"history_%d_%@", message->receiver.type, targetID];
    NSMutableDictionary *messageDictionary = _historyDic[historyFile];
    
    if(messageDictionary == nil)
    {
        messageDictionary = [NSMutableDictionary dictionary];
        [messageDictionary setObject:[NSNumber numberWithInt:message->receiver.type] forKey:History_key_type];
        [messageDictionary setObject:targetID forKey:History_key_ID];
        [messageDictionary setObject:[NSMutableArray array] forKey:History_key_Content];
        
        [_historyDic setObject:messageDictionary forKey:historyFile];
    }
    
    NSMutableArray *messageArray = messageDictionary[History_key_Content];
    
    if(messageArray.count > 0)
    {
        NSDictionary *lastmessage = messageArray[messageArray.count - 1];
        long long lastID = [lastmessage[Message_key_ID] longLongValue];
        if(lastID >= message->id)
            return;
    }
    
    [messageArray addObject:[self convertMessageToDictionary:message]];
    
    NSString *historyPath = [historyDir stringByAppendingFormat:@"%@.plist", historyFile];
    [messageDictionary writeToFile:historyPath atomically:YES];
    
    if([_historyOrder containsObject:historyFile])
        [_historyOrder removeObject:historyFile];
    
    [_historyOrder insertObject:historyFile atIndex:0];
    
    NSString *orderPath = [historyDir stringByAppendingString:History_OrderFile];
    [_historyOrder writeToFile:orderPath atomically:YES];
}

-(NSDictionary*)convertMessageToDictionary:(GotyeMessage*)message
{
    NSNumber *msgID = [NSNumber numberWithLongLong:message->id];
    NSNumber *msgType = [NSNumber numberWithLongLong:message->type];
    NSNumber *msgRead = [NSNumber numberWithBool:NO];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    
    NSString *msgDate = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:message->date]];
    
    NSMutableDictionary *retDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   msgID, Message_key_ID,
                                   msgType, Message_key_Type,
                                   msgRead, Message_key_Read,
                                   msgDate, Message_key_Date, nil];
    
    
    switch (message->type) {
        case GotyeMessageTypeText:
            [retDic setObject:NSStringUTF8(message->text) forKey:Message_key_Content];
            break;
            
        case GotyeMessageTypeAudio:
            [retDic setObject:[NSNumber numberWithInteger:message->media.duration] forKey:Message_key_Duration];
            [retDic setObject:NSStringUTF8(message->media.path) forKey:Message_key_Content];
            break;
            
        case GotyeMessageTypeImage:
            [retDic setObject:NSStringUTF8(message->media.path) forKey:Message_key_Content];
            [retDic setObject:NSStringUTF8(message->media.pathEx) forKey:Message_key_ContentEx];
            break;
            
        default:
            break;
    }
    
    switch (message->sender.type) {
        case GotyeChatTargetTypeUser:
            [retDic setObject:NSStringUTF8(message->sender.name) forKey:Message_key_Sender];
            break;
            
        case GotyeChatTargetTypeGroup:
        case GotyeChatTargetTypeRoom:
            [retDic setObject:[NSString stringWithFormat:@"%lld", message->sender.id] forKey:Message_key_Sender];
            break;
            
        default:
            break;
    }
    
    return retDic;
}

- (void)setMessagesRead:(NSString *)historyKey
{
    NSMutableDictionary *messageDictionary = _historyDic[historyKey];
    
    if(messageDictionary == nil)
        return;
    
    NSMutableArray *messageArray = messageDictionary[History_key_Content];
    
    if(messageArray == nil)
        return;

    for(NSMutableDictionary *dic in messageArray)
        [dic setObject:[NSNumber numberWithBool:YES] forKey:Message_key_Read];
    
    NSString *historyPath = [historyDir stringByAppendingFormat:@"%@.plist", historyKey];
    [messageDictionary writeToFile:historyPath atomically:YES];
}

-(void)removeMessage:(NSString*)historyKey
{
    NSString *historyPath = [historyDir stringByAppendingFormat:@"%@.plist", historyKey];
    [[NSFileManager defaultManager] removeItemAtPath:historyPath error:nil];
    
    [_historyDic removeObjectForKey:historyKey];
    [_historyOrder removeObject:historyKey];
    
    NSString *orderPath = [historyDir stringByAppendingString:History_OrderFile];
    [_historyOrder writeToFile:orderPath atomically:YES];
}

- (void)addGroupInviteHistory:(gotyeapi::GotyeGroup)group sender:(std::string)sender message:(std::string)message
{
    NSNumber *groupID = [NSNumber numberWithLongLong:group.id];
    NSString *groupName = NSStringUTF8(group.name);
    NSString *senderName = NSStringUTF8(sender);
    NSString *content = NSStringUTF8(message);
    NSNumber *msgRead = [NSNumber numberWithBool:NO];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         groupID, Message_key_ID,
                         groupName, Message_key_Type,
                         content, Message_key_Content,
                         senderName, Message_key_Sender,
                         msgRead, Message_key_Read, nil];
    
    
    NSString * historyFile = @"history_invite_group";
    NSMutableDictionary *messageDictionary = _historyDic[historyFile];
    
    if(messageDictionary == nil)
    {
        messageDictionary = [NSMutableDictionary dictionary];
        [messageDictionary setObject:[NSNumber numberWithInt:3] forKey:History_key_type];
        [messageDictionary setObject:[NSMutableArray array] forKey:History_key_Content];
        
        [_historyDic setObject:messageDictionary forKey:historyFile];
    }
    
    NSMutableArray *messageArray = messageDictionary[History_key_Content];
    [messageArray addObject:dic];
    
    NSString *historyPath = [historyDir stringByAppendingFormat:@"%@.plist", historyFile];
    [messageDictionary writeToFile:historyPath atomically:YES];
    
    if([_historyOrder containsObject:historyFile])
        [_historyOrder removeObject:historyFile];
    
    [_historyOrder insertObject:historyFile atIndex:0];
    
    NSString *orderPath = [historyDir stringByAppendingString:History_OrderFile];
    [_historyOrder writeToFile:orderPath atomically:YES];
}

- (void)removeInviteMessage:(NSInteger)index
{
    NSString * historyFile = @"history_invite_group";
    NSMutableDictionary *messageDictionary = _historyDic[historyFile];
    
    NSMutableArray *messageArray = messageDictionary[History_key_Content];
    
    if(index >= messageArray.count)
        return;
    
    [messageArray removeObjectAtIndex:index];
    NSString *historyPath = [historyDir stringByAppendingFormat:@"%@.plist", historyFile];
    [messageDictionary writeToFile:historyPath atomically:YES];
    
    if(messageArray.count == 0)
        [_historyOrder removeObject:historyFile];
    NSString *orderPath = [historyDir stringByAppendingString:History_OrderFile];
    [_historyOrder writeToFile:orderPath atomically:YES];
}

-(void)saveTarget:(GotyeChatTarget*)target
{
    NSString *key;
    
    NSNumber *TargetID = [NSNumber numberWithLongLong:target->id];
    NSNumber *TargetType = [NSNumber numberWithInt:target->type];
    NSString *TargetName = NSStringUTF8(target->name);
    NSString *TargetIconURL = NSStringUTF8(target->icon.url);
    NSString *TargetIconPath = NSStringUTF8(target->icon.path);
    
    NSMutableDictionary *dictinary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               TargetID, Target_key_ID,
                               TargetType, Target_key_Type,
                               TargetName, Target_key_Name,
                               TargetIconURL, Target_key_IconURL,
                               TargetIconPath, Target_key_IconPath, nil];

    switch (target->type) {
        case gotyeapi::GotyeChatTargetTypeUser:
            key = [NSString stringWithFormat:@"User_%@", NSStringUTF8(target->name)];
            break;
        case gotyeapi::GotyeChatTargetTypeGroup:
            key = [NSString stringWithFormat:@"Group_%lld", target->id];
            [dictinary setObject:NSStringUTF8(((GotyeGroup*)target)->ownerAccount) forKey:Target_key_GroupOwner];
            break;
        case gotyeapi::GotyeChatTargetTypeRoom:
            key = [NSString stringWithFormat:@"Room_%lld", target->id];
            break;
        default:
            return;
            break;
    }
    
    [_targetList setObject:dictinary forKey:key];
    
    NSString *historyPath = [historyDir stringByAppendingString:History_TargetFile];
    [_targetList writeToFile:historyPath atomically:YES];
}

-(BOOL)addFriends:(NSString*)userName
{
    [_friendsArray addObject:userName];
    
    NSString *friendsPath = [historyDir stringByAppendingString:History_FriendsFile];
    [_friendsArray writeToFile:friendsPath atomically:YES];
    
    return YES;
}

- (void)removeFriend:(NSString*)username
{
    [_friendsArray removeObject:username];
    
    NSString *friendsPath = [historyDir stringByAppendingString:History_FriendsFile];
    [_friendsArray writeToFile:friendsPath atomically:YES];
}

#pragma mark - Gotye UI delegates

-(void)onReceiveMessage:(gotyeapi::GotyeMessage *)message downloadMediaIfNeed:(bool *)downloadMediaIfNeed
{
    [self addHistory:message];
    
    *downloadMediaIfNeed = true;
}

-(void)onReceiveGroupInvite:(gotyeapi::GotyeGroup)group sender:(std::string)sender message:(std::string)message
{
    [self addGroupInviteHistory:group sender:sender message:message];
}

-(void)onSendMessage:(GotyeStatusCode)code message:(gotyeapi::GotyeMessage *)message
{
    if(code == GotyeStatusCodeOK && message->type < GotyeMessageTypeInviteGroup)
    {
        [self addHistory:message];
    }
}

- (void)onGetOfflineMessageList:(GotyeStatusCode)code msglist:(std::vector<GotyeMessage *>)msglist downloadMediaIfNeed:(bool *)downloadMediaIfNeed
{
    for(int i = msglist.size() - 1; i>=0; i--)
    {
        GotyeMessage* message = msglist[i];
        
        [self addHistory:message];
    }

    *downloadMediaIfNeed = true;
}

- (void)onGetHistoryMessageList:(GotyeStatusCode)code msglist:(std::vector<GotyeMessage *>)msglist downloadMediaIfNeed:(bool *)downloadMediaIfNeed
{
    for(int i = msglist.size() - 1; i>=0; i--)
    {
        GotyeMessage* message = msglist[i];
        
        [self addHistory:message];
    }

    *downloadMediaIfNeed = true;
}

-(void)onGetUserInfo:(GotyeStatusCode)code user:(gotyeapi::GotyeUser)user
{
    apiist->downloadMedia(user.icon);
    
    [self saveTarget:&user];
}

-(void)onGetGroupInfo:(GotyeStatusCode)code group:(gotyeapi::GotyeGroup)group
{
    [self saveTarget:&group];
}

-(void)onGetRoomList:(GotyeStatusCode)code pageIndex:(unsigned int)pageIndex roomlist:(std::vector<GotyeRoom>)roomlist
{
//    for(GotyeRoom room: roomlist){
//        apiist->downloadMedia(room->icon);
//        
//        [self saveTarget:room];
//    }
}

-(void)onGetGroupList:(GotyeStatusCode)code pageIndex:(unsigned int)pageIndex grouplist:(std::vector<GotyeGroup *>)grouplist
{
    for(GotyeGroup* group: grouplist){
        [self saveTarget:group];
    }
}

-(void)onGetRoomUserList:(GotyeStatusCode)code room:(gotyeapi::GotyeRoom)room pageIndex:(unsigned int)pageIndex curPageMemberList:(std::vector<GotyeUser>)curPageMemberList allMemberList:(std::vector<GotyeUser>)allMemberList
{
//    for(std::string username: userlist){
//        apiist->reqUserInfo(username);
//    }
//    apiist->reqUserDetailList(allMemberList);
}

-(void)onGetGroupUserList:(GotyeStatusCode)code groupID:(long long)groupID pageIndex:(unsigned int)pageIndex userlist:(std::vector<std::string>)userlist
{
    for(std::string username: userlist){
//        apiist->reqUserInfo(username);
    }
}

@end
