//
//  GotyeNotifyController.h
//  GotyeIM
//
//  Created by Peter on 14-9-29.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GotyeContextMenuTableViewController.h"
#import "GotyeContextMenuCell.h"

@interface GotyeNotifyController : GotyeContextMenuTableViewController
{
    NSArray *messageArray;
    
    NSArray *notifylist;
    
    NSInteger processingIndex;
}

@end

@interface GotyeNotifyCell : GotyeContextMenuCell

@property (strong, nonatomic) IBOutlet UIImageView *imageHead;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;
@property (strong, nonatomic) IBOutlet UIButton *buttonConfirm;

@property (strong, nonatomic) IBOutlet UIButton *buttonReject;

@end