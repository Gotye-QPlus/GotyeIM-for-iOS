//
//  GotyeGroupSelUserController.h
//  GotyeIM
//
//  Created by Peter on 14-10-9.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeAPI.h"

USING_NS_GOTYEAPI;

@interface GotyeGroupSelUserController : UITableViewController
{
    UIButton *confirmButton;
    
    NSMutableDictionary *contactDic;
    NSMutableDictionary *checkDic;
    
    NSArray *sortedKeys;
    
    GotyeGroup newGroup;
}

-(id)initWithGroup:(GotyeGroup)group;

@end
