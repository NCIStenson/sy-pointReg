//
//  ZEPointAuditViewController.m
//  NewCentury
//
//  Created by Stenson on 16/2/17.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEPointAuditViewController.h"
#import "ZEUserServer.h"
#import "MBProgressHUD.h"
#import "ZEAuditViewController.h"

#import "ZEEPM_TEAM_RATION_REGModel.h"

#import "ZEPointRegistrationVC.h"

#import "ZELeaderRegVC.h"
#import "ZEPointRegCache.h"

@interface ZEPointAuditViewController ()
{
    ZEPointAuditView * _pointAuditView;
    ZEEPM_TEAM_RATION_REGModel * _pointAuditM;
    NSInteger _currentPage;
}
@end

@implementation ZEPointAuditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currentPage = 0;
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
    [self sendRequest];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(auditRefreshView) name:kNotiRefreshAuditView object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiRefreshAuditView object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[ZEPointRegCache instance] cacheShareType:self.view];
}
#pragma mark - initView
-(void)initView
{
    _pointAuditView = [[ZEPointAuditView alloc]initWithFrame:self.view.frame];
    _pointAuditView.delegate = self;
    [self.view addSubview:_pointAuditView];
}

#pragma mark - SendRequest

-(void)auditRefreshView
{
    _currentPage = 0;
    [self sendRequest];
}

/******  审核列表   ****/
-(void)sendRequest
{
    NSDictionary * parametersDic = @{@"start":[NSString stringWithFormat:@"%ld",(long)_currentPage * 20],
                                     @"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"ENDDATE",
                                     @"WHERESQL":@"(SYSCREATORID='#PSNNUM#' or ( ORGCODE IN (#TEAMORGCODES#) and '#PSNNUM#'='#PLURALIST#')) and suitunit='#SUITUNIT#' and status in ('10')",
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
    [MBProgressHUD showHUDAddedTo:_pointAuditView animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:_pointAuditView animated:YES];
                                 NSArray * dataArr = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RATION_REG];
                                 
                                 if ([ZEUtil isNotNull:dataArr] && dataArr.count > 0) {
                                     if (_currentPage == 0) {
                                         [_pointAuditView reloadFirstView:dataArr];
                                     }else{
                                         [_pointAuditView reloadView:dataArr];
                                     }
                                     if (dataArr.count%20 == 0) {
                                         _currentPage += 1;
                                     }
                                 }else{
                                     if (_currentPage > 0) {
                                         [_pointAuditView loadNoMoreData];
                                         return ;
                                     }
                                     [_pointAuditView reloadFirstView:dataArr];
                                     [_pointAuditView headerEndRefreshing];
                                     [_pointAuditView loadNoMoreData];
                                 }
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:_pointAuditView animated:YES];
                             }];
}


#pragma mark - ZEPointAuditDelegate

-(void)loadNewData:(ZEPointAuditView *)hisView
{
    _currentPage = 0;
    [self sendRequest];
}

-(void)loadMoreData:(ZEPointAuditView *)hisView
{
    [self sendRequest];
}
-(void)goAuditVC
{
    ZEAuditViewController * auditVC = [[ZEAuditViewController alloc]init];
    [self presentViewController:auditVC animated:YES completion:nil];
}

-(void)deleteNoAuditHistory:(NSString *)seqkey
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
    __block ZEPointAuditViewController * safeSelf = self;
    
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 _currentPage = 0 ;
                                [safeSelf sendRequest];
                            } fail:^(NSError *errorCode) {
                                 
                             }];
}

-(void)enterDetailView:(NSString *)seqkey
{
    
    NSDictionary * parametersDic = @{@"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"SYSCREATEDATE",
                                     @"WHERESQL":[NSString stringWithFormat:@"SEQKEY=%@",seqkey],
                                     @"METHOD":@"search",
                                     @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                     @"DETAILTABLE":[NSString stringWithFormat:@"%@,%@",EPM_TEAM_RATION_REG_DETAIL,EPM_TEAM_RATION_REG_SX],
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"TASKID",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation"};
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION_REG]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:_pointAuditView animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:_pointAuditView animated:YES];
                                 [self getRationValue:seqkey withHistoryData:data];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:_pointAuditView animated:YES];
                             }];
    
}

-(void)getRationValue:(NSString *)seqkey withHistoryData:(NSDictionary *)hisData
{
    NSDictionary * parametersDic = @{@"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":[NSString stringWithFormat:@"SEQKEY=%@",seqkey],
                                     @"METHOD":@"search",
                                     @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                     @"DETAILTABLE":EPM_TEAM_RATIONTYPEVALUE,
                                     @"MASTERFIELD":@"RATIONCODE,SUITUNIT",
                                     @"DETAILFIELD":@"RATIONCODE,SUITUNIT",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation"};
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION_REG]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:_pointAuditView animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:_pointAuditView animated:YES];
                                 [self goChageVC:hisData rationValueArr:[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPEVALUE]];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:_pointAuditView animated:YES];
                             }];
}

-(void)goChageVC:(NSDictionary *)dic rationValueArr:(NSArray *)valueArr
{
    ZEEPM_TEAM_RATION_REGModel * model = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:[ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG][0]];
    
    if ([model.SELF isEqualToString:@"self"]) {
        ZEPointRegistrationVC * pointRegVC = [[ZEPointRegistrationVC alloc]init];
        pointRegVC.regType = ENTER_PERSON_POINTREG_TYPE_HISTORY;
        pointRegVC.defaultDic = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG][0] ;
        pointRegVC.defaultDetailArr = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG_DETAIL];
        pointRegVC.recordLengthArr = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG_SX];
        pointRegVC.rationTypeValueArr = valueArr;
        [self.navigationController pushViewController:pointRegVC animated:YES];
    }else if([model.SELF isEqualToString:@"leader"]){
        ZELeaderRegVC * pointRegVC = [[ZELeaderRegVC alloc]init];
        pointRegVC.regType = ENTER_PERSON_POINTREG_TYPE_HISTORY;
        pointRegVC.isLeaderOrCharge = ENTER_MANYPERSON_POINTREG_TYPE_CHARGE;
        pointRegVC.defaultDic = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG][0] ;
        pointRegVC.defaultDetailArr = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG_DETAIL];
        pointRegVC.recordLengthArr = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG_SX];
        pointRegVC.rationTypeValueArr = valueArr;
        [self.navigationController pushViewController:pointRegVC animated:YES];
    }else{
        ZELeaderRegVC * pointRegVC = [[ZELeaderRegVC alloc]init];
        pointRegVC.regType = ENTER_PERSON_POINTREG_TYPE_HISTORY;
        pointRegVC.isLeaderOrCharge = ENTER_MANYPERSON_POINTREG_TYPE_LEADER;
        pointRegVC.defaultDic = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG][0] ;
        pointRegVC.defaultDetailArr = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG_DETAIL];
        pointRegVC.recordLengthArr = [ZEUtil getServerData:dic withTabelName:EPM_TEAM_RATION_REG_SX];
        pointRegVC.rationTypeValueArr = valueArr;
        [self.navigationController pushViewController:pointRegVC animated:YES];
    }
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
