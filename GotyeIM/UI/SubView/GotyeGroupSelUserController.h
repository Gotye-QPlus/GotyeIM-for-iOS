//
//  GotyeGroupSelUserController.h
//  GotyeIM
//
//  Created by Peter on 14-10-9.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeOCAPI.h"


@interface GotyeGroupSelUserController : UITableViewController
{
    UIButton *confirmButton;
    
    NSMutableDictionary *contactDic;
    NSMutableDictionary *checkDic;
    
    NSArray *sortedKeys;
    
    GotyeOCGroup* newGroup;
    
    NSArray *friendList;
}

-(id)initWithGroup:(GotyeOCGroup*)group;

@end
