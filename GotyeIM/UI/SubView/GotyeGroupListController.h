//
//  GotyeGroupListController.h
//  GotyeIM
//
//  Created by Peter on 14-10-9.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeAPI.h"

USING_NS_GOTYEAPI;

@interface GotyeGroupListController : UITableViewController
{
    const std::vector<GotyeGroup> *grouplistReceive;
}

@end
