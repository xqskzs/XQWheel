//
//  XQWheelVerticalView.m
//  XQWheel
//
//  Created by 小强 on 2018/6/30.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "XQWheelVerticalView.h"
#import "XQWheelVerticalLayout.h"
static const float TimeSecond = 2.5;
@interface XQWheelVerticalView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong)UICollectionView * collectionV;

@property(nonatomic,assign)NSUInteger curSelectedNum;
@property(nonatomic,assign)CGFloat min_offsetY;
@property(nonatomic,assign)CGFloat max_offsetY;
@property(nonatomic,assign)CGFloat min_out_offsetY;
@property(nonatomic,assign)CGFloat max_out_offsetY;
@property(nonatomic,assign)NSUInteger infactNum;

@property(nonatomic,strong)XQWheelVerticalLayout * layout;

@property(nonatomic,strong)dispatch_source_t timer;//有这个资源事件在，这个类不会调用dealloc这个方法，所以我在它所在的控制器的dealloc方法里释放了它就可以了

@property(nonatomic,assign)BOOL isBeginDragging;
@property(nonatomic,assign)BOOL isStartTime;
@property(nonatomic,assign)BOOL isRoll;
@end
@implementation XQWheelVerticalView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor blackColor];
        [self viewInit];
        [self timerInit];
    }
    return self;
}

- (void)setDataA:(NSMutableArray *)dataA
{
    _dataA = [[NSMutableArray alloc] initWithArray:dataA];
    
    _infactNum = _dataA.count;
    NSArray * arr = [[NSArray alloc] initWithArray:_dataA];
    for (int j = 0 ; j < RepetNum * 2 ; j ++) {
        [_dataA addObjectsFromArray:arr];
    }
    _min_offsetY = (_infactNum * RepetNum - 1) * WHEEL_CELL_H;
    _max_offsetY = (_infactNum * (RepetNum + 1) - 1) * WHEEL_CELL_H;
    
    _min_out_offsetY = (_infactNum - 1) * WHEEL_CELL_H;
    _max_out_offsetY = (RepetNum * 2 * _infactNum - 1) * WHEEL_CELL_H;
    
    _layout.cellCount = _dataA.count;
    [self.collectionV reloadData];
    [self->_collectionV setContentOffset:CGPointMake(0, self.max_offsetY) animated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TimeSecond * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startTime];
    });
}

- (void)viewInit
{
    [self addSubview:self.collectionV];
}

- (void)timerInit
{
     dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_queue_t mainQueue = dispatch_get_main_queue();
     _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
     dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, TimeSecond * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
     dispatch_source_set_event_handler(_timer, ^{
         dispatch_async(mainQueue, ^{
             [self loopPlay];
         });
    });
    dispatch_source_set_cancel_handler(_timer, ^{
        NSLog(@"I've already released it");
    });
}

- (void)loopPlay
{
    CGFloat currentY = self.collectionV.contentOffset.y;
    NSUInteger num = currentY/(int)WHEEL_CELL_H;//由于WHEEL_CELL_H小数点后面可能不是只舍，导致currentY不能整除，WHEEL_CELL_H累加之后大于真实的currentY；所以我给WHEEL_CELL_H取整了，或者给currentY加一个比较小的数用来抵消这个误差。
    [self.collectionV setContentOffset:CGPointMake(0, (num + 1) * WHEEL_CELL_H) animated:YES];
}

- (void)stopTime
{
    if(_timer && _isStartTime)//dispatch_suspend和dispatch_resume必须成对出现
    {
        _isStartTime = NO;
        dispatch_suspend(self.timer);
    }
}

- (void)startTime
{
    if(_timer && !_isStartTime)
    {
        _isStartTime = YES;
        dispatch_resume(self.timer);
    }
}

- (void)releaseTimer
{
    if(_timer)
    {
        if(!_isStartTime)//dispatch_suspend和dispatch_resume必须成对出现,如果只有dispatch_suspend，释放的时候会崩
           [self startTime];
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (UICollectionView *)collectionV
{
    if(_collectionV == nil)
    {
        _layout = [[XQWheelVerticalLayout alloc] init];
        _layout.cellCount = _dataA.count;
        
        _collectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0 , WW, WHEEL_COLLECTIONV_H) collectionViewLayout:_layout];
        [_collectionV registerClass:[XQWheelVerticalCell class] forCellWithReuseIdentifier:@"XQWheelVerticalCell"];
        _collectionV.delegate = self;
        _collectionV.dataSource = self;
        _collectionV.backgroundColor = [UIColor clearColor];
        _collectionV.decelerationRate = .98;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_collectionV setContentOffset:CGPointMake(0, self.max_offsetY) animated:NO];
        });
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
            _isRoll = YES;
            [_collectionV setContentOffset:CGPointMake(0, leastScaleNum * WHEEL_CELL_H) animated:YES];
        }
        else if((moreY/WHEEL_CELL_H) > 1/2.0)
        {
            _isRoll = YES;
            [_collectionV setContentOffset:CGPointMake(0, (leastScaleNum + 1) * WHEEL_CELL_H) animated:YES];
        }
    }
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
        }
    }
}
#pragma mark --------------- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isBeginDragging = YES;
    [self stopTime];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if([scrollView isKindOfClass:[UICollectionView class]])
    {
        if(!decelerate)
        {
            NSLog(@"++++++++++++++++++++++==rollBack:");
//            scrollView.panGestureRecognizer.enabled = NO;//想通过这个限制用户滑动频繁，但觉得不自然，用户滑的不连贯所以去掉了
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
}


//第一道防线（手速过快并连续滑动会看到尽头，所以我加了第二道防线）
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if(_isBeginDragging)
    {
        [self startTime];
        _isBeginDragging = NO;
    }
    CGFloat currentY = scrollView.contentOffset.y;
    
    if(!(currentY >= _min_offsetY && currentY <= _max_offsetY))
    {
        CGFloat currentOffsetY = _collectionV.contentOffset.y;
        NSUInteger leastScaleNum = (int)(currentOffsetY/WHEEL_CELL_H);
        CGFloat moreY = currentOffsetY - leastScaleNum * WHEEL_CELL_H;
        if(moreY >= WHEEL_CELL_H/2)
            leastScaleNum = leastScaleNum + 1;
        if(currentY < _min_offsetY)
        {
            [scrollView setContentOffset:CGPointMake(0, (leastScaleNum + _infactNum) * WHEEL_CELL_H)];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0, (leastScaleNum - _infactNum) * WHEEL_CELL_H)];
        }
    }
}
//第二道防线（保证用户看不到尽头）
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentY = scrollView.contentOffset.y;
    
    if(!(currentY >= _min_out_offsetY && currentY <= _max_out_offsetY))
    {
        CGFloat currentOffsetY = _collectionV.contentOffset.y;
        NSUInteger leastScaleNum = (int)(currentOffsetY/WHEEL_CELL_H);
        CGFloat moreY = currentOffsetY - leastScaleNum * WHEEL_CELL_H;
        if(moreY >= WHEEL_CELL_H/2)
            leastScaleNum = leastScaleNum + 1;
        
        if(currentY < _min_out_offsetY)
        {
            [scrollView setContentOffset:CGPointMake(0, ((RepetNum - 1) * _infactNum + leastScaleNum) * WHEEL_CELL_H)];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0, (leastScaleNum - (RepetNum - 1) * _infactNum) * WHEEL_CELL_H)];
        }
        [self rollBack];
    }
}

- (void)dealloc
{
//    [self releaseTimer];
}

@end
