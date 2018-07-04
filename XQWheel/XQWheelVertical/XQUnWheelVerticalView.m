//
//  XQUnWheelVerticalView.m
//  XQWheel
//
//  Created by 小强 on 2018/7/3.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "XQUnWheelVerticalView.h"
#import "XQWheelVerticalLayout.h"
@interface XQUnWheelVerticalView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong)UICollectionView * collectionV;

@property(nonatomic,assign)NSUInteger curSelectedNum;
@property(nonatomic,assign)BOOL isSelectedDefault;
@property(nonatomic,strong)XQWheelVerticalCell * selectedCell;

@property(nonatomic,strong)XQWheelVerticalLayout * layout;

@end
@implementation XQUnWheelVerticalView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor blackColor];
        [self viewInit];
    }
    return self;
}

- (void)setDataA:(NSMutableArray *)dataA
{
    _dataA = [[NSMutableArray alloc] initWithArray:dataA];
    
    _layout.cellCount = _dataA.count;
    [self.collectionV reloadData];
}

- (void)viewInit
{
    [self addSubview:self.collectionV];
}

- (UICollectionView *)collectionV
{
    if(_collectionV == nil)
    {
        _layout = [[XQWheelVerticalLayout alloc] init];
        _layout.cellCount = _dataA.count;
        _layout.isUnWheel = YES;
        
        _collectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0 , WW, WHEEL_COLLECTIONV_H) collectionViewLayout:_layout];
        [_collectionV registerClass:[XQWheelVerticalCell class] forCellWithReuseIdentifier:@"XQWheelVerticalCell"];
        _collectionV.delegate = self;
        _collectionV.dataSource = self;
        _collectionV.backgroundColor = [UIColor clearColor];
        _collectionV.decelerationRate = .98;
    }
    return _collectionV;
}

- (void)rollBack
{
    CGFloat currentOffsetY = _collectionV.contentOffset.y;
    NSUInteger leastScaleNum = (int)(currentOffsetY/WHEEL_CELL_H);
    CGFloat moreY = currentOffsetY - leastScaleNum * WHEEL_CELL_H;
    if(moreY > 0)
    {
        if((moreY/WHEEL_CELL_H) <= 1/2.0)
        {
            [_collectionV setContentOffset:CGPointMake(0, leastScaleNum * WHEEL_CELL_H) animated:YES];
            [self judgeIsUpdate:leastScaleNum];
        }
        else if((moreY/WHEEL_CELL_H) > 1/2.0)
        {
            [_collectionV setContentOffset:CGPointMake(0, (leastScaleNum + 1) * WHEEL_CELL_H) animated:YES];
            [self judgeIsUpdate:leastScaleNum + 1];
        }
    }
    else
    {
        [self judgeIsUpdate:leastScaleNum];
    }
}

- (void)judgeIsUpdate:(NSUInteger)nextSelectedNum
{
    if(nextSelectedNum != _curSelectedNum)
    {
        _curSelectedNum = nextSelectedNum;
        [self updateShadow:nextSelectedNum];
    }
}

- (void)updateShadow:(NSUInteger)indexRow
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(XQ_KeyboardAnimation_Time * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   ^{
                       XQWheelVerticalCell * cell = (XQWheelVerticalCell *)[self.collectionV cellForItemAtIndexPath:[NSIndexPath indexPathForItem:indexRow inSection:0]];
                       if(self.selectedCell)
                       {
                           [self.selectedCell setShadow:0.0f];
                       }
                       if(self.selectedCell != cell)
                       {
                           self.selectedCell = cell;
                       }
                       [cell setShadow:1.0];
                   });
}

#pragma mark --------------- UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataA.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XQWheelVerticalCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XQWheelVerticalCell" forIndexPath:indexPath];
    [cell setInfoModel:_dataA[indexPath.row]];
    if(!_isSelectedDefault && indexPath.row == _dataA.count - 1)
    {
        _isSelectedDefault = YES;
        _selectedCell = cell;
        [cell setShadow:1.0f];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat currentOffsetY = _collectionV.contentOffset.y;
    NSUInteger leastScaleNum = (int)(currentOffsetY/WHEEL_CELL_H);
    CGFloat moreY = currentOffsetY - leastScaleNum * WHEEL_CELL_H;
    CGFloat needScaleNum = leastScaleNum + ((moreY > 0) ? 1 : 0);
    
    if(indexPath.row == (int)needScaleNum)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(wheelView:model:)])
        {
            [self.delegate wheelView:self model:_dataA[indexPath.row]];
        }
    }
    else
    {
        if(moreY > 0 && indexPath.row == ((int)needScaleNum - 1) && ((moreY/WHEEL_CELL_H) < 1.0/3.0))
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(wheelView:model:)])
            {
                [self.delegate wheelView:self model:_dataA[indexPath.row]];
            }
        }
        else
        {
            [_collectionV setContentOffset:CGPointMake(0, indexPath.row * WHEEL_CELL_H) animated:YES];
            [self judgeIsUpdate:indexPath.row];
        }
    }
}
#pragma mark --------------- UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if([scrollView isKindOfClass:[UICollectionView class]])
    {
        if(!decelerate)
        {
            [self rollBack];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if([scrollView isKindOfClass:[UICollectionView class]])
    {
        [self rollBack];
    }
    //    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}
@end
