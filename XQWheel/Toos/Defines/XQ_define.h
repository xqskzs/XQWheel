//
//  XQ_define.h
//  PlusEV
//
//  Created by 小强 on 17/6/22.
//  Copyright © 2017年 小强. All rights reserved.
//

#ifndef XQ_define_h
#define XQ_define_h

//define this constant if you want to use Masonry without the 'mas_' prefix
#define MAS_SHORTHAND

//define this constant if you want to enable auto-boxing for default syntax
#define MAS_SHORTHAND_GLOBALS

#import "Masonry.h"

#import "XQConst.h"

#import "UIView+Extension.h"

#import "ProgressHUD.h"

#import "UIImageView+WebCache.h"

// 日志输出
#ifdef DEBUG
#define XQLog(...) NSLog(__VA_ARGS__)
#else
#define XQLog(...)
#endif

//字体简写
#define XQ_FONT(x)         [UIFont systemFontOfSize:x]
#define XQ_FONT_BOLD(x)    [UIFont boldSystemFontOfSize:x]

#define XQWeakSelf __weak typeof(self) weakSelf = self;

//RGB颜色
#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
//RGB颜色加透明度
#define RGBColorD(r,g,b,d) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:d]
//随即色
#define RandomColor RGBColor(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256))

//16进制rgb
#define UIColorHexadecimal(hexadecimal) [UIColor colorWithRed:((float)((hexadecimal & 0xFF0000) >> 16))/255.0 green:((float)((hexadecimal & 0xFF00) >> 8))/255.0 blue:((float)(hexadecimal & 0xFF))/255.0 alpha:1.0]

#define UIColorHexadecimalD(hexadecimal,d) [UIColor colorWithRed:((float)((hexadecimal & 0xFF0000) >> 16))/255.0 green:((float)((hexadecimal & 0xFF00) >> 8))/255.0 blue:((float)(hexadecimal & 0xFF))/255.0 alpha:d]

//固定颜色值
#define XQ_BGCOLOR_MIN                                     RGBColor(50, 50, 50)
#define XQ_BGCOLOR_MIDDLE                                  RGBColor(100, 100, 100)
#define XQ_BGCOLOR_LARGE                                   RGBColor(150, 150, 150)
#define XQ_BGCOLOR_REGULAR                                 RGBColor(200, 200, 200)
#define XQ_BGCOLOR_MAX                                     RGBColor(240, 240, 240)

//屏幕大小
#define WW [UIScreen mainScreen].bounds.size.width
#define HH [UIScreen mainScreen].bounds.size.height


//适配比例
#define _SCALE_H(h)            ((HH)/667) * (h)

#define _SCALE_W(w)            ((WW)/375) * (w)
//是否iphoneX
#define IS_IPHONEX  (CGSizeEqualToSize(CGSizeMake(375.0f, 812.0f), [[UIScreen mainScreen] bounds].size) ? YES : NO)

//适配iphonex状态栏尺寸
#define XStatusBarH         (IS_IPHONEX ? 44 : 20)
//适配iphonex导航栏尺寸
#define XNavigationBarH     (IS_IPHONEX ? 88 : 64)
//适配iphonex底部
#define XTabBarH            (IS_IPHONEX ? 34 : 0)

#endif /* XQ_define_h */
