//
//  ZEHistoryViewController.m
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#import "ZEHistoryViewController.h"
#import "ZEHistoryView.h"
#import "MBProgressHUD.h"
#import "ZEUserServer.h"

#import "ZEHistoryDetailVC.h"
#import "ZEPointRegistrationVC.h"

#import "ZEPointRegCache.h"
#import "ZEPointRegModel.h"

@interface ZEHistoryViewController ()<ZEHistoryViewDelegate>
{
    ZEHistoryView * _historyView;
    NSInteger _currentPage;
    BOOL _isSearch;
    NSString * _startDate;
    NSString * _endDate;
}
@end

@implementation ZEHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    
    _historyView = [[ZEHistoryView alloc]initWithFrame:self.view.frame];
    _historyView.delegate = self;
    [self.view addSubview:_historyView];
    
    _currentPage = 0;
    [_historyView canLoadMoreData];
    [self sendRequest];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewData:) name:kNotiRefreshHistoryView object:nil];
}




-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotiRefreshHistoryView object:nil];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

-(void)sendRequest
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString * str = @"null";
//    [ZEUserServer getHistoryDataByStartDate:str
//                                    endDate:str
//                                       page:[NSString stringWithFormat:@"%ld",(long)_currentPage]
//                                 success:^(id data) {
//                                     if ([ZEUtil isNotNull:data]) {
//                                         NSArray * dataArr = [data objectForKey:@"data"];
//                                         if ([ZEUtil isNotNull:dataArr] && dataArr.count > 0) {
//                                             if (_currentPage == 0) {
//                                                 [_historyView reloadFirstView:dataArr];
//                                             }else{
//                                                 [_historyView reloadView:dataArr];
//                                             }
//                                             if (dataArr.count%20 == 0) {
//                                                 _currentPage += 1;
//                                             }
//                                         }else{
//                                             [_historyView reloadFirstView:dataArr];
//                                             [_historyView headerEndRefreshing];
//                                             [_historyView loadNoMoreData];
//                                         }
//                                     }
//                                     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//
//                                 }
//                                    fail:^(NSError *errorCode) {
//                                        [_historyView headerEndRefreshing];
//                                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//
//                                    }];
}

