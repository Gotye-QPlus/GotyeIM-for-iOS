//
//  GotyeOverlayView.m
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/25/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "GotyeOverlayView.h"

@implementation GotyeOverlayView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self.delegate overlayView:self didHitTest:point withEvent:event];
}

@end