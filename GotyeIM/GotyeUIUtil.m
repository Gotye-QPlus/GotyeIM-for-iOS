//
//  GotyeUIUtil.m
//  GotyeIM
//
//  Created by Peter on 14-9-28.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeUIUtil.h"

@implementation GotyeUIUtil

+(UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{
    
	CGImageRef maskRef = maskImage.CGImage;
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	return [UIImage imageWithCGImage:masked];
}

+(UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)newSize
{
    NSUInteger newWidth = newSize.width ;
    NSUInteger newHeight = newSize.height;
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+(UIImage*)scaleImage:(UIImage*)image toScale:(CGFloat)scaleSize
{
    return [self scaleImage:image toSize:CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize)];
}

+(NSData*)ConpressImageToJPEGData:(UIImage*)image maxSize:(NSInteger)maxSize
{
    CGFloat scaleSize = 1; /* Modify by Zhuqi 20120704 */
//    if(image.size.width > 128)
//        scaleSize = 128 / image.size.width;
    UIImage *cmpImg = image;//[self scaleImage:image toScale:scaleSize];
    NSData *jpgImage = UIImageJPEGRepresentation(cmpImg, 0.75f);
    image = nil;
    
    NSUInteger length = jpgImage.length;
    while (length > maxSize) {
        scaleSize = (CGFloat)maxSize / jpgImage.length;
        scaleSize = sqrtf(scaleSize);
        cmpImg = [self scaleImage:cmpImg toScale:scaleSize];
        jpgImage = UIImageJPEGRepresentation(cmpImg, 0.75f);
        length = jpgImage.length;
    }
    
    return jpgImage;
}

+(UIImage*)getHeadImage:(NSString *)iconPath defaultIcon:(NSString*)defaultIconName
{
    UIImage *headImage= [UIImage imageWithContentsOfFile:iconPath];
    if(headImage != nil)
    {
        UIImage *maskImage = [UIImage imageNamed:@"message_head_mask"];
        
        headImage = [GotyeUIUtil scaleImage:headImage toSize:maskImage.size];
        headImage = [GotyeUIUtil maskImage:headImage withMask:maskImage];
        
        headImage = headImage;
    }
    return (headImage == nil) ? [UIImage imageNamed:defaultIconName] : headImage;
}

+(void)showHUD:(NSString *)text
{
    UIView *rootView = [[UIApplication sharedApplication].delegate window].rootViewController.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:rootView animated:NO];
    hud.labelText = text;
    hud.opacity = 0.5;
    hud.removeFromSuperViewOnHide = YES;
}

+(void)showHUD:(NSString *)text toView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
    hud.labelText = text;
    hud.opacity = 0.5;
    hud.removeFromSuperViewOnHide = YES;
}

+(void)hideHUD
{
    UIView *rootView = [[UIApplication sharedApplication].delegate window].rootViewController.view;
    [MBProgressHUD hideHUDForView:rootView animated:YES];
}

+(void)hideHUD:(UIView*)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

+(void)popToRootViewControllerForNavgaion:(UINavigationController *)navController animated:(BOOL)animated
{
    [navController popToRootViewControllerAnimated:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:popToRootViewControllerNotification object:nil];
}

@end

@implementation UIColor (CreateByInteger)

+(UIColor*)colorWithInteger:(NSInteger)hexInteger alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((float)((hexInteger & 0xFF0000) >> 16))/255.0 green:((float)((hexInteger & 0xFF00) >> 8))/255.0 blue:((float)(hexInteger & 0xFF))/255.0 alpha:(alpha)];
}

@end
