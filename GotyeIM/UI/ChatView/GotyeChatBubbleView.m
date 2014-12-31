//
//  GotyeChatBubbleCell.m
//  GotyeIM
//
//  Created by Peter on 14-10-17.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeChatBubbleView.h"

#import "GotyeUIUtil.h"

#define kContentWidthMax    160
#define kBubbleMinHeight    40
#define kHeadIconSize       40
#define kTextFontSize       14

#define kGapBetweenBubbles  12
#define kDateTextHeight     36
#define kExtraTextHeight     20

#define kBubbleTopGap       12
#define kBubbleBottomGap    12
#define kBubbleCommaGap     21
#define kBubbleEndGap       14

#define kImageMaxHeight     80

@implementation GotyeChatBubbleView

+(NSInteger)getbubbleHeight:(GotyeOCMessage*)message showDate:(BOOL)showDate
{
    UIFont *font = [UIFont systemFontOfSize:kTextFontSize];
	CGSize size;
    switch (message.type) {
        case GotyeMessageTypeText:
        {
            size = [message.text boundingRectWithSize:CGSizeMake(kContentWidthMax, 1000.0f)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName: font}
                                      context:nil].size;
        }
            break;
        case GotyeMessageTypeAudio:
        {
            size = CGSizeMake(0, 0);
        }
            break;
        case GotyeMessageTypeImage:
        {
            UIImage* image = [UIImage imageWithContentsOfFile:message.media.path];
            size = image.size;
            size.width /= 2;
            size.height /= 2;
            
            if(size.width > kContentWidthMax)
            {
                size.height = kContentWidthMax * size.height / size.width;
            }
            if(size.height > kImageMaxHeight) size.height = kImageMaxHeight;
            
        }
            break;
            
        default:
            break;
    }
    
    size.height += kBubbleTopGap + kBubbleBottomGap;
    if(size.height < kBubbleMinHeight) size.height = kBubbleMinHeight;
    
    if(showDate)
        size.height += kDateTextHeight;
    
    if(message.hasExtraData && message.type == GotyeMessageTypeAudio)
        size.height += kExtraTextHeight;

    return size.height + kGapBetweenBubbles;
}


