//
//  GotyeOverlayView.h
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/25/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GotyeOverlayView;

@protocol GotyeOverlayViewDelegate <NSObject>

- (UIView *)overlayView:(GotyeOverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event;

@end


@interface GotyeOverlayView : UIView

@property (weak, nonatomic) id<GotyeOverlayViewDelegate> delegate;

@end
