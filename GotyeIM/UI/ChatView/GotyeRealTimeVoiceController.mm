//
//  GotyeRealTimeVoiceController.m
//  GotyeIM
//
//  Created by Peter on 14-10-21.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeRealTimeVoiceController.h"
#import "GotyeDelegateManager.h"
#import "GotyeUIUtil.h"

#define IconSize        50
#define IconGap         10

@interface GotyeRealTimeVoiceController () <GotyeUIDelegate>

@end

@implementation GotyeRealTimeVoiceController

@synthesize scrollViewUsers, labelSpeaker, imageSpeaking;

- (id)initWithRoomID:(unsigned)ID talkingID:(NSString *)userID
{
    self = [self init];
    if(self)
    {
        roomID = ID;
        talkingUserID = userID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(talkingUserID != nil)
        labelSpeaker.text = [NSString stringWithFormat:@"%@正在说话", talkingUserID];
    
    imageSpeaking.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"chat_realtime_speak_1"],
                                     [UIImage imageNamed:@"chat_realtime_speak_2"],
                                     [UIImage imageNamed:@"chat_realtime_speak_3"], nil];
    imageSpeaking.animationDuration = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    delegateist->addDelegate(self);
    
    GotyeRoom room(roomID);
    apiist->reqRoomMemberList(room, 0);
}

- (void)viewWillDisappear:(BOOL)animated
{
    delegateist->removeDelegate(self);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)speakButtonDown:(id)sender
{
    GotyeRoom room(roomID);
    apiist->startTalk(room, GotyeWhineModeDefault, true);
}

-(IBAction)speakButtonUp:(id)sender
{
    apiist->stopTalk();
    
    [imageSpeaking stopAnimating];
}

- (void)resetHeadIcon:(NSInteger)headIconIndex
{
    UIButton *button = (UIButton*)[scrollViewUsers viewWithTag:headIconIndex + 1];
    GotyeUser user = roomUserlist[headIconIndex];
    
    UIImage *headImage = [GotyeUIUtil getHeadImage:NSStringUTF8(user.icon.path) defaultIcon:@"head_icon_user"];
    
    [button setBackgroundImage:headImage forState:UIControlStateNormal];
}

#pragma mark - Gotye UI delegates

- (void)onGetRoomMemberList:(GotyeStatusCode)code room:(gotyeapi::GotyeRoom)room pageIndex:(unsigned int)pageIndex curPageMemberList:(std::vector<GotyeUser>)curPageMemberList allMemberList:(std::vector<GotyeUser>)allMemberList
{
    roomUserlist = allMemberList;
    
    for(int i = 0; i<allMemberList.size(); i++)
    {
        GotyeUser user = allMemberList[i];
        
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(IconGap + (IconSize + IconGap) * i, IconGap, IconSize, IconSize)];
        button.tag = i + 1;
        
        [scrollViewUsers addSubview:button];
        
        [self resetHeadIcon:i];
    }
    
    scrollViewUsers.contentSize = CGSizeMake(roomUserlist.size() * (IconSize + IconGap) + IconGap, IconSize + IconGap * 2);
}

- (void)onStartTalk:(GotyeStatusCode)code target:(gotyeapi::GotyeChatTarget)target realtime:(bool)realtime
{
    if(realtime && code == GotyeStatusCodeOK)
    {
        labelSpeaker.text = [NSString stringWithFormat:@"%@正在说话", NSStringUTF8(apiist->getLoginUser().name)];
        [imageSpeaking startAnimating];
    }
}

- (void)onStopTalk:(GotyeStatusCode)code realtime:(bool)realtime message:(gotyeapi::GotyeMessage)message cancelSending:(bool *)cancelSending
{
    if(realtime)
    {
        talkingUserID = nil;
        labelSpeaker.text = @"";
        [imageSpeaking stopAnimating];
    }
}

- (void)onRealPlayStart:(GotyeStatusCode)code speaker:(gotyeapi::GotyeUser)speaker room:(gotyeapi::GotyeRoom)room
{
    talkingUserID = NSStringUTF8(speaker.name);
    
    labelSpeaker.text = [NSString stringWithFormat:@"%@正在说话", talkingUserID];
}

- (void)onPlayStop
{
    talkingUserID = nil;
    labelSpeaker.text = @"";
}

@end
