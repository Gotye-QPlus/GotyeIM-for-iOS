//
//  GotyeLoadingView.m
//  GotyeIM
//
//  Created by Peter on 14-10-31.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeLoadingView.h"

@interface GotyeLoadingView()

@property (strong, nonatomic) IBOutlet UILabel *labelNotice;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation GotyeLoadingView

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"GotyeLoadingView" owner:self options:nil] firstObject];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"GotyeLoadingView" owner:self options:nil] firstObject];;
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (void)showLoading:(BOOL)loading
{
    self.indicator.hidden = !loading;
    self.labelNotice.text = loading ? @"正在加载" : @"下面没有了";
}

@end
