//
//  XQWheelLandscapeView.h
//  XQWheel
//
//  Created by 小强 on 2018/6/30.
//  Copyright © 2018年 小强. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kPageScrollViewHeight (WW * 9.0 / 16.0)

@class XQWheelLandscapeView;
@protocol WheelLandscapeDelegate<NSObject>

@optional

- (void)wheelView:(XQWheelLandscapeView *)view selectedIndex:(NSUInteger)index;
@end
@interface XQWheelLandscapeView : UIView

@property(nonatomic,weak)id<WheelLandscapeDelegate> delegate;
/** 图片地址数组 */
@property (strong, nonatomic) NSArray<id> *imageURLs;//id可以是UIImage,NSUrl,链接字符串

/** 自动滑动时间 */
@property (assign, nonatomic) NSTimeInterval pagingInterval;

/** 指示器颜色（未选中） */
@property (strong, nonatomic) UIColor *pageIndicatorTintColor;

/** 指示器颜色（当前） */
@property (strong, nonatomic) UIColor *currentPageIndicatorTintColor;


/**
 *  开始自动滑动
 */
- (void)beginAutoPaging;

/**
 *  停止自动滑动
 */
- (void)stopAutoPaging;

@end
