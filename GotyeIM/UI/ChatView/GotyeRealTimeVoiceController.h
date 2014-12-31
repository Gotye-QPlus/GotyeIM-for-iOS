//
//  GotyeRealTimeVoiceController.h
//  GotyeIM
//
//  Created by Peter on 14-10-21.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeOCAPI.h"


@interface GotyeRealTimeVoiceController : UIViewController
{
    unsigned roomID;
    
    NSString *talkingUserID;
    
    NSArray* roomUserlist;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewUsers;
@property (strong, nonatomic) IBOutlet UILabel  *labelSpeaker;
@property (strong, nonatomic) IBOutlet UIImageView *imageSpeaking;

-(id)initWithRoomID:(unsigned)ID talkingID:(NSString*)userID;

@end
