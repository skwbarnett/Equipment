//
//  MBProgressHUD+Bnt.h
//  MBProgress
//
//  Created by Barnett Wu on 16/4/14.
//  Copyright © 2016年 Dante_Barnett. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Bnt)

/**
 *  显示
 *
 *  @param mode 模式
 *  @param view 添加到视图
 *  @param text 信息
 *  @param icon 图标
 *  @param time 持续时间
 */
+ (MBProgressHUD *)showUnderMode:(MBProgressHUDMode)mode
                          toView:(UIView *)view
                            text:(NSString *)text
                            icon:(NSString *)icon
                            time:(float)time;

/**
 *  显示风火轮
 */
+ (void)showIndeterminate;

/**
 *  显示有信息和风火轮
 *
 *  @param message 信息
 *  @param view    toView
 *
 */
+ (void)bnt_indeterminateWithMessage:(NSString *)message
                              toView:(UIView *)view;

/**
 *  只显示信息
 *
 *  @param message 信息内容
 *  @param view    需要显示信息的视图
 *
 *  @return 直接返回一个MBProgressHUD，需要手动关闭
 */
+ (MBProgressHUD *)bnt_showMessage:(NSString *)message;

+ (MBProgressHUD *)bnt_showMessage:(NSString *)message
                        toView:(UIView *)view;

+ (MBProgressHUD *)bnt_showMessage:(NSString *)message delay:(CGFloat)delay;

+ (void)bnt_showError:(NSString *)error;
+ (void)bnt_showError:(NSString *)error toView:(UIView *)view;

+ (void)bnt_hideHUD;
+ (void)bnt_hideHUDForView:(UIView *)view;
@end
