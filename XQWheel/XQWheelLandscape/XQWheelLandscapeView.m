//
//  XQWheelLandscapeView.m
//  XQWheel
//
//  Created by 小强 on 2018/6/30.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "XQWheelLandscapeView.h"
#import "UIImageView+WebCache.h"

static const NSTimeInterval kDefaultPagingInterval = 2.5;
static const CGFloat kPageControlHeight            = 37.0;
static const CGFloat kPageControlEachWidth         = 16.0;


@interface XQWheelLandscapeView()<UIScrollViewDelegate>

/** UIScrollView */
@property (strong, nonatomic) UIScrollView *scrollView;

/** 指示器 */
@property (strong, nonatomic) UIPageControl *pageControl;

/** 定时器 */
@property (strong, nonatomic) NSTimer *pagingTimer;

/** 是否自动滚动 */
@property (assign, nonatomic, getter=isAutoPaging) BOOL autoPaging;

/** 左边的 imageView */
@property (strong, nonatomic) UIImageView *leftImageView;

/** 当前的 imageView */
@property (strong, nonatomic) UIImageView *currentImageView;

/** 右边的 imageView */
@property (strong, nonatomic) UIImageView *rightImageView;

@end

@implementation XQWheelLandscapeView

#pragma mark - Init

// 使用代码创建
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self makeUI];
    }
    return self;
}

// 从 Storyboard/Xib 加载
//- (void)awakeFromNib {
//    [self makeUI];
//}

- (void)makeUI {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = NO; // 初始化时先设置为 NO，有 >1 张图片时才设置为 YES
    self.scrollView.bounces = NO; // 取消弹簧效果，不然拖动（的确）会出现问题
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.hidesForSinglePage = YES; // 对于单个图片隐藏
    [self addSubview:self.pageControl];
    
    // 默认不开启自动切换图片
    self.autoPaging = NO;
    
    // 设置默认切图间隔
    self.pagingInterval = kDefaultPagingInterval;
    
    self.leftImageView = [[UIImageView alloc] init];
    self.leftImageView.clipsToBounds = YES;
    self.leftImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:self.leftImageView];
    
    self.currentImageView = [[UIImageView alloc] init];
    self.currentImageView.clipsToBounds = YES;
    self.currentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.currentImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCurrentImage:)];
    [self.currentImageView addGestureRecognizer:recognizer];
    [self.scrollView addSubview:self.currentImageView];
    
    self.rightImageView = [[UIImageView alloc] init];
    self.rightImageView.clipsToBounds = YES;
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:self.rightImageView];
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)didTapCurrentImage:(UITapGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wheelView:selectedIndex:)]) {
        [self.delegate wheelView:self selectedIndex:self.currentImageView.tag];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_imageURLs.count <= 1) return;
    
    // 设置UIPageControl的页码
    if (self.scrollView.contentOffset.x > self.scrollView.bounds.size.width * 1.5) {
        self.pageControl.currentPage = self.rightImageView.tag;
    } else if (self.scrollView.contentOffset.x < self.scrollView.bounds.size.width * 0.5) {
        self.pageControl.currentPage = self.leftImageView.tag;
    } else {
        self.pageControl.currentPage = self.currentImageView.tag;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 手动拖拽切换更改内容
    [self updateContent];
    if (self.isAutoPaging) {
        [self startTimer];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 定时器切换更改内容
    [self updateContent];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isAutoPaging) {
        [self stopTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isAutoPaging && !decelerate) {
        [self startTimer];
    }
}


#pragma mark - Private methods

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 因为外界可以动态改变frame，所以有关frame的设置都在layoutSubviews中设置
    
    // 设置子控件的frame
    self.scrollView.frame = self.bounds;
    
    CGFloat imageViewW = self.scrollView.bounds.size.width;
    CGFloat imageViewH = self.scrollView.bounds.size.height;
    
    self.leftImageView.frame = CGRectMake(0, 0, imageViewW, imageViewH);
    self.currentImageView.frame = CGRectMake(imageViewW, 0, imageViewW, imageViewH);
    self.rightImageView.frame = CGRectMake(imageViewW * 2, 0, imageViewW, imageViewH);
    
    // 设置UIScrollView滚动内容大小
    self.scrollView.contentSize = CGSizeMake(imageViewW * 3, 0);
    
    // 设置UIPageControl位置
    [self setPageControlPostion];
    
    [self updateContent];
}

/**
 * 设置页索引位置
 */
- (void)setPageControlPostion {
    CGFloat pageControlCenterX = 0;
    CGFloat pageControlCenterY = 0;
    pageControlCenterX = self.bounds.size.width - _imageURLs.count * kPageControlEachWidth / 2.0;
    pageControlCenterY = self.bounds.size.height - kPageControlHeight / 4.0;
    self.pageControl.center = CGPointMake(pageControlCenterX, pageControlCenterY);
}

