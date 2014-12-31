//
//  GotyeGroupSearchController.h
//  GotyeIM
//
//  Created by Peter on 14-10-29.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeOCAPI.h"


@interface GotyeGroupSearchController : UITableViewController
{
    NSArray* grouplistReceive;
    NSArray* grouplistlocal;
    NSMutableArray* requestSend;
    
    NSInteger searchPageIndex;
    BOOL haveMoreData;
}

@end

@interface GotyeGroupSearchCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageHead;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UIButton *buttonApply;
@property (strong, nonatomic) IBOutlet UILabel *labelSend;

@end
