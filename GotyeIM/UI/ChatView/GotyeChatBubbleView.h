//
//  GotyeChatBubbleCell.h
//  GotyeIM
//
//  Created by Peter on 14-10-17.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeAPI.h"

USING_NS_GOTYEAPI;

@interface GotyeChatBubbleView : UIView

#define bubblePlayImageTag      10000
#define bubbleHeadButtonTag     10001
#define bubbleThumbImageTag     10002
#define bubbleMessageButtonTag  10003

+(NSInteger)getbubbleHeight:(GotyeMessage)message showDate:(BOOL)showDate;

+(UIView*)BubbleWithMessage:(GotyeMessage)message showDate:(BOOL)showDate;

@end
