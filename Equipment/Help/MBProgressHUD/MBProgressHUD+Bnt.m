//
//  MBProgressHUD+Bnt.m
//  MBProgress
//
//  Created by Barnett Wu on 16/4/14.
//  Copyright © 2016年 Dante_Barnett. All rights reserved.
//

#import "MBProgressHUD+Bnt.h"
//#import "BntProgressHUD.h"


#define DefaultMode MBProgressHUDModeIndeterminate
#define DefaultDelay 3.5
#define DefaultDelayIndeterminate 6.66
#define BntKeyWindow [UIApplication sharedApplication].keyWindow

@implementation MBProgressHUD (Bnt)

#pragma mark - show
+ (MBProgressHUD *)showUnderMode:(MBProgressHUDMode)mode
                          toView:(UIView *)view
                            text:(NSString *)text
                            icon:(NSString *)icon
                            time:(float)time
{
    if (view == nil) {
        view = BntKeyWindow;
    }
    __block MBProgressHUD *hud_1 = [[MBProgressHUD alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        
        hud.contentColor = [UIColor whiteColor];
        
        hud.bezelView.backgroundColor = [UIColor blackColor];
        
        hud.label.text = text;
        hud.label.numberOfLines = 3;
        //    hud.label.font = Font(13);
        
        if (icon) {
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
        }
        
        if (mode) {
            hud.mode = mode;
        }else{
            hud.mode = DefaultMode;
        }
        
        //  隐藏时移除
        hud.removeFromSuperViewOnHide = YES;
        
        if (time) {
            [hud hideAnimated:YES afterDelay:time];
        }else{
            [hud hideAnimated:YES afterDelay:DefaultDelay];
        }
        hud_1 = hud;
    });
    return hud_1;
}

//  风火轮模式
+ (void)showIndeterminate
{
    [MBProgressHUD showMode:DefaultMode toView:BntKeyWindow];
//    [MBProgressHUD showUnderMode:DefaultMode toView:BntKeyWindow text:nil icon:nil time:10];
}


/**
 *  显示不带信息
 *
 *  @param message 信息内容
 *  @param view    需要显示信息的视图
 *
 *  @return 直接返回一个MBProgressHUD，需要手动关闭
 */
+ (void)showMode:(MBProgressHUDMode)mode toView:(UIView *)view {
    if (view == nil) view = BntKeyWindow;
     dispatch_async(dispatch_get_main_queue(), ^{
         // 快速显示一个提示信息
         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
         hud.mode = mode;
         hud.bezelView.color = [UIColor blackColor];
         
         hud.contentColor = [UIColor whiteColor];
         
         [hud hideAnimated:YES afterDelay:DefaultDelayIndeterminate];
         // 隐藏时候从父控件中移除
         hud.removeFromSuperViewOnHide = YES;
     });
    
    
}

/**
 *  显示有信息和风火轮
 *
 *  @param message 信息
 *  @param view    toView
 *
 */
+ (void)bnt_indeterminateWithMessage:(NSString *)message
                                         toView:(UIView *)view
{
    if (view == nil){
    view = BntKeyWindow;
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showUnderMode:MBProgressHUDModeIndeterminate toView:view text:message icon:nil time:DefaultDelayIndeterminate];
    // 蒙版效果
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    
}

+ (MBProgressHUD *)bnt_showMessage:(NSString *)message delay:(CGFloat)delay
{

    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showUnderMode:MBProgressHUDModeText toView:BntKeyWindow text:message icon:nil time:delay];
    
    // 蒙版效果
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.contentColor = [UIColor lightGrayColor];
    
    return hud;
}

/**
 *  只显示信息
 *
 *  @param message 信息内容
 *  @param view    需要显示信息的视图
 *
 *  @return 直接返回一个MBProgressHUD，需要手动关闭
 */
+ (MBProgressHUD *)bnt_showMessage:(NSString *)message
                            toView:(UIView *)view
{    if (view == nil) {
        view = BntKeyWindow;
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showUnderMode:MBProgressHUDModeText toView:view text:message icon:nil time:DefaultDelay];

    // 蒙版效果
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.contentColor = [UIColor lightGrayColor];
    
    return hud;
}

+ (MBProgressHUD *)bnt_showMessage:(NSString *)message
{
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD bnt_showMessage:message toView:BntKeyWindow];
    
    return hud;
}


#pragma mark - error
/**
 *  显示错误信息
 *
 */
+ (void)bnt_showError:(NSString *)error
{
    [self bnt_showError:error toView:nil];
}

/**
 *  显示错误信息
 *
 *  @param error 错误信息内容
 *  @param view  需要显示信息的视图
 */
+ (void)bnt_showError:(NSString *)error toView:(UIView *)view{
    [self showUnderMode:MBProgressHUDModeText toView:view text:error icon:nil time:0.5];
}



#pragma mark - hide

/**
 *  手动关闭
 */
+ (void)bnt_hideHUD
{
    [self bnt_hideHUDForView:nil];

}

+ (void)bnt_hideHUDForView:(UIView *)view
{
    if (view == nil)
    {
        view = BntKeyWindow;
    }
    dispatch_async(dispatch_get_main_queue(), ^{

    [self hideHUDForView:view animated:YES];
    });
}

@end
