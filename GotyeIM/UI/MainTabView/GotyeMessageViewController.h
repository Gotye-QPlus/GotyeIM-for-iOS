//
//  GotyeTableViewController.h
//  GotyeIM
//
//  Created by Peter on 14-9-29.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GotyeContextMenuCell.h"

#import "GotyeContextMenuTableViewController.h"
#import "GotyeContextMenuCell.h"

@interface GotyeMessageViewController : GotyeContextMenuTableViewController

@property (strong, nonatomic) IBOutlet UIView *viewNetworkFail;
@property (strong, nonatomic) IBOutlet UILabel *labelNetwork;

@end

@interface GotyeMessageCell : GotyeContextMenuCell

@property (strong, nonatomic) IBOutlet UIImageView *imageHead;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UIButton *buttonNewCount;

@property (strong, nonatomic) IBOutlet UIButton *buttonDelete;

@end
