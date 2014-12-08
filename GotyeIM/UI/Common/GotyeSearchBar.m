//
//  GotyeSearchBar.m
//  GotyeIM
//
//  Created by Peter on 14-10-29.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeSearchBar.h"

@implementation GotyeSearchBar

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"GotyeSearchBar" owner:self options:nil] firstObject];
    if (self) {
        UIButton *searchIcon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 15)];
        [searchIcon setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
        searchIcon.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        searchIcon.userInteractionEnabled = NO;
        
        self.textSearch.leftView = searchIcon;
        self.textSearch.leftViewMode = UITextFieldViewModeAlways;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"GotyeSearchBar" owner:self options:nil] firstObject];;
    if (self) {
        self.frame = frame;
        UIButton *searchIcon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 15)];
        [searchIcon setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
        searchIcon.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        searchIcon.userInteractionEnabled = NO;
        
        self.textSearch.leftView = searchIcon;
        self.textSearch.leftViewMode = UITextFieldViewModeAlways;
    }
    return self;
}

- (IBAction)textSearchReturn:(id)sender
{
    [self.textSearch resignFirstResponder];
}

@end
