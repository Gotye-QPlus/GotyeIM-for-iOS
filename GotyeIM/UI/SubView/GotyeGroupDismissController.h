//
//  GotyeGroupDismissController.h
//  GotyeIM
//
//  Created by Peter on 14-10-23.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeOCAPI.h"


@interface GotyeGroupDismissController : UIViewController
{
    GotyeOCGroup* groupTarget;
    
    NSArray* groupUserlist;
}

@property (strong, nonatomic) IBOutlet UIView *headListView;
@property (strong, nonatomic) IBOutlet UIButton *changeButton;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;

-(id)initWithTarget:(GotyeOCGroup*)target userList:(NSArray*)list;

@end
