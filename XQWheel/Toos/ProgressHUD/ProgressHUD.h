//
//  ProgressHUD.h
//  ProgressHUD-obj-C
//
//  Created by apple on 16/7/12.
//  Copyright © 2016年 ANGELEN. All rights reserved.
//

#import <UIKit/UIKit.h>

// 文字字体
#define HUD_STATUS_FONT			[UIFont boldSystemFontOfSize:16]
// 文字颜色
#define HUD_STATUS_COLOR		[UIColor colorWithRed:0.24 green:0.71 blue:1.00 alpha:1.00]

// 菊花颜色
#define HUD_SPINNER_COLOR		[UIColor colorWithRed:0.24 green:0.71 blue:1.00 alpha:1.00]
// HUD 背景颜色
#define HUD_BACKGROUND_COLOR	[UIColor colorWithRed:1 green:1 blue:1 alpha:1.00]
// HUD 后面的 Window 的颜色
#define HUD_WINDOW_COLOR		[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2]

// 成功提示图标
#define HUD_IMAGE_SUCCESS		[UIImage imageNamed:@"ProgressHUD.bundle/progresshud-success.png"]
// 失败提示图标
#define HUD_IMAGE_ERROR			[UIImage imageNamed:@"ProgressHUD.bundle/progresshud-error.png"]

@interface ProgressHUD : UIView

+ (ProgressHUD *)shared;

+ (void)dismiss;

+ (void)show:(NSString *)status;
+ (void)show:(NSString *)status Interaction:(BOOL)Interaction;

+ (void)showSuccess:(NSString *)status;
+ (void)showSuccess:(NSString *)status Interaction:(BOOL)Interaction;

+ (void)showError:(NSString *)status;
+ (void)showError:(NSString *)status Interaction:(BOOL)Interaction;

@end
