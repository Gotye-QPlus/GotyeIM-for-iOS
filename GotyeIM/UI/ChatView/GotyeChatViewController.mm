//
//  GotyeChatViewController.m
//  GotyeIM
//
//  Created by Peter on 14-10-16.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeChatViewController.h"

#import "GotyeUIUtil.h"

#import "GotyeChatBubbleView.h"

#import "GotyeLoadingView.h"
#import "GotyeDelegateManager.h"
#import "GotyeSettingManager.h"

#import "GotyeGroupSettingController.h"
#import "GotyeChatRoomSettingController.h"
#import "GotyeRealTimeVoiceController.h"
#import "GotyeUserInfoController.h"

@interface GotyeChatViewController () <GotyeUIDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    GotyeChatTarget chatTarget;
    
    NSString *talkingUserID;
    
    NSInteger playingRow;
    
    CGFloat keyboardHeight;
    CGFloat chatViewOriginY;
    
    UIButton *largeImageView;
    
    const std::vector<GotyeMessage> *messageList;
    
    GotyeLoadingView *loadingView;
    BOOL haveMoreData;
    NSString *tempImagePath;
}

@end

@implementation GotyeChatViewController

@synthesize chatView, inputView, buttonVoice, buttonWrite, realtimeStartView, labelRealTimeStart, textInput, buttonRealTime;

- (id)initWithTarget:(gotyeapi::GotyeChatTarget)target
{
    self = [self init];
    if(self)
    {
        chatTarget = target;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    switch (chatTarget.type) {
        case GotyeChatTargetTypeUser:
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithImage:[UIImage imageNamed:@"nav_button_user"]
                                                      style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(targetUserClick:)];
            
            GotyeUser user = apiist->getUserDetail(chatTarget);
            self.navigationItem.title = NSStringUTF8(user.name);
        }
            break;
            
        case GotyeChatTargetTypeGroup:
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithImage:[UIImage imageNamed:@"nav_button_user"]
                                                      style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(groupSettingClick:)];
            
            GotyeGroup group = apiist->getGroupDetail(chatTarget);
            self.navigationItem.title = NSStringUTF8(group.name);
        }
            break;
            
        case GotyeChatTargetTypeRoom:
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithImage:[UIImage imageNamed:@"nav_button_user"]
                                                      style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(roomSettingClick:)];
            
            GotyeRoom room = apiist->getRoomDetail(chatTarget);
            self.navigationItem.title = NSStringUTF8(room.name);
        }
            break;
    }
    
    messageList = &apiist->getMessageList(chatTarget, chatTarget.type==GotyeChatTargetTypeRoom);
    
    loadingView = [[GotyeLoadingView alloc] init];
    loadingView.hidden = YES;
    haveMoreData = YES;
}

- (void)reloadHistorys:(BOOL)scrollToEnd
{
    playingRow = -1;
    [self.tableView reloadData];
    
    if(messageList->size() > 0 && scrollToEnd)
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageList->size() - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view addSubview:chatView];
    if(self.isMovingToParentViewController)
    {
        chatView.frame = CGRectMake(0, self.view.frame.size.height - 50, 320, 150);
        self.tableView.frame = CGRectMake(0, 0, 320, chatView.frame.origin.y);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitChatProcesses) name:popToRootViewControllerNotification object:nil];
    }
    
    delegateist->addDelegate(self);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    apiist->activeSession(chatTarget);
    
    [self reloadHistorys:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(self.isMovingFromParentViewController)
    {
        [self exitChatProcesses];
    }
}