-(void)searchHistoryStartDate:(NSString *)startDate withEndDate:(NSString *)endDate
{
    [_historyView showAlertView:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [ZEUserServer getHistoryDataByStartDate:startDate
//                                    endDate:endDate
//                                       page:[NSString stringWithFormat:@"%ld",(long)_currentPage]
//                                    success:^(id data) {
//                                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                                        if ([ZEUtil isNotNull:data]) {
//                                            NSArray * dataArr = [data objectForKey:@"data"];                                            
//                                            if ([ZEUtil isNotNull:dataArr]) {
//                                                if(dataArr.count == 0){
//                                                    [_historyView headerEndRefreshing];
//                                                    [_historyView reloadFirstView:dataArr];
//                                                    [ZEUtil showAlertView:@"未查询到历史数据" viewController:self];
//                                                    return;
//                                                }
//                                                if (_currentPage == 0) {
//                                                    [_historyView reloadFirstView:dataArr];
//                                                }else{
//                                                    [_historyView reloadView:dataArr];
//                                                }
//                                                if (dataArr.count%20 == 0) {
//                                                    _currentPage += 1;
//                                                }
//                                            }
//                                        }
//    }
//                                       fail:^(NSError *errorCode) {
//                                           [_historyView headerEndRefreshing];
//                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    }];
}


#pragma mark - ZEHistoryViewDelegate

-(void)beginSearch:(ZEHistoryView *)hisView withStartDate:(NSString *)startDate withEndDate:(NSString *)endDate
{
    if ([startDate isEqualToString:@"开始日期"]&&[endDate isEqualToString:@"结束日期"]) {
        [hisView showAlertView:YES];
        [ZEUtil showAlertView:@"请至少选择一个日期" viewController:self];
        return;
    }
    if ([ZEUtil compareDate:startDate withDate:endDate] == -1) {
        [ZEUtil showAlertView:@"开始日期不能晚于结束日期" viewController:self];
        [hisView showAlertView:YES];
        return;
    }
    _currentPage = 0;
    _isSearch    = YES;
    _startDate   = startDate;
    _endDate     = endDate;
    
    if ([startDate isEqualToString:@"开始日期"]) {
        _startDate = @"null";
    }else if ([endDate isEqualToString:@"结束日期"]){
        _endDate = @"null";
    }
    [self searchHistoryStartDate:_startDate withEndDate:_endDate];

}

-(void)loadNewData:(ZEHistoryView *)hisView
{
    _isSearch = NO;
    _currentPage = 0;
    _startDate = @"null";
    _endDate = @"null";
    [self searchHistoryStartDate:@"null" withEndDate:@"null"];
}

-(void)loadMoreData:(ZEHistoryView *)hisView
{
    if (_isSearch) {
        [self searchHistoryStartDate:_startDate withEndDate:_endDate];
    }else{
        [self sendRequest];
    }
}

-(void)enterDetailView:(ZEHistoryModel *)hisMod
{
    if ([hisMod.TT_FLAG isEqualToString:@"未审核"]) {
        
        NSMutableDictionary * historyDic = [NSMutableDictionary dictionary];
        
        [historyDic setObject:hisMod.TT_ENDDATE forKey:[ZEUtil getPointRegField:POINT_REG_TIME]];
        [historyDic setObject:hisMod.NDXS forKey:@"ndxs"];
        [historyDic setObject:hisMod.TT_HOUR forKey:@"hour"];
        [historyDic setObject:hisMod.TT_TASK forKey:@"woekername"];
//        [historyDic setObject:[ZESetLocalData getUsername] forKey:@"username"];
        [historyDic setObject:hisMod.seqkey forKey:@"sqlkey"];
        [historyDic setObject:hisMod.DISPATCH_TYPE forKey:@"shareType"];
        [historyDic setObject:hisMod.SJXS forKey:@"sjxs"];
        [historyDic setObject:hisMod.REAL_HOUR forKey:@"allScore"];
        

        if ([hisMod.DISPATCH_TYPE integerValue] == 4) {
            [historyDic setObject:hisMod.TTP_QUOTIETY forKey:@"workRoleScore"];
        }
        [historyDic setObject:hisMod.SJXSScore  forKey:@"sjxsScore"];
        [historyDic setObject:hisMod.NDXSScore  forKey:@"ndxsScore"];

        if ([ZEUtil isNotNull:hisMod.TIMES]) {
            [historyDic setObject:hisMod.TIMES forKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]];
        }else{
            [historyDic setObject:@"1" forKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]];
        }
        if ([ZEUtil isNotNull:hisMod.TWR_ID]) {
            [historyDic setObject:hisMod.TWR_ID forKey:@"twr_id"];
        }else{
            [historyDic setObject:@"" forKey:@"twr_id"];
        }
        
        if ([ZEUtil isNotNull:hisMod.ROLENAME] && [ZEUtil isNotNull:hisMod.TTP_QUOTIETY]) {
            [historyDic setObject:hisMod.ROLENAME forKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]];

        }else{
            [historyDic setObject:@"" forKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]];
        }

        [[ZEPointRegCache instance] setResubmitCaches:historyDic];

        ZEPointRegistrationVC * pointRegVC = [[ZEPointRegistrationVC alloc]init];
        pointRegVC.enterType               = ENTER_POINTREG_TYPE_HISTORY;
        pointRegVC.hisModel                = hisMod;
        [self presentViewController:pointRegVC animated:YES completion:nil];
    }else{
        ZEHistoryDetailVC * detailVC = [[ZEHistoryDetailVC alloc]init];
        detailVC.model = hisMod;
        detailVC.enterType = ENTER_FIXED_POINTREG_TYPE_HIS;
        [self presentViewController:detailVC animated:YES completion:nil];
    }
}


-(void)deleteHistory:(NSString *)seqkey
{
    __block ZEHistoryViewController * safeSelf = self;
//    [ZEUserServer deleteHistoryItem:seqkey success:^(id data) {
//        if ([ZEUtil isNotNull:data]) {
//            if ([[data objectForKey:@"data"] integerValue] == 1) {
//                _currentPage = 0 ;
//                if(_isSearch){
//                    [safeSelf searchHistoryStartDate:_startDate withEndDate:_endDate];
//                }else{
//                    [safeSelf sendRequest];
//                }
//            }else{
//                [ZEUtil showAlertView:@"删除失败，请重试" viewController:self];
//            }
//        }
//    } fail:^(NSError *errorCode) {
//        
//    }];
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
