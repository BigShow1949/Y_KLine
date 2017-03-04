//
//  YStockChartViewController.m
//  BTC-Kline
//
//  Created by yate1996 on 16/4/27.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "Y_StockChartViewController.h"
#import "Masonry.h"
#import "Y_StockChartView.h"
#import "Y_StockChartView.h"
#import "NetWorking.h"
#import "Y_KLineGroupModel.h"
#import "UIColor+Y_StockChart.h"
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"

@interface Y_StockChartViewController ()<Y_StockChartViewDataSource>

@property (nonatomic, strong) Y_StockChartView *stockChartView;

@property (nonatomic, strong) Y_KLineGroupModel *groupModel;

@property (nonatomic, copy) NSMutableDictionary <NSString*, Y_KLineGroupModel*> *modelsDict;


@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, copy) NSString *type;

@end

@implementation Y_StockChartViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentIndex = -1;
    self.stockChartView.backgroundColor = [UIColor backgroundColor];
}

- (NSMutableDictionary<NSString *,Y_KLineGroupModel *> *)modelsDict
{
    if (!_modelsDict) {
        _modelsDict = @{}.mutableCopy;
    }
    return _modelsDict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of  nmthat can be recreated.
}

-(id) stockDatasWithIndex:(NSInteger)index
{
    NSString *type;
    switch (index) {
        case 0:
        {
            type = @"1min";
        }
            break;
        case 1:
        {
            type = @"1min";
        }
            break;
        case 2:
        {
            type = @"1min";
        }
            break;
        case 3:
        {
            type = @"5min";
        }
            break;
        case 4:
        {
            type = @"30min";
        }
            break;
        case 5:
        {
            type = @"h";
        }
            break;
        case 6:
        {
            type = @"d";
        }
            break;
        case 7:
        {
            type = @"w";
        }
            break;
            
        default:
            break;
    }
    
    self.currentIndex = index;
    self.type = type;
    if(![self.modelsDict objectForKey:type])
    {
        [self reloadData];
    } else {
        return [self.modelsDict objectForKey:type].models;
    }
    return nil;
}


- (void)reloadData
{
    //
    NSString *req_type = self.type;//@"d";
    NSString *req_freq = @"601888.SS";
    NSString *req_url = @"http://ichart.yahoo.com/table.csv?s=%@&g=%@";
    NSString *url = [[NSString alloc] initWithFormat:req_url,req_freq,req_type];
    NSURL *nurl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:nurl];
    [request setTimeOutSeconds:30];
    [request setCachePolicy:ASIUseDefaultCachePolicy];
    [request startSynchronous];
    // 加载完成执行此块
    [self Finished:request];
}

- (void)Finished:(ASIHTTPRequest *)request
{
    NSString *content = [request responseString];
    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:lines];
    [tempArr removeObjectAtIndex:0];// 第一个日期没用
    Y_KLineGroupModel *groupModel = [Y_KLineGroupModel objectWithArray:tempArr];
//
    self.groupModel = groupModel;
    [self.modelsDict setObject:groupModel forKey:self.type];
//    NSLog(@"%@",groupModel);
    [self.stockChartView reloadData];
}

//- (void)reloadData
//{
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    param[@"type"] = self.type;
//    param[@"symbol"] = @"huobibtccny";
//    param[@"size"] = @"300";
//    
//    [NetWorking requestWithApi:@"https://www.btc123.com/kline/klineapi" param:param thenSuccess:^(NSDictionary *responseObject) {
//        if ([responseObject[@"isSuc"] boolValue]) {
//            Y_KLineGroupModel *groupModel = [Y_KLineGroupModel objectWithArray:responseObject[@"datas"]];
//            
//            self.groupModel = groupModel;
//            [self.modelsDict setObject:groupModel forKey:self.type];
//            NSLog(@"%@",groupModel);
//            [self.stockChartView reloadData];
//        }
//        
//    } fail:^{
//        
//    }];
//}

- (Y_StockChartView *)stockChartView
{
    if(!_stockChartView) {
        _stockChartView = [Y_StockChartView new];
        _stockChartView.itemModels = @[
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"指标" type:Y_StockChartcenterViewTypeOther],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"分时" type:Y_StockChartcenterViewTypeTimeLine],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"1分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"5分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"30分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"60分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"日线" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"周线" type:Y_StockChartcenterViewTypeKline],
 
                                       ];
        _stockChartView.backgroundColor = [UIColor orangeColor];
        _stockChartView.dataSource = self;
        [self.view addSubview:_stockChartView];
        [_stockChartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        tap.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:tap];
    }
    return _stockChartView;
}
- (void)dismiss
{
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    appdelegate.isEable = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
- (BOOL)shouldAutorotate
{
    return NO;
}
@end
