//
//  GotyeUIUtil.h
//  GotyeIM
//
//  Created by Peter on 14-9-28.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MBProgressHUD.h"

@interface GotyeUIUtil : NSObject

+(UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+(UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)newSize;
+(NSData*)ConpressImageToJPEGData:(UIImage*)image maxSize:(NSInteger)maxSize;
+(UIImage*)getHeadImage:(NSString *)iconPath defaultIcon:(NSString*)defaultIconName;

+(void)showHUD:(NSString*)text;
+(void)showHUD:(NSString*)text toView:(UIView*)view;
+(void)hideHUD;
+(void)hideHUD:(UIView*)view;

+(void)popToRootViewControllerForNavgaion:(UINavigationController *)navController animated:(BOOL)animated;

@end

@interface UIColor (CreateByInteger)

+(UIColor*)colorWithInteger:(NSInteger)hexInteger alpha:(CGFloat)alpha;

@end

#define Common_Color_Def_Nav    [UIColor colorWithInteger:0x0fd5c9 alpha:1]
#define Common_Color_Def_Gray   [UIColor colorWithInteger:0xeeeeee alpha:1]

#define ScreenHeight    ([[UIScreen mainScreen] bounds].size.height)
#define ScreenWidth     ([[UIScreen mainScreen] bounds].size.width)

#define ImageFileSizeMax    (1024*1024)

#define NSStringUTF8(string)  [NSString stringWithUTF8String:(string).c_str()]
#define STDStringUTF8(nsstr)   std::string([nsstr UTF8String])

#define popToRootViewControllerNotification @"popToRootViewControllerNotification"
