//
//  GotyeContextMenuTableViewController.h
//  GotyeContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GotyeContextMenuCell.h"
#import "GotyeOverlayView.h"


@interface GotyeContextMenuTableViewController : UITableViewController <GotyeContextMenuCellDelegate, GotyeOverlayViewDelegate>

@property (readonly, strong, nonatomic) GotyeContextMenuCell *cellDisplayingMenuOptions;
@property (assign, nonatomic) BOOL shouldDisableUserInteractionWhileEditing;

- (void)hideMenuOptionsAnimated:(BOOL)animated;

@end
