//
//  GotyeUserInfoController.h
//  GotyeIM
//
//  Created by Peter on 14-10-23.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeOCAPI.h"


@interface GotyeUserInfoController : UIViewController
{
    GotyeOCUser* userTarget;
    
    long long groupID;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageHead;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelID;

@property (strong, nonatomic) IBOutlet UIButton *buttonAdd;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlock;
@property (strong, nonatomic) IBOutlet UIButton *buttonMessage;
@property (strong, nonatomic) IBOutlet UIButton *buttonKickout;

-(id)initWithTarget:(GotyeOCUser*)target groupID:(long long)gID;

@end
