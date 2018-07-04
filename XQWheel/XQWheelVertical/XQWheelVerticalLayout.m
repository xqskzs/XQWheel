//
//  XQWheelVerticalLayout.m
//  XQWheel
//
//  Created by 小强 on 2018/6/30.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "XQWheelVerticalLayout.h"

@interface XQWheelVerticalLayout()

@property(nonatomic,strong)NSMutableArray * cellLayoutList;

@property(nonatomic,assign)CGFloat cellWidth;

@property(nonatomic,assign)CGFloat cellHeight;

@property(nonatomic,assign)CGFloat collectionVH;

@property(nonatomic,assign)BOOL isFirst;

@property(nonatomic,assign)NSUInteger infactNum;

@end

@implementation XQWheelVerticalLayout

- (instancetype)init
{
    if(self = [super init])
    {
        _cellWidth = WW - 2 * BothSpace;
        _cellHeight = _cellWidth/16* 9;
        _collectionVH = _cellHeight/(1.0 - 1/UpDownScale);
        if(!_cellLayoutList)
            _cellLayoutList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setCellCount:(NSUInteger)cellCount
{
    _cellCount = cellCount;
    self.infactNum = _cellCount/(2 * RepetNum + 1);
    self.showNum = self.infactNum;
}

- (void)setShowNum:(NSUInteger)showNum
{
    if(showNum > self.infactNum)
        _showNum = self.infactNum;
    else
        _showNum = showNum;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    [self.cellLayoutList removeAllObjects];
    
    for (NSInteger row = 0 ; row < self.cellCount; row++) {
        UICollectionViewLayoutAttributes* attribute = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        [self.cellLayoutList addObject:attribute];
    }
}

- (CGSize)collectionViewContentSize
{
    //    NSLog(@"++++++++++++HHHH: %lf",[self getSizeY]);
    return CGSizeMake(self.collectionView.frame.size.width,[self getSizeY]);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes* attribute in self.cellLayoutList) {
        if (CGRectIntersectsRect(attribute.frame, rect)) {
            [array addObject:attribute];
        }
    }
    return array;
}

//每次手指滑动时，都会调用这个方法来返回每个cell的布局
-(UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getAttributesWhenMoreRows:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

#pragma mark - 私有方法

//布局
-(UICollectionViewLayoutAttributes*)getAttributesWhenMoreRows:(NSIndexPath*)indexPath
{
    if(!_isUnWheel)
        return [self dynamicAttributes:indexPath];
    else
        return [self staticAttributes:indexPath];
}

- (UICollectionViewLayoutAttributes *)dynamicAttributes:(NSIndexPath *)indexPath
{
    self.collectionView.bounces = NO;
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = CGSizeMake(_cellWidth, _cellHeight);
    
    CGFloat currentOffsetY = self.collectionView.contentOffset.y;
    NSUInteger leastScaleNum = (int)(currentOffsetY/_cellHeight);
    CGFloat moreY = currentOffsetY - leastScaleNum * _cellHeight;
    CGFloat needScaleNum = leastScaleNum + ((moreY > 0) ? 1 : 0);
    NSUInteger changeNum = self.showNum - 1;
    NSUInteger minScaleNum = leastScaleNum - changeNum;
    
    if(indexPath.row < needScaleNum)
    {
        CGFloat heightRange = _collectionVH / UpDownScale;

        CGFloat heightPart = heightRange / changeNum;
        CGFloat changeHeight;
        
        CGFloat scaleRange = _collectionVH / UpDownScale * 2 / _cellWidth;
        CGFloat startScale = 1 - scaleRange;
        CGFloat scalePart = scaleRange / changeNum;
        CGFloat scale;
        
        CGFloat offsetY = heightPart * (moreY/_cellHeight);
        CGFloat offsetScale = scalePart * (moreY/_cellHeight);

        changeHeight = (indexPath.row - minScaleNum) * heightPart - offsetY;

        scale = startScale + (indexPath.row - minScaleNum) * scalePart - offsetScale;

        if(indexPath.row > minScaleNum)
        {
            attributes.center = CGPointMake(WW/2, self.collectionView.contentOffset.y + _collectionVH / UpDownScale * (UpDownScale - 1) / 2 + changeHeight);
            attributes.transform = CGAffineTransformMakeScale(scale, scale);
        }
        else
        {
            attributes.center = CGPointMake(WW/2, self.collectionView.contentOffset.y + _collectionVH / UpDownScale * (UpDownScale - 1) / 2);
            scale = startScale - offsetScale;
            attributes.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
    else
    {
        attributes.frame = CGRectMake(BothSpace, _collectionVH / UpDownScale + indexPath.row * _cellHeight, _cellWidth, _cellHeight);
    }
    attributes.zIndex = 100 + indexPath.row;
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)staticAttributes:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = CGSizeMake(_cellWidth, _cellHeight);
    
    CGFloat currentOffsetY = self.collectionView.contentOffset.y;
    NSUInteger leastScaleNum = (int)(currentOffsetY/_cellHeight);
    CGFloat moreY = currentOffsetY - leastScaleNum * _cellHeight;
    CGFloat needScaleNum = leastScaleNum + ((moreY > 0) ? 1 : 0);
    
    if(indexPath.row < needScaleNum)
    {
        CGFloat heightRange = _collectionVH / UpDownScale;
        if(self.cellCount == needScaleNum)
        {
            heightRange = heightRange * ((_cellHeight/2 - moreY)/(_cellHeight/2));
        }
        CGFloat heightPart = heightRange / (currentOffsetY/_cellHeight);
        CGFloat changeHeight;
        
        CGFloat scaleRange = _collectionVH / UpDownScale * 2 / _cellWidth;
        CGFloat startScale = 1 - scaleRange;
        CGFloat scalePart = scaleRange / (currentOffsetY/_cellHeight);
        CGFloat scale;
        if(needScaleNum > 1)
        {
            changeHeight = indexPath.row * heightPart;
            if(self.cellCount == needScaleNum)
            {
                heightRange = heightRange * ((_cellHeight/2 - moreY)/(_cellHeight/2));
                scalePart = scalePart * ((_cellHeight/2 - moreY)/(_cellHeight/2));
                scale = startScale + indexPath.row * scalePart;
            }
            else
            {
                scale = startScale + indexPath.row * scalePart;
            }
        }
        else
        {
            CGFloat changeValue = _cellHeight - currentOffsetY;
            changeHeight = heightRange * (changeValue/_cellHeight);
            
            scale = startScale + scaleRange * (changeValue/_cellHeight);
        }
        
        attributes.center = CGPointMake(WW/2, self.collectionView.contentOffset.y + _collectionVH / UpDownScale * (UpDownScale - 1) / 2 + changeHeight);
        attributes.transform = CGAffineTransformMakeScale(scale, scale);
    }
    else
    {
        attributes.frame = CGRectMake(BothSpace, _collectionVH / UpDownScale + indexPath.row * _cellHeight, _cellWidth, _cellHeight);
    }
    
    attributes.zIndex = 100 + indexPath.row;
    
    return attributes;
}

-(CGFloat)getSizeY
{
    return (self.cellCount - 1) * _cellHeight + _collectionVH;
}
@end
