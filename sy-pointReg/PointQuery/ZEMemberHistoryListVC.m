//
//  ZEMemberHistoryListVC.m
//  sy-pointReg
//
//  Created by Stenson on 17/5/23.
//  Copyright © 2017年 Zenith Electronic. All rights reserved.
//

#import "ZEMemberHistoryListVC.h"
#import "ZEMemberHistoryListView.h"
#import "ZEQueryMemberQueryVC.h"
@interface ZEMemberHistoryListVC ()<ZEMemberHistoryListViewDelegate>
{
    ZEMemberHistoryListView * memberHistoryListView;
}
@end

@implementation ZEMemberHistoryListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"班长工时查看";
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self sendRequest];
}

-(void)initView{
    memberHistoryListView = [[ZEMemberHistoryListView alloc]initWithFrame:CGRectMake(0, NAV_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT)];
    memberHistoryListView.delegate = self;
    [self.view addSubview:memberHistoryListView];
}

-(void)sendRequest
{
    NSDictionary * parametersDic = @{@"start":@"0",
                                     @"limit":@"-1",
                                     @"MASTERTABLE":V_EPM_TEAM_RATION_REG_PERSUM,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"WHERESQL":[NSString stringWithFormat:@"orgcode='#ORGCODE#' and suitunit='#SUITUNIT#' AND PERIODCODE='%@'",[ZEUtil getCurrentMonth]],
                                     @"ORDERSQL":@"SUMPOINTS DESC",
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
                                     NSArray * arr = [ZEUtil getServerData:data withTabelName:V_EPM_TEAM_RATION_REG_PERSUM];
                                     [memberHistoryListView reloadContentData:arr];
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
    
}


-(void)goQueryMemberVC
{
    ZEQueryMemberQueryVC * queryMemberVC = [[ZEQueryMemberQueryVC alloc]init];
    [self.navigationController pushViewController:queryMemberVC animated:YES];
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
