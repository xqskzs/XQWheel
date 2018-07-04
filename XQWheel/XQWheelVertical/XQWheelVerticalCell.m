//
//  XQWheelVerticalCell.m
//  XQWheel
//
//  Created by 小强 on 2018/6/30.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "XQWheelVerticalCell.h"
@interface XQWheelVerticalCell()
@property(nonatomic,strong)UIImageView * imgV;
@property(nonatomic,strong)UIView * coverV;
@property(nonatomic,strong)UILabel * titleL;
@property(nonatomic,strong)XQWheelVerticalModel * model;

@end
@implementation XQWheelVerticalCell

- (void)setInfoModel:(XQWheelVerticalModel *)model
{
    if(!_model)
    {
        [self viewInit];
    }
    [self dataInit:model];
}

- (void)viewInit
{
    _imgV = [[UIImageView alloc] init];
    _imgV.layer.masksToBounds = YES;
    _imgV.contentMode = UIViewContentModeScaleAspectFill;
    
    self.contentView.layer.shadowColor = UIColorHexadecimal(0x00adc3).CGColor;
    self.contentView.layer.shadowOpacity = 0.0f;
    self.contentView.layer.shadowRadius = XQ_CONST_NUM_THREE;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    
    _coverV = [[UIView alloc] init];
    _coverV.backgroundColor = [UIColor blackColor];
    _coverV.alpha = 0.7;
    _coverV.autoresizingMask = UIViewAutoresizingNone;
    
    _titleL = [[UILabel alloc] init];
    _titleL.textAlignment = NSTextAlignmentCenter;
    _titleL.font = XQ_FONT(16);
    _titleL.textColor = [UIColor whiteColor];
    _titleL.autoresizingMask = UIViewAutoresizingNone;
    
    [self.contentView addSubview:_imgV];
    [self.contentView addSubview:_coverV];
    [self.contentView addSubview:_titleL];
}

- (void)setShadow:(CGFloat)opacityNum
{
    self.contentView.layer.shadowOpacity = opacityNum;
}

- (void)dataInit:(XQWheelVerticalModel *)model
{
    _model = model;
    CGFloat coverVH = 30;
    
    [self.imgV makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(0);
        make.bottom.equalTo(0);
    }];
    
    [self addImage:model.cover imageView:self.imgV];
    
    [self.coverV makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(0);
        make.bottom.equalTo(0);
        make.height.equalTo(coverVH);
    }];
    
    [self.titleL makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(XQ_CONST_NUM_TEN);
        make.right.equalTo(- XQ_CONST_NUM_TEN);
        make.bottom.equalTo(0);
        make.height.equalTo(coverVH);
    }];

    _titleL.text = model.title;
}

- (void)addImage:(id)object imageView:(UIImageView *)imgV
{
    if([object isKindOfClass:[UIImage class]])
    {
        imgV.image = object;
        return;
    }
    if([object isKindOfClass:[NSURL class]])
    {
        [imgV sd_setImageWithURL:object placeholderImage:[UIImage imageNamed:@"ev_square_default"]];
        return;
    }
    if([object isKindOfClass:[NSString class]])
    {
        [imgV sd_setImageWithURL:[NSURL URLWithString:object] placeholderImage:[UIImage imageNamed:@"ev_square_default"]];
    }
}
@end
