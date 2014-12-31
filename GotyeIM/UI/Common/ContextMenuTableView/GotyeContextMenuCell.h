//
//  DAСontextMenuCell.h
//  GotyeContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GotyeContextMenuCellButtonVerticalAlignmentModeCenter = 0,
    GotyeContextMenuCellButtonVerticalAlignmentModeTop,
    GotyeContextMenuCellButtonVerticalAlignmentModeBottom
} GotyeContextMenuCellButtonVerticalAlignmentMode;

@class GotyeContextMenuCell;


@protocol GotyeContextMenuCellDataSource <NSObject>

- (NSUInteger)numberOfButtonsInContextMenuCell:(GotyeContextMenuCell *)cell;
- (UIButton *)contextMenuCell:(GotyeContextMenuCell *)cell buttonAtIndex:(NSUInteger)index;
- (GotyeContextMenuCellButtonVerticalAlignmentMode)contextMenuCell:(GotyeContextMenuCell *)cell alignmentForButtonAtIndex:(NSUInteger)index;

@end


@protocol GotyeContextMenuCellDelegate <NSObject>

- (void)contextMenuCell:(GotyeContextMenuCell *)cell buttonTappedAtIndex:(NSUInteger)index;
- (void)contextMenuDidHideInCell:(GotyeContextMenuCell *)cell;
- (void)contextMenuDidShowInCell:(GotyeContextMenuCell *)cell;
- (void)contextMenuWillHideInCell:(GotyeContextMenuCell *)cell;
- (void)contextMenuWillShowInCell:(GotyeContextMenuCell *)cell;
- (BOOL)shouldDisplayContextMenuViewInCell:(GotyeContextMenuCell *)cell;

@end


@interface GotyeContextMenuCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *actualContentView;
@property (strong, nonatomic) UIColor *contextMenuBackgroundColor;
@property (readonly, assign, nonatomic, getter = isContextMenuHidden) BOOL contextMenuHidden;
@property (assign, nonatomic) BOOL contextMenuEnabled;
@property (assign, nonatomic) CGFloat menuOptionsAnimationDuration;
@property (assign, nonatomic) CGFloat bounceValue;
@property (readonly, strong, nonatomic) UIPanGestureRecognizer *panRecognizer;

@property (weak, nonatomic) id<GotyeContextMenuCellDataSource> dataSource;
@property (weak, nonatomic) id<GotyeContextMenuCellDelegate> delegate;

- (void)setMenuOptionsViewHidden:(BOOL)hidden animated:(BOOL)animated completionHandler:(void (^)(void))completionHandler;

@end