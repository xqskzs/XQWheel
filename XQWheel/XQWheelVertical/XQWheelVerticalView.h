//
//  XQWheelVerticalView.h
//  XQWheel
//
//  Created by 小强 on 2018/6/30.
//  Copyright © 2018年 小强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XQWheelVerticalModel.h"
#import "XQWheelVerticalCell.h"

@class XQWheelVerticalView;
@protocol WheelVerticalDelegate<NSObject>

@optional

- (void)wheelView:(XQWheelVerticalView *)view model:(XQWheelVerticalModel *)model;

- (void)wheelView:(XQWheelVerticalView *)view selectedIndex:(NSUInteger)index;
@end
@interface XQWheelVerticalView : UIView

@property(nonatomic,weak)id<WheelVerticalDelegate> delegate;

@property(nonatomic,strong)NSMutableArray * dataA;

- (void)stopTime;

- (void)startTime;

- (void)releaseTimer;

@end
