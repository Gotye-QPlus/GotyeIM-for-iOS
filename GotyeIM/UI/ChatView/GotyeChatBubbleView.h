//
//  GotyeChatBubbleCell.h
//  GotyeIM
//
//  Created by Peter on 14-10-17.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeOCAPI.h"


@interface GotyeChatBubbleView : UIView

#define bubblePlayImageTag      10000
#define bubbleHeadButtonTag     10001
#define bubbleThumbImageTag     10002
#define bubbleMessageButtonTag  10003

+(NSInteger)getbubbleHeight:(GotyeOCMessage*)message showDate:(BOOL)showDate;

+(UIView*)BubbleWithMessage:(GotyeOCMessage*)message showDate:(BOOL)showDate;

@end
