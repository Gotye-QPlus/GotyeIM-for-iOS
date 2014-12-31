//
//  GotyeChatRoomController.h
//  GotyeIM
//
//  Created by Peter on 14-10-9.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeOCAPI.h"


@interface GotyeChatRoomListController : UITableViewController
{
    NSInteger selectedRow;
    
    NSArray *roomlistReceive;
    
    NSInteger searchPageIndex;
    BOOL haveMoreData;
}

@end