/**
 * 开启定时器
 */
- (void)startTimer {
    if (_imageURLs.count <= 1) return;
    
    if (!self.pagingTimer) {
        // 注册定时器
        XQWeakSelf
        self.pagingTimer = [NSTimer timerWithTimeInterval:self.pagingInterval target:weakSelf selector:@selector(nextPage) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.pagingTimer forMode:NSRunLoopCommonModes];
    }
}

/**
 * 关闭定时器
 */
- (void)stopTimer {
    if (self.pagingTimer) {
        [self.pagingTimer invalidate];
        self.pagingTimer = nil;
    }
}

- (BOOL)isTimerRuning {
    return self.pagingTimer.isValid;
}

/**
 * 下一张
 */
- (void)nextPage {
    // 防止layoutSubviews中，第一次偏移量还没更改时就执行
    if (self.scrollView.contentOffset.x != 0) {
        // 移动到第三个UIImageView
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width * 2, 0) animated:YES];
    }
}

/**
 * 更新图片和索引数据
 */
- (void)updateContent {
    CGFloat scrollViewW = self.scrollView.bounds.size.width;
    
    if (_imageURLs.count <= 1)
    {
        [self.scrollView setContentOffset:CGPointMake(scrollViewW, 0) animated:NO];
        return;
    }
    
    if (self.scrollView.contentOffset.x > scrollViewW) {
        // 向前滚动，设置tag
        // 先设置左边的tag为当前图片tag后，才改变当前图片tag
        self.leftImageView.tag = self.currentImageView.tag;
        self.currentImageView.tag = self.rightImageView.tag;
        self.rightImageView.tag = (self.rightImageView.tag + 1) % _imageURLs.count;
        
    } else if (self.scrollView.contentOffset.x < scrollViewW) {
        // 向后滚动，设置tag
        // 先设置右边的tag为当前图片tag后，才改变当前图片tag
        self.rightImageView.tag = self.currentImageView.tag;
        self.currentImageView.tag = self.leftImageView.tag;
        self.leftImageView.tag = (self.leftImageView.tag - 1 + _imageURLs.count) % _imageURLs.count;
        
    }
    
    // 设置图片
    [self addImage:_imageURLs[self.leftImageView.tag] imageView:_leftImageView];
    [self addImage:_imageURLs[self.currentImageView.tag] imageView:_currentImageView];
    [self addImage:_imageURLs[self.rightImageView.tag] imageView:_rightImageView];
    
    // 移动至中间的UIImageView
    [self.scrollView setContentOffset:CGPointMake(scrollViewW, 0) animated:NO];
}


#pragma mark - Setters & public methods

-  (void)updateData {
    if (_imageURLs.count < 1) {
        return;
    }
    [self addImage:_imageURLs[0] imageView:_currentImageView];

    self.currentImageView.tag = 0;
    
    // 小于等于1张就不设置左右图片，2.3.4.5.6
    if (_imageURLs.count > 1) {
        [self addImage:_imageURLs[_imageURLs.count - 1] imageView:_leftImageView];
        [self addImage:_imageURLs[1] imageView:_rightImageView];
        self.leftImageView.tag = _imageURLs.count - 1;
        self.rightImageView.tag = 1;
    }
    
    //设置页数
    self.pageControl.numberOfPages = _imageURLs.count;
    
    // 设置显示中间的图片
    CGFloat imageViewW = self.scrollView.bounds.size.width;
    [self.scrollView setContentOffset:CGPointMake(imageViewW, 0)];
    
    // 设置UIPageControl位置
    [self setPageControlPostion];
    
    // 图片过少不能拖动
    self.scrollView.scrollEnabled = !(_imageURLs.count <= 1);
    
    // 下载完成重启定时器
    if (!self.isTimerRuning) {
        [self beginAutoPaging];
    }
}

- (void)setImageURLs:(NSArray *)imageURLs {
    _imageURLs = imageURLs;
    
    [self updateData];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setPagingInterval:(NSTimeInterval)pagingInterval {
    _pagingInterval = pagingInterval > 0 ? pagingInterval : kDefaultPagingInterval;
    
    // 在开启自动切图的情况下，修改时间间隔会实时生效
    if (self.isAutoPaging) {
        [self beginAutoPaging];
    }
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

/**
 *  开启自动切换图片
 */
- (void)beginAutoPaging {
    // 先停止正在执行的定时器
    [self stopTimer];
    
    self.autoPaging = YES;
    [self startTimer];
}

/**
 *  停止自动切换图片
 */
- (void)stopAutoPaging {
    self.autoPaging = NO;
    [self stopTimer];
}

- (void)dealloc
{
    if(self.pagingTimer)
    {
        [self.pagingTimer invalidate];
        self.pagingTimer = nil;
    }
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
