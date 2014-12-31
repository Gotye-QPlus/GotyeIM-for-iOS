//
//  GotyeContactViewController.h
//  GotyeIM
//
//  Created by Peter on 14-9-28.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeContextMenuTableViewController.h"
#import "GotyeContextMenuCell.h"

#import "GotyeOCAPI.h"

@interface GotyeContactViewController : GotyeContextMenuTableViewController
{
    NSMutableDictionary *contactDic;
    NSArray *sortedKeys;
    NSIndexPath *deletingItem;
    
    NSArray *userList;
}

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIButton *buttonContact;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlack;

@end

@interface GotyeContactCell : GotyeContextMenuCell

@property (nonatomic) BOOL showNickName;

@property (strong, nonatomic) IBOutlet UIImageView *imageHead;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UIButton *buttonCheck;
@property (strong, nonatomic) IBOutlet UILabel *labelNickname;

@property (strong, nonatomic) IBOutlet UIButton *buttonDelete;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlock;

@end
