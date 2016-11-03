//
//  ZEPointQueryVC.m
//  sy-pointReg
//
//  Created by Stenson on 16/9/11.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEPointQueryVC.h"

#import "ZEPointQueryView.h"

#import "ZEPointSearchVC.h"

@interface ZEPointQueryVC ()
{
    ZEPointQueryView * _pointQueryView;
}
@end

@implementation ZEPointQueryVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"工时查看";
    [self initView];
    [self sendRequest];
    [self sendDetailRequest];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goSearch) name:kNOTISEARCHPOINT object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTISEARCHPOINT object:nil];
}

-(void)goSearch
{
    ZEPointSearchVC * searchVC = [[ZEPointSearchVC alloc]init];
    
    [self.navigationController pushViewController:searchVC animated:YES];
}

-(void)initView
{
    _pointQueryView = [[ZEPointQueryView alloc]initWithFrame:CGRectMake(0, NAV_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT)];
    
    [self.view addSubview:_pointQueryView];
}

-(void)sendRequest
{
    NSDictionary * parametersDic = @{@"start":@"0",
                                     @"limit":@"2000",
                                     @"MASTERTABLE":V_EPM_TEAM_RATION_REG_PERSUM,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"WHERESQL":[NSString stringWithFormat:@"psnnum='%@' and suitunit='SYBDYWS' AND PERIODCODE='%@'",[ZESettingLocalData getUSERCODE],[ZEUtil getCurrentMonth]],
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[V_EPM_TEAM_RATION_REG_PERSUM]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                       showAlertView:YES
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 if ([[ZEUtil getServerData:data withTabelName:V_EPM_TEAM_RATION_REG_PERSUM] count] > 0) {
                                     NSDictionary * dic = [ZEUtil getServerData:data withTabelName:V_EPM_TEAM_RATION_REG_PERSUM][0];
                                     [_pointQueryView reloadHeader:[NSString stringWithFormat:@"%@",[dic objectForKey:@"SUMPOINTS"]]
                                                       withTimeStr:[NSString stringWithFormat:@"%@",[dic objectForKey:@"QUOTIETY4"]]];
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];

}

-(void)sendDetailRequest
{    
    NSDictionary * parametersDic = @{@"start":@"0",
                                     @"limit":@"2000",
                                     @"MASTERTABLE":EPM_TEAM_RATION_REG_DETAIL,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"WHERESQL":[NSString stringWithFormat:@"psnnum='#PSNNUM#' and suitunit='#SUITUNIT#' AND PERIODCODE='%@'",[ZEUtil getCurrentMonth]],
                                     @"ORDERSQL":@"ENDDATE DESC",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION_REG_DETAIL]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [ZEUserServer getDataWithJsonDic:packageDic
                       showAlertView:YES
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 if ([[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATION_REG_DETAIL] count] > 0) {
                                     [_pointQueryView reloadContentData:[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATION_REG_DETAIL]];
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];

}


@end