+(UIView*)BubbleWithMessage:(GotyeOCMessage*)message  showDate:(BOOL)showDate
{
    NSString *text = message.text;
    GotyeMessageType msgType = message.type;
    if(msgType == GotyeMessageTypeUserData)
    {
        text = @"[用户数据]";
        msgType = GotyeMessageTypeText;
    }
    
    BOOL msgFromSelf = [[GotyeOCAPI getLoginUser].name isEqualToString:message.sender.name];
    
	UIView *messageView = [[UIView alloc] initWithFrame:CGRectZero];
	messageView.backgroundColor = [UIColor clearColor];
    
	UIImageView *bubbleImageView;
    CGFloat messageXoffset = kBubbleCommaGap + 60;
    CGFloat messageYoffset = showDate ? kDateTextHeight : 0;
    CGFloat bubbleXoffset = 60;
    UIColor *textColor;
    
    if(msgFromSelf)
    {
        bubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bubble_self"]];
        textColor = [UIColor whiteColor];
    }
    else
    {
        bubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bubble_user"]];
        textColor = [UIColor blackColor];
    }
    
    CGSize size;
    UIView *content = nil, *content2 = nil;
    
    switch (msgType) {
        case GotyeMessageTypeText:
        {
            //文字标签设置
            UIFont *font = [UIFont systemFontOfSize:kTextFontSize];
            size = [text boundingRectWithSize:CGSizeMake(kContentWidthMax, 1000.0f)
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{NSFontAttributeName: font}
                               context:nil].size;

            if(msgFromSelf)
            {
                messageXoffset = ScreenWidth - messageXoffset - size.width;
                bubbleXoffset = ScreenWidth - bubbleXoffset - kBubbleCommaGap - kBubbleEndGap - size.width;
            }
            
            UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(messageXoffset, kGapBetweenBubbles / 2 + kBubbleTopGap + messageYoffset, size.width, size.height)];
            bubbleText.backgroundColor = [UIColor clearColor];
            bubbleText.textColor = textColor;
            bubbleText.font = font;
            bubbleText.numberOfLines = 0;
            bubbleText.lineBreakMode = NSLineBreakByWordWrapping;
            bubbleText.text = text;
            
            content = bubbleText;
        }
            break;
            
        case GotyeMessageTypeAudio:
        {
            size = CGSizeMake(60, 16);
            
            if(msgFromSelf)
            {
                messageXoffset = ScreenWidth - messageXoffset - size.width;
                bubbleXoffset = ScreenWidth - bubbleXoffset - kBubbleCommaGap - kBubbleEndGap - size.width;
            }
            
            UILabel *durText = [[UILabel alloc] initWithFrame:CGRectMake(messageXoffset, kGapBetweenBubbles / 2 + kBubbleTopGap + messageYoffset, size.width, size.height)];
            durText.backgroundColor = [UIColor clearColor];
            durText.textColor = msgFromSelf ? textColor : Common_Color_Def_Nav;
            durText.font = [UIFont systemFontOfSize:kTextFontSize + 1];
            durText.numberOfLines = 0;
            durText.textAlignment = msgFromSelf ? NSTextAlignmentLeft : NSTextAlignmentRight;
            durText.text = [[NSString alloc] initWithFormat:@"%d'", message.media.duration /1000];
            
            UIImageView *voiceImage = [[UIImageView alloc] initWithFrame:CGRectMake(messageXoffset + (msgFromSelf ? size.width - 16 : 0), kGapBetweenBubbles / 2 + 10 + messageYoffset, 14, 20)];
            
            NSMutableArray *animArray = [NSMutableArray array];
            NSString *imageNameFormat;
            if(msgFromSelf)
            {
                imageNameFormat = @"chat_anim_voice_white_%d";
                voiceImage.image = [UIImage imageNamed:@"chat_anim_voice_white_3"];
            }
            else
            {
                imageNameFormat = @"chat_anim_voice_%d";
                voiceImage.image = [UIImage imageNamed:@"chat_anim_voice_3"];
            }
            
            for (int i = 1; i<=3; i++) {
                [animArray addObject:[UIImage imageNamed:[NSString stringWithFormat:imageNameFormat, i]]];
            }
            voiceImage.animationImages = animArray;
            voiceImage.animationDuration = 1;
            voiceImage.tag = bubblePlayImageTag;
            
            content = durText;
            content2 = voiceImage;
        }
            break;
            
        case GotyeMessageTypeImage:
        {
            UIImage* image = [UIImage imageWithContentsOfFile:message.media.path];
            if(image == nil)
                size = CGSizeMake(kBubbleMinHeight - kBubbleTopGap - kBubbleBottomGap, kBubbleMinHeight - kBubbleTopGap - kBubbleBottomGap);
            else
                size = CGSizeMake(image.size.width / 2, image.size.height / 2);
            
            if(size.width > kContentWidthMax)
            {
                size.height = kContentWidthMax * size.height / size.width;
                size.width = kContentWidthMax;
            }
            if(size.height > kImageMaxHeight)
            {
                size.width = kImageMaxHeight * size.width / size.height;
                size.height = kImageMaxHeight;
            }
            
            if(msgFromSelf)
            {
                messageXoffset = ScreenWidth - messageXoffset - size.width;
                bubbleXoffset = ScreenWidth - bubbleXoffset - kBubbleCommaGap - kBubbleEndGap - size.width;
            }
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(messageXoffset, kGapBetweenBubbles / 2 + kBubbleTopGap + messageYoffset, size.width, size.height)];
            if(image != nil)
                imgView.image = image;
            else
                imgView.image = [UIImage imageNamed:@"chat_button_pic"];
            imgView.tag = bubbleThumbImageTag;
            
            content = imgView;
        }
            break;
            
            default:
            break;
    }
    
	bubbleImageView.frame = CGRectMake(bubbleXoffset, kGapBetweenBubbles / 2 + messageYoffset, size.width + kBubbleCommaGap + kBubbleEndGap, size.height + kBubbleTopGap + kBubbleEndGap);
    
	messageView.frame = CGRectMake(0.0f, 0.0f, 320, bubbleImageView.frame.size.height + kGapBetweenBubbles + messageYoffset);
	[messageView addSubview:bubbleImageView];
    [messageView addSubview:content];
    [messageView addSubview:content2];
    
//  热点按钮
    if(message.type == GotyeMessageTypeAudio || message.type == GotyeMessageTypeImage)
    {
        UIButton *msgButton = [[UIButton alloc] initWithFrame:bubbleImageView.frame];
        msgButton.tag = bubbleMessageButtonTag;
        [messageView addSubview:msgButton];
    }
    
