//
//  GotyeGroupDismissController.h
//  GotyeIM
//
//  Created by Peter on 14-10-23.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeAPI.h"

USING_NS_GOTYEAPI;

@interface GotyeGroupDismissController : UIViewController
{
    GotyeGroup groupTarget;
    
    std::vector<GotyeUser> groupUserlist;
}

@property (strong, nonatomic) IBOutlet UIView *headListView;
@property (strong, nonatomic) IBOutlet UIButton *changeButton;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;

-(id)initWithTarget:(GotyeGroup)target userList:(std::vector<GotyeUser>)list;

@end
