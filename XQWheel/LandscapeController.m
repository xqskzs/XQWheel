//
//  LandscapeController.m
//  XQWheel
//
//  Created by 小强 on 2018/7/3.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "LandscapeController.h"
#import "XQWheelLandscapeView.h"

@interface LandscapeController ()<WheelLandscapeDelegate>

@property(nonatomic,strong)XQWheelLandscapeView * landscapeView;

@property(nonatomic,strong)NSMutableArray * dataA;

@end

@implementation LandscapeController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_landscapeView)
        [_landscapeView beginAutoPaging];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_landscapeView stopAutoPaging];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dataInit];
    [self viewInit];
    // Do any additional setup after loading the view.
}

- (void)dataInit
{
    if(!_dataA)
        _dataA = [[NSMutableArray alloc] init];

    int num = arc4random() % 9 + 1;
    for (int i = 0 ; i < num ; i ++) {
        [_dataA addObject:[UIImage imageNamed:[NSString stringWithFormat:@"img%d",i + 1]]];
    }
}

- (void)viewInit
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.landscapeView];
}

- (XQWheelLandscapeView *)landscapeView
{
    if(!_landscapeView)
    {
        _landscapeView = [[XQWheelLandscapeView alloc] initWithFrame:CGRectMake(0, (HH - kPageScrollViewHeight)/2, WW, kPageScrollViewHeight)];
        _landscapeView.imageURLs = _dataA;
        [_landscapeView beginAutoPaging];
        _landscapeView.delegate = self;
    }
    return _landscapeView;
}

#pragma mark --------------- WheelLandscapeDelegate
- (void)wheelView:(XQWheelLandscapeView *)view selectedIndex:(NSUInteger)index
{
    NSLog(@"++++++++++++++++++++L: %ld",(long)index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
