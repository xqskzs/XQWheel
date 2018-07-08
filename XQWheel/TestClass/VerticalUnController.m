//
//  VerticalUnController.m
//  XQWheel
//
//  Created by 小强 on 2018/7/3.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "VerticalUnController.h"
#import "XQUnWheelVerticalView.h"
@interface VerticalUnController ()<UnWheelVerticalDelegate>

@property(nonatomic,strong)XQUnWheelVerticalView * verticalUnView;

@end

@implementation VerticalUnController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewInit];
    // Do any additional setup after loading the view.
}

- (void)viewInit
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.verticalUnView];
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    int num = arc4random() % 6 + 4;
    for (int i = 0 ; i < num ; i ++) {
        XQWheelVerticalModel * md = [[XQWheelVerticalModel alloc] init];
        md.cover = [UIImage imageNamed:[NSString stringWithFormat:@"img%d",i + 1]];
        md.title = [NSString stringWithFormat:@"a啊快点减肥%d",i];
        [arr addObject:md];
    }
    self.verticalUnView.dataA = arr;
}

- (XQUnWheelVerticalView *)verticalUnView
{
    if(!_verticalUnView)
    {
        _verticalUnView = [[XQUnWheelVerticalView alloc] initWithFrame:CGRectMake(0, (HH - WHEEL_COLLECTIONV_H)/2, WW, WHEEL_COLLECTIONV_H)];
        _verticalUnView.delegate = self;
    }
    return _verticalUnView;
}

#pragma mark --------------- UnWheelVerticalDelegate
- (void)wheelView:(XQUnWheelVerticalView *)view model:(XQWheelVerticalModel *)model
{
    NSLog(@"++++++++++++++++++++V: %@",model.title);
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