- (void)exitChatProcesses
{
    apiist->stopPlay();
    
    delegateist->removeDelegate(self);
    
    apiist->deactiveSession(chatTarget);
    if(chatTarget.type == GotyeChatTargetTypeRoom)
    {
        GotyeRoom room = GotyeRoom((unsigned)chatTarget.id);
        apiist->leaveRoom(room);
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) keyboardWillShown:(NSNotification*)notify
{
    if(chatViewOriginY == 0)
        chatViewOriginY = chatView.frame.origin.y;
    
    [self moveTextViewForKeyBoard:notify up:YES];
}

- (void) keyboardWillHidden:(NSNotification*)notify
{
    [self moveTextViewForKeyBoard:notify up:NO];
    
    keyboardHeight = 0;
    chatViewOriginY = 0;
}

- (void) moveTextViewForKeyBoard:(NSNotification*)notify up:(BOOL)up
{
    NSDictionary *userInfo = [notify userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    keyboardHeight = keyboardEndFrame.size.height;
    
    if(animationDuration > 0)
    {
        // Animate up or down
        [UIView beginAnimations:@"contentMove" context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    
    CGRect newFrame = chatView.frame;
    
    if(!up)
        newFrame.origin.y = chatViewOriginY;
    else
    {
        newFrame.origin.y = self.view.frame.size.height - keyboardHeight - 50;
    }
    
    chatView.frame = newFrame;
    
    if(animationDuration > 0)
    {
        [UIView commitAnimations];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendClick:(UITextField *)sender
{
    [sender resignFirstResponder];
    
    GotyeMessage msg = GotyeMessage::createTextMessage(chatTarget, STDStringUTF8(sender.text));
    msg.putExtraData((void*)"hello", 5);
    apiist->sendMessage(msg);
    
    sender.text = @"";
    
    [self reloadHistorys:YES];
}

- (IBAction)voiceButtonClick:(id)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    buttonWrite.alpha = 1;
    buttonVoice.alpha = 0;
    inputView.frame = CGRectMake(inputView.frame.origin.x, -50, 320, 100);
    
    [UIView commitAnimations];
    
    [textInput resignFirstResponder];
}

- (IBAction)writeButtonClick:(id)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    buttonWrite.alpha = 0;
    buttonVoice.alpha = 1;
    inputView.frame = CGRectMake(inputView.frame.origin.x, 0, 320, 100);
    
    [UIView commitAnimations];
}

- (IBAction)addButtonClick:(id)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    CGRect frame = chatView.frame;
    
    if(frame.origin.y < self.view.frame.size.height - 50)
        frame.origin.y = self.view.frame.size.height - 50;
    else
        frame.origin.y = self.view.frame.size.height - frame.size.height;
    
    chatView.frame =frame;
    self.tableView.frame = CGRectMake(0, 0, 320, chatView.frame.origin.y);
    
    [UIView commitAnimations];
    
    buttonRealTime.hidden = !apiist->supportRealtime(chatTarget);
    
    [textInput resignFirstResponder];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *jpgTempImage = [GotyeUIUtil ConpressImageToJPEGData:image maxSize:ImageFileSizeMax];
    tempImagePath = [[GotyeSettingManager defaultManager].settingDirectory stringByAppendingString:@"temp.jpg"];
    [jpgTempImage writeToFile:tempImagePath atomically:YES];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    std::string path = STDStringUTF8(tempImagePath);
    GotyeMessage msg = GotyeMessage::createImageMessage(chatTarget, path);
    apiist->sendMessage(msg);
    [self reloadHistorys:YES];
}

- (IBAction)albumClick:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)cameraButtonClick:(id)sender
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.delegate = self;
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing = YES;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (IBAction)realtimeClick:(id)sender
{
    if(chatTarget.type == GotyeChatTargetTypeRoom && apiist->supportRealtime(chatTarget))
    {
        GotyeRealTimeVoiceController *viewController = [[GotyeRealTimeVoiceController alloc] initWithRoomID:(unsigned)chatTarget.id talkingID:talkingUserID];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

-(IBAction)speakButtonDown:(id)sender
{
    apiist->startTalk(chatTarget);
}

-(IBAction)speakButtonUp:(id)sender
{
    apiist->stopTalk();
    
    [self reloadHistorys:YES];
}

-(void)messageClick:(UIButton*)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    GotyeMessage message = (*messageList)[indexPath.row];
    
    switch (message.type) {
        case GotyeMessageTypeAudio:
        {
            if(playingRow == button.tag)
            {
                apiist->stopPlay();
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                UIImageView *voiceImage = (UIImageView*)[cell viewWithTag:bubblePlayImageTag];
                [voiceImage stopAnimating];
                playingRow = -1;
            }
            else
            {
                if(message.media.status!=GotyeMediaStatusDownloading && ![[NSFileManager defaultManager] fileExistsAtPath:NSStringUTF8(message.media.path)])
                {
                    apiist->downloadMediaInMessage(message);
                    [self reloadHistorys:NO];
                    break;
                }
                
                status s = apiist->playMessage(message);
                if(s == GotyeStatusCodeOK)
                {
                    [self onPlayStop];
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    UIImageView *voiceImage = (UIImageView*)[cell viewWithTag:bubblePlayImageTag];
                    [voiceImage startAnimating];
                    playingRow = indexPath.row;
                }
            }
        }
            break;
            
        case GotyeMessageTypeImage:
        {
            if(largeImageView!=nil)
                break;
            
            if(message.media.status!=GotyeMediaStatusDownloading && ![[NSFileManager defaultManager] fileExistsAtPath:NSStringUTF8(message.media.pathEx)])
            {
                apiist->downloadMediaInMessage(message);
                [self reloadHistorys:NO];
                break;
            }

            UIImage *image = [UIImage imageWithContentsOfFile:NSStringUTF8(message.media.pathEx)];
            
            if(image != nil)
            {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                UIImageView *thumbImageView = (UIImageView*)[cell viewWithTag:bubbleThumbImageTag];
                CGPoint transCenter = [thumbImageView.superview convertPoint:thumbImageView.center toView:self.view];
                
                largeImageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                [largeImageView addTarget:self action:@selector(largeImageClose:) forControlEvents:UIControlEventTouchUpInside];
                
                CGSize imgSize = CGSizeMake(image.size.width / 2, image.size.height / 2);
                if(imgSize.width > self.view.frame.size.width)
                {
                    imgSize.height = self.view.frame.size.width * imgSize.height / imgSize.width;
                    imgSize.width = self.view.frame.size.width;
                }
                if(imgSize.height > self.view.frame.size.height)
                {
                    imgSize.width = self.view.frame.size.height * imgSize.width / imgSize.height;
                    imgSize.height = self.view.frame.size.height;
                }
                image = [GotyeUIUtil scaleImage:image toSize:CGSizeMake(imgSize.width*2, imgSize.height*2)];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgSize.width, imgSize.height)];
//                imageView.contentMode = UIViewContentModeScaleAspectFit;
                imageView.image = image;
                imageView.center = largeImageView.center;
                
                [largeImageView addSubview:imageView];
                [self.view addSubview:largeImageView];
                
                CGAffineTransform transform = CGAffineTransformMakeTranslation(transCenter.x - imageView.center.x, transCenter.y - imageView.center.y);
                transform = CGAffineTransformScale(transform, thumbImageView.frame.size.width / imageView.frame.size.width, thumbImageView.frame.size.height / imageView.frame.size.height);
                
                largeImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                imageView.transform = transform;
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                
                largeImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
                imageView.transform = CGAffineTransformIdentity;
                
                [UIView commitAnimations];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)largeImageClose:(id)sender
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         largeImageView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if (finished){
                             [largeImageView removeFromSuperview];
                             largeImageView = nil;
                         }
                     }
     ];
}

- (void)groupSettingClick:(id)sender
{
    GotyeGroupSettingController *viewController = [[GotyeGroupSettingController alloc] initWithTarget:apiist->getGroupDetail(chatTarget)];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)roomSettingClick:(id)sender
{
    GotyeChatRoomSettingController *viewController = [[GotyeChatRoomSettingController alloc] initWithTarget:apiist->getRoomDetail(chatTarget)];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)targetUserClick:(id)sender
{
    GotyeUserInfoController *viewController = [[GotyeUserInfoController alloc] initWithTarget:apiist->getUserDetail(chatTarget) groupID:0];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)userClick:(UIButton*)sender
{
    GotyeMessage message = (*messageList)[sender.tag];
    
    GotyeUserInfoController *viewController = [[GotyeUserInfoController alloc] initWithTarget:apiist->getUserDetail(message.sender) groupID:0];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(loadingView.hidden && scrollView.contentOffset.y < -20)
    {
        loadingView.frame = CGRectMake(0, -40, 320, 40);
        [scrollView insertSubview:loadingView atIndex:0];
        loadingView.hidden = NO;
        [loadingView showLoading:haveMoreData];
        
        if(haveMoreData)
        {
            NSInteger lastCount = messageList->size();
            apiist->getMessageList(chatTarget, true);
            if(chatTarget.type != GotyeChatTargetTypeRoom)
            {
                if(lastCount == messageList->size())
                {
                    haveMoreData = NO;
                    [loadingView showLoading:haveMoreData];
                }
                else
                {
                    CGFloat lastOffsetY = self.tableView.contentOffset.y;
                    CGFloat lastContentHeight = self.tableView.contentSize.height;

                    loadingView.hidden = YES;
                    [self reloadHistorys:NO];
                    
                    CGFloat newOffsetY = self.tableView.contentSize.height - lastContentHeight + lastOffsetY;
                    
                    [self.tableView scrollRectToVisible:CGRectMake(0, newOffsetY, ScreenHeight, self.tableView.frame.size.height) animated:NO];
                }
            }
        }
    }

}

#pragma mark - Gotye UI delegates

- (void)onSendMessage:(GotyeStatusCode)code message:(gotyeapi::GotyeMessage)message
{

    [self reloadHistorys:NO];
    
    if(message.type == GotyeMessageTypeImage)
    {
        [[NSFileManager defaultManager] removeItemAtPath:tempImagePath  error:nil];
        tempImagePath = nil;
    }
}

- (void)onReceiveMessage:(gotyeapi::GotyeMessage)message downloadMediaIfNeed:(bool *)downloadMediaIfNeed
{
    [self reloadHistorys:YES];
    
    *downloadMediaIfNeed = true;
}

- (void)onGetMessageList:(GotyeStatusCode)code msglist:(std::vector<GotyeMessage>)msglist downloadMediaIfNeed:(bool *)downloadMediaIfNeed
{
    if(chatTarget.type == GotyeChatTargetTypeRoom)
    {
        CGFloat lastOffsetY = self.tableView.contentOffset.y;
        CGFloat lastContentHeight = self.tableView.contentSize.height;
        
        [self reloadHistorys:NO];
        
        CGFloat newOffsetY = self.tableView.contentSize.height - lastContentHeight + lastOffsetY;
        
        [self.tableView scrollRectToVisible:CGRectMake(0, newOffsetY, ScreenHeight, self.tableView.frame.size.height) animated:NO];
    }
    
     *downloadMediaIfNeed = true;
    
    loadingView.hidden = YES;
    haveMoreData = (msglist.size() > 0);
}

- (void)onDownloadMediaInMessage:(GotyeStatusCode)code message:(gotyeapi::GotyeMessage)message
{
    [self reloadHistorys:NO];
}

- (void)onPlayStop
{
    for(UITableViewCell* cell in self.tableView.visibleCells)
    {
        UIImageView *voiceImage = (UIImageView*)[cell viewWithTag:bubblePlayImageTag];
        [voiceImage stopAnimating];
    }
    
    playingRow = -1;
    
    talkingUserID = nil;
    [realtimeStartView removeFromSuperview];
}

- (void)onRealPlayStart:(GotyeStatusCode)code speaker:(gotyeapi::GotyeUser)speaker room:(gotyeapi::GotyeRoom)room
{
    talkingUserID = NSStringUTF8(speaker.name);
    
    labelRealTimeStart.text = [NSString stringWithFormat:@"%@发起了实时对讲", talkingUserID];
    
    [self.view addSubview:realtimeStartView];
}

- (void)onStopTalk:(GotyeStatusCode)code realtime:(bool)realtime message:(gotyeapi::GotyeMessage)message cancelSending:(bool *)cancelSending
{
    if(code == GotyeStatusCodeVoiceTooShort)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"录音时间太短"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)onUserDismissGroup:(gotyeapi::GotyeGroup)group user:(gotyeapi::GotyeUser)user
{
    if(group.id == chatTarget.id && chatTarget.type == GotyeChatTargetTypeGroup)
    {
        apiist->deleteSession(group);
        [GotyeUIUtil popToRootViewControllerForNavgaion:self.navigationController animated:YES];
    }
}

#pragma mark - table delegate & data

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messageList->size();
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GotyeMessage message = (*messageList)[indexPath.row];
    
    BOOL showDate = NO;
    if(indexPath.row == 0)
        showDate = YES;
    else
    {
        GotyeMessage lastmessage = (*messageList)[indexPath.row - 1];
        if(message.date - lastmessage.date > 300)
            showDate = YES;
    }
    
    return [GotyeChatBubbleView getbubbleHeight:message showDate:showDate];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MessageCellIdentifier = @"MessageCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] init];
    }
    
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    GotyeMessage message = (*messageList)[indexPath.row];
    
    BOOL showDate = NO;
    if(indexPath.row == 0)
        showDate = YES;
    else
    {
        GotyeMessage lastmessage = (*messageList)[indexPath.row - 1];
        if(message.date - lastmessage.date > 300)
            showDate = YES;
    }

    UIView *bubble = [GotyeChatBubbleView BubbleWithMessage:message showDate:showDate];
    
    UIButton *msgButton = (UIButton *)[(UIButton*)bubble viewWithTag:bubbleMessageButtonTag];
    msgButton.tag = indexPath.row;
    [msgButton addTarget:self action:@selector(messageClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:bubble];
    
    if(playingRow == indexPath.row)
    {
        UIImageView *voiceImage = (UIImageView*)[cell viewWithTag:bubblePlayImageTag];
        [voiceImage startAnimating];
    }
    
    UIButton *headButton = (UIButton*)[cell viewWithTag:bubbleHeadButtonTag];
    headButton.tag = indexPath.row;
    [headButton addTarget:self action:@selector(userClick:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
