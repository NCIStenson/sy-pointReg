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

#import "ZEPointRegistrationVC.h"
#import "ZELeaderRegVC.h"

#import "ZEPointRegCache.h"
#import "ZEEPM_TEAM_RATION_REGModel.h"

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
    [self.view sendSubviewToBack:_historyView];
    
    _currentPage = 0;
    [_historyView canLoadMoreData];
    [self sendRequest];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewData:) name:kNotiRefreshHistoryView object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotiRefreshHistoryView object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

-(void)sendRequest
{
    NSDictionary * parametersDic = @{@"start":[NSString stringWithFormat:@"%ld",(long)_currentPage * 20],
                                     @"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"ENDDATE DESC",
                                     @"WHERESQL":@"(SYSCREATORID='#PSNNUM#' or ( ORGCODE IN (#TEAMORGCODES#) and '#PSNNUM#'='#PLURALIST#')) and suitunit='#SUITUNIT#'",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION_REG]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:_historyView animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:_historyView animated:YES];
                                 NSArray * dataArr = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RATION_REG];
                                 
                                 if ([ZEUtil isNotNull:dataArr] && dataArr.count > 0) {
                                     if (_currentPage == 0) {
                                         [_historyView reloadFirstView:dataArr];
                                     }else{
                                         [_historyView reloadView:dataArr];
                                     }
                                     if (dataArr.count%20 == 0) {
                                         _currentPage += 1;
                                     }
                                 }else{
                                     [_historyView reloadFirstView:dataArr];
                                     [_historyView headerEndRefreshing];
                                     [_historyView loadNoMoreData];
                                 }
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:_historyView animated:YES];
                             }];
}

-(void)searchHistoryStartDate:(NSString *)startDate withEndDate:(NSString *)endDate
{
    [_historyView showAlertView:YES];
    NSString * whereSQL = [NSString stringWithFormat:@"(SYSCREATORID='#PSNNUM#' or ( ORGCODE IN (#TEAMORGCODES#) and '#PSNNUM#'='#PLURALIST#')) and suitunit='#SUITUNIT#' and enddate>=to_date('%@','yyyy-mm-dd') and enddate<=to_date('%@','yyyy-mm-dd')",startDate,endDate];

    NSDictionary * parametersDic = @{@"start":[NSString stringWithFormat:@"%ld",(long)_currentPage * 20],
                                     @"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"ENDDATE DESC",
                                     @"WHERESQL":whereSQL,
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION_REG]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:_historyView animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 NSLog(@">>>  %@",data);
                                 NSArray * dataArr = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RATION_REG];
                                 
                                 if ([ZEUtil isNotNull:dataArr] && dataArr.count > 0) {
                                     if(dataArr.count == 0){
                                         [_historyView headerEndRefreshing];
                                         [_historyView reloadFirstView:dataArr];
                                         [ZEUtil showAlertView:@"未查询到历史数据" viewController:self];
                                         return;
                                     }
                                     if (_currentPage == 0) {
                                         [_historyView reloadFirstView:dataArr];
                                     }else{
                                         [_historyView reloadView:dataArr];
                                     }
                                     if (dataArr.count%20 == 0) {
                                         _currentPage += 1;
                                     }
                                 }else{
                                     [_historyView reloadFirstView:dataArr];
                                     [_historyView headerEndRefreshing];
                                     [_historyView loadNoMoreData];
                                 }
                                 [MBProgressHUD hideHUDForView:_historyView animated:YES];

                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:_historyView animated:YES];
                             }];

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
        _startDate = @"";
    }else if ([endDate isEqualToString:@"结束日期"]){
        _endDate = @"";
    }
    [self searchHistoryStartDate:_startDate withEndDate:_endDate];

}

-(void)loadNewData:(ZEHistoryView *)hisView
{
    _isSearch = NO;
    _currentPage = 0;
    _startDate = @"null";
    _endDate = @"null";
    [self sendRequest];
}

-(void)loadMoreData:(ZEHistoryView *)hisView
{
    if (_isSearch) {
        [self searchHistoryStartDate:_startDate withEndDate:_endDate];
    }else{
        [self sendRequest];
    }
}

-(void)enterDetailView:(NSString *)seqkey
{
    NSDictionary * parametersDic = @{@"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"SYSCREATEDATE",
                                     @"WHERESQL":[NSString stringWithFormat:@"SEQKEY=%@",seqkey],
                                     @"METHOD":@"search",
                                     @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                     @"DETAILTABLE":EPM_TEAM_RATION_REG_DETAIL,
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"TASKID",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION_REG]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:_historyView animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:_historyView animated:YES];
                                 [self goChageVC:data];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:_historyView animated:YES];
                             }];

}

-(void)goChageVC:(NSDictionary *)dic
{
    ZEEPM_TEAM_RATION_REGModel * model = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:[ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG][0]];
    NSLog(@">>>  %@",model.SELF);
    if ([model.SELF isEqualToString:@"self"]) {
        NSLog(@"自己录入的");
        ZEPointRegistrationVC * pointRegVC = [[ZEPointRegistrationVC alloc]init];
        pointRegVC.regType = ENTER_PERSON_POINTREG_TYPE_HISTORY;
        pointRegVC.defaultDic = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG][0] ;
        pointRegVC.defaultDetailArr = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG_DETAIL];
        [self.navigationController pushViewController:pointRegVC animated:YES];
        
    }else if([model.SELF isEqualToString:@"leader"]){
        NSLog(@"负责人录入");
    }else{
        NSLog(@" 班组长录入 ");
        ZELeaderRegVC * pointRegVC = [[ZELeaderRegVC alloc]init];
        pointRegVC.regType = ENTER_PERSON_POINTREG_TYPE_HISTORY;
        pointRegVC.defaultDic = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG][0] ;
        pointRegVC.defaultDetailArr = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG_DETAIL];
        [self.navigationController pushViewController:pointRegVC animated:YES];
        
    }
}

-(void)deleteHistory:(NSString *)seqkey
{
    NSDictionary * parametersDic = @{@"MASTERTABLE":EPM_TEAM_RATION_REG,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"WHERESQL":@"",
                                     @"METHOD":@"delete",
                                     @"DETAILTABLE":EPM_TEAM_RATION_REG_DETAIL,
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"TASKID",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{@"SEQKEY":seqkey};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION_REG]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    __block ZEHistoryViewController * safeSelf = self;
    
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 _currentPage = 0 ;
                                 if(_isSearch){
                                     [safeSelf searchHistoryStartDate:_startDate withEndDate:_endDate];
                                 }else{
                                     [safeSelf sendRequest];
                                 }
                                 
                                 
                             } fail:^(NSError *errorCode) {

                             }];
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
