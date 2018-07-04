//
//  XQWheelVerticalCell.h
//  XQWheel
//
//  Created by 小强 on 2018/6/30.
//  Copyright © 2018年 小强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XQWheelVerticalModel.h"
#import "XQWheelVerticalLayout.h"
#define WHEEL_CELL_W        (WW - BothSpace * 2)
#define WHEEL_CELL_H        (WHEEL_CELL_W/16*9)
#define WHEEL_COLLECTIONV_H      (WHEEL_CELL_H/(1 - 1/UpDownScale))
@interface XQWheelVerticalCell : UICollectionViewCell

- (void)setInfoModel:(XQWheelVerticalModel *)model;

- (void)setShadow:(CGFloat)opacityNum;
@end
