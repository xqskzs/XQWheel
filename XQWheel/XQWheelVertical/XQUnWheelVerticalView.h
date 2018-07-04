//
//  XQUnWheelVerticalView.h
//  XQWheel
//
//  Created by 小强 on 2018/7/3.
//  Copyright © 2018年 小强. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XQWheelVerticalModel.h"
#import "XQWheelVerticalCell.h"

@class XQUnWheelVerticalView;
@protocol UnWheelVerticalDelegate<NSObject>

@optional

- (void)wheelView:(XQUnWheelVerticalView *)view model:(XQWheelVerticalModel *)model;

- (void)wheelView:(XQUnWheelVerticalView *)view selectedIndex:(NSUInteger)index;
@end
@interface XQUnWheelVerticalView : UIView

@property(nonatomic,weak)id<UnWheelVerticalDelegate> delegate;

@property(nonatomic,strong)NSMutableArray * dataA;

@end