//  头像图片
    GotyeOCUser* user = [GotyeOCAPI getUserDetail:message.sender forceRequest:NO];
    NSString *headpath = user.icon.path;
    UIImage *headImage = [GotyeUIUtil getHeadImage:headpath defaultIcon:@"head_icon_user"];
    
    UIButton *headImageView = [[UIButton alloc] initWithFrame:CGRectZero];
    headImageView.tag = bubbleHeadButtonTag;
    if(msgFromSelf)
    {
        headImageView.frame = CGRectMake(265, kGapBetweenBubbles / 2 + messageYoffset, kHeadIconSize, kHeadIconSize);
    }
    else
    {
        headImageView.frame = CGRectMake(15, kGapBetweenBubbles / 2 + messageYoffset, kHeadIconSize, kHeadIconSize);
    }
    [headImageView setBackgroundImage:headImage forState:UIControlStateNormal];
    
    [messageView addSubview:headImageView];
    
//  时间
    if(showDate)
    {
        UILabel *dateText = [[UILabel alloc] initWithFrame:CGRectMake(0, kGapBetweenBubbles / 2, 320, kDateTextHeight)];
        dateText.backgroundColor = [UIColor clearColor];
        dateText.textColor = [UIColor lightGrayColor];
        dateText.font = [UIFont systemFontOfSize:11];
        dateText.textAlignment = NSTextAlignmentCenter;
        dateText.text = [self getMessageDateString:[NSDate dateWithTimeIntervalSince1970:message.date]];
        [messageView addSubview:dateText];
    }

//  状态
    NSString *stateString;
    if(message.status == GotyeMessageStatusSending)
        stateString = @"发送中";
    else if (message.status == GotyeMessageStatusSendingFailed)
        stateString = @"发送失败";
    else if (message.status == GotyeMessageStatusSent)
        stateString = @"已发送";
    
    if(message.media.status == GotyeMediaStatusDownloading)
        stateString = @"下载中";
    else if (message.media.status == GotyeMediaStatusDownloadFailed)
        stateString = @"下载失败";
    
    if(stateString != nil)
    {
        CGRect frame;
        if(msgFromSelf)
        {
            frame = CGRectMake(0, bubbleImageView.frame.origin.y + bubbleImageView.frame.size.height / 2 - 8, bubbleImageView.frame.origin.x - 10, 16);
        }
        else
        {
            frame = CGRectMake(bubbleImageView.frame.origin.x + bubbleImageView.frame.size.width + 10, bubbleImageView.frame.origin.y + bubbleImageView.frame.size.height / 2 - 8, ScreenWidth - bubbleImageView.frame.origin.x - bubbleImageView.frame.size.width - 10, 16);
        }
        
        UILabel *stateText = [[UILabel alloc] initWithFrame:frame];
        stateText.backgroundColor = [UIColor clearColor];
        stateText.textColor = [UIColor lightGrayColor];
        stateText.font = [UIFont systemFontOfSize:11];
        stateText.textAlignment = msgFromSelf ? NSTextAlignmentRight : NSTextAlignmentLeft;
        stateText.text = stateString;
        [messageView addSubview:stateText];
    }
    
    if(message.hasExtraData && message.type == GotyeMessageTypeAudio)
    {
        NSData *data = [NSData dataWithContentsOfFile:message.extra.path];
        
        if(data != nil)
        {
            char * str = malloc(data.length + 1);
            [data getBytes:str length:data.length];
            str[data.length] = 0;
            NSString *extraStr = [NSString stringWithUTF8String:str];
            free(str);
            
            CGRect frame = CGRectMake(60 , bubbleImageView.frame.origin.y + bubbleImageView.frame.size.height + 2, 200, 16);
            UILabel *extraText = [[UILabel alloc] initWithFrame:frame];
            extraText.backgroundColor = [UIColor clearColor];
            extraText.textColor = [UIColor lightGrayColor];
            extraText.font = [UIFont systemFontOfSize:11];
            extraText.textAlignment = msgFromSelf ? NSTextAlignmentRight : NSTextAlignmentLeft;
            extraText.text = [NSString stringWithFormat:@"语音内容：%@", extraStr];
            
            [messageView addSubview:extraText];
        }
    }
    
    return messageView;
}

+ (NSString*)getMessageDateString:(NSDate*)messageDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:messageDate];
    NSDate *msgDate = [cal dateFromComponents:components];
    
    components = [cal components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    
    if([today isEqualToDate:msgDate])
        [formatter setDateFormat:@"HH:mm"];
    
    components.day -= 1;
    NSDate *yestoday = [cal dateFromComponents:components];
    
    if([yestoday isEqualToDate:msgDate])
        [formatter setDateFormat:@"昨天 HH:mm"];
    
    return [formatter stringFromDate:messageDate];
}

@end
