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
#import "ZESumDeatilVC.h"

@interface ZEMemberHistoryListVC ()<ZEMemberHistoryListViewDelegate>
{
    ZEMemberHistoryListView * memberHistoryListView;
    
    NSMutableArray * _allMemberData;
}
@end

@implementation ZEMemberHistoryListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"班组查看";
    _allMemberData = [NSMutableArray array];
    [self initView];
    [self sendMemberRequest];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];    
}

-(void)initView{
    memberHistoryListView = [[ZEMemberHistoryListView alloc]initWithFrame:CGRectMake(0, NAV_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT) withType:_ORGCODE.length > 0 ? ENTER_MEMBERLIST_GROUP : ENTER_MEMBERLIST_MEMBER];
    memberHistoryListView.delegate = self;
    [self.view addSubview:memberHistoryListView];
    
    __block ZEMemberHistoryListVC * saveSelf = self;
    memberHistoryListView.block = ^(ZEEPM_TEAM_RATION_REGModel *model) {

        if ([model.SUMPOINTS floatValue] == 0) {
            model.PSNNUM = @"";
        }
        ZESumDeatilVC * sumDetailVC = [[ZESumDeatilVC alloc]init];
        sumDetailVC.PSNNUM = model.PSNNUM;
        sumDetailVC.PERIODCODE = model.PERIODCODE;
        [saveSelf.navigationController pushViewController:sumDetailVC animated:YES];
    };

}

-(void)sendMemberRequest
{
    NSString * WHERESQL = @"ORGCODE IN (#TEAMORGCODES#) and persontype like 'B%' AND ISASSESS='true'";
    if (_ORGCODE.length > 0) {
        NSString * sql = [NSString stringWithFormat:@"select orgcode from epm_base_suitunit_org where  (secorgcode is not null or orgcode='%@') connect by prior orgcode = parentorgcode start with orgcode='%@'",_ORGCODE,_ORGCODE];
        
        WHERESQL = [NSString stringWithFormat:@"ORGCODE IN (%@) and persontype like 'B%%' AND ISASSESS='true'",sql];
    }
    
    NSDictionary * parametersDic = @{@"start":@"0",
                                     @"limit":@"-1",
                                     @"MASTERTABLE":@"EPM_BASE_REL",
                                     @"MENUAPP":@"EMARK_APP",
                                     @"WHERESQL":WHERESQL,
                                     @"ORDERSQL":@"",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_BASE_REL]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                       showAlertView:YES
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 if ([[ZEUtil getServerData:data withTabelName:EPM_BASE_REL] count] > 0) {
                                     NSArray * arr = [ZEUtil getServerData:data withTabelName:EPM_BASE_REL];
                                     [_allMemberData addObjectsFromArray:arr];
                                 }
                                 [self sendRequest];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];

}

-(void)sendRequest
{
    NSString * WHERESQL = [NSString stringWithFormat:@"orgcode='#ORGCODE#' and suitunit='#SUITUNIT#' AND PERIODCODE='%@'",[ZEUtil getCurrentMonth]];
    if (_ORGCODE.length > 0) {
        WHERESQL = [NSString stringWithFormat:@"orgcode='%@' and suitunit='#SUITUNIT#' AND PERIODCODE='%@'",_ORGCODE,[ZEUtil getCurrentMonth]];
    }
    
    NSDictionary * parametersDic = @{@"start":@"0",
                                     @"limit":@"-1",
                                     @"MASTERTABLE":V_EPM_TEAM_RATION_REG_PERSUM,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"WHERESQL":WHERESQL,
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
                                if ([ZEUtil isSuccess:[data objectForKey:@"RETMSG"]]) {
                                     NSMutableArray * arr = [NSMutableArray arrayWithArray:[ZEUtil getServerData:data withTabelName:V_EPM_TEAM_RATION_REG_PERSUM]];
                                     
                                     for (int i = 0; i < _allMemberData.count; i ++) {
                                         BOOL isHave = NO;
                                         ZEEPM_TEAM_RATION_REGModel * allModel = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:_allMemberData[i]];
                                         NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:_allMemberData[i]];
                                         
                                         for (int j = 0; j < arr.count; j ++) {
                                             ZEEPM_TEAM_RATION_REGModel * alreadyHaveModel = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:arr[j]];
                                             if ([allModel.PSNNAME isEqualToString:alreadyHaveModel.PSNNAME]) {
                                                 isHave = YES;
                                                 break;
                                             }
                                         }
                                         
                                         if (!isHave) {
                                             [dic setObject:@"0" forKey:@"QUOTIETY4"];
                                             [dic setObject:@"0" forKey:@"SUMPOINTS"];
                                             
                                             [_allMemberData replaceObjectAtIndex:i withObject:dic];
                                             [arr addObject:_allMemberData[i]];
                                         }
                                     }
                                     
                                     [memberHistoryListView reloadContentData:arr];
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
    
}


-(void)goQueryMemberVC
{
    ZEQueryMemberQueryVC * queryMemberVC = [[ZEQueryMemberQueryVC alloc]init];
    queryMemberVC.ORGCODE = _ORGCODE;
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
