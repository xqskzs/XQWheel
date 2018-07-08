//
//  VerticalController.m
//  XQWheel
//
//  Created by 小强 on 2018/7/3.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "VerticalController.h"
#import "XQWheelVerticalView.h"

@interface VerticalController ()<WheelVerticalDelegate>

@property(nonatomic,strong)XQWheelVerticalView * verticalView;

@end

@implementation VerticalController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if(_verticalView)
//        [self.verticalView startTime];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [_verticalView stopTime];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewInit];
    // Do any additional setup after loading the view.
}

- (void)viewInit
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.verticalView];
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < 4 ; i ++) {
        XQWheelVerticalModel * md = [[XQWheelVerticalModel alloc] init];
        md.cover = [UIImage imageNamed:[NSString stringWithFormat:@"img%d",i + 3]];
        md.title = [NSString stringWithFormat:@"a啊快点减肥%d",i];
        [arr addObject:md];
    }
    self.verticalView.dataA = arr;
}

- (XQWheelVerticalView *)verticalView
{
    if(!_verticalView)
    {
        _verticalView = [[XQWheelVerticalView alloc] initWithFrame:CGRectMake(0, (HH - WHEEL_COLLECTIONV_H)/2, WW, WHEEL_COLLECTIONV_H)];
        _verticalView.delegate = self;
    }
    return _verticalView;
}

#pragma mark --------------- WheelVerticalDelegate
- (void)wheelView:(XQWheelVerticalView *)view model:(XQWheelVerticalModel *)model
{
    NSLog(@"++++++++++++++++++++V: %@",model.title);
}

- (void)dealloc
{
    [_verticalView releaseTimer];
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
