//
//  XQWheelVerticalLayout.h
//  XQWheel
//
//  Created by 小强 on 2018/6/30.
//  Copyright © 2018年 小强. All rights reserved.
//

#import <UIKit/UIKit.h>
#define UpDownScale     (3.0)

#define BothSpace       (30)

#define RepetNum         (5)
@interface XQWheelVerticalLayout : UICollectionViewFlowLayout

@property(nonatomic,assign)NSUInteger cellCount;

@property(nonatomic,assign)NSUInteger showNum;//设置可视范围显示的数目，不可大于实际数目，但可以小于，最好大于1；默认情况下是等于实际数目的
@property(nonatomic,assign)BOOL isUnWheel;

@end
