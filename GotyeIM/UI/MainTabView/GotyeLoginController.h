//
//  GotyeLoginController.h
//  GotyeIM
//
//  Created by Peter on 14-10-13.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GotyeLoginController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *textUsername;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;

@property (strong, nonatomic) IBOutlet UIScrollView *contentView;
@property (strong, nonatomic) IBOutlet UITableView *appkeyTable;
@property (strong, nonatomic) IBOutlet UITableView *serverTable;
@property (strong, nonatomic) IBOutlet UITextField *textAppkey;
@property (strong, nonatomic) IBOutlet UITextField *textServer;
@property (strong, nonatomic) IBOutlet UITextField *textPort;

@end
