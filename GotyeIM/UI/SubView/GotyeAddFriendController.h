//
//  GotyeAddFriendController.h
//  GotyeIM
//
//  Created by Peter on 14-9-29.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeOCAPI.h"


@interface GotyeAddFriendController : UITableViewController
{
    NSString *curUserID;
    
    NSArray* userlistReceive;
    
    NSInteger searchPageIndex;
    BOOL haveMoreData;
}

@end

@interface GotyeAddFriendCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageHead;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelID;
@property (strong, nonatomic) IBOutlet UIButton *buttonAdd;

@end

@interface GotyeAddFriendInputController : UIViewController
{
    UITextField *textInput;
}

@end