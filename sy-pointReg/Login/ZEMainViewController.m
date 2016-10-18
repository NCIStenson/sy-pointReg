//
//  ZEMainViewController.m
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年  Zenith Electronic Technology Co., Ltd. All rights reserved.
//

#import "ZEMainViewController.h"

#import "ZELeaderRegVC.h"
#import "ZEPointRegistrationVC.h"
#import "ZEHistoryViewController.h"
#import "ZEPointAuditViewController.h"
#import "ZEPointQueryVC.h"
#import "ZELoginViewController.h"
#import "ZEPointRegCache.h"

#import "SvUDIDTools.h"
@interface ZEMainViewController ()
{
    ZEMainView * mainView;
}
@end

@implementation ZEMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    [self initView];
    /***** 检测更新  *****/
    [self checkUpdate];
    [self storeSystemInfo];

    [self sendRequest];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.tabBarController.tabBar.tintColor = MAIN_NAV_COLOR;
    self.tabBarController.tabBar.hidden = NO;
}

-(void)storeSystemInfo
{
    NSDictionary * parametersDic = @{@"MASTERTABLE":SNOW_MOBILE_DEVICE,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"",
                                     @"WHERESQL":@"",
                                     @"start":@"0",
                                     @"limit":@"2000",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{@"IMEI":[SvUDIDTools UDID],
                                @"SEQKEY":@"",
                                @"LOGINTIMES":@""};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[SNOW_MOBILE_DEVICE]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 if([[ZEUtil getServerData:data withTabelName:SNOW_MOBILE_DEVICE] count] == 0){
                                     [self insertSystemInfo];
                                 }else{
                                     [self updateSystemInfo:[ZEUtil getServerData:data withTabelName:SNOW_MOBILE_DEVICE][0]];
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}
-(void)insertSystemInfo
{
    NSDictionary * parametersDic = @{@"MASTERTABLE":SNOW_MOBILE_DEVICE,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"",
                                     @"WHERESQL":@"",
                                     @"start":@"0",
                                     @"limit":@"20",
                                     @"METHOD":@"addSave",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSMutableDictionary * fieldsDic = [NSMutableDictionary dictionaryWithDictionary:[ZEUtil getSystemInfo]];
    [fieldsDic setObject:@"1" forKey:@"LOGINTIMES"];
    [fieldsDic setObject:@"true" forKey:@"ISENABLE"];
    [fieldsDic setObject:[ZEUtil getCurrentDate:@"YYYY-MM-dd"] forKey:@"FIRSTUSE"];
    [fieldsDic setObject:[ZEUtil getCurrentDate:@"YYYY-MM-dd"] forKey:@"LATESTUSE"];
    [fieldsDic setObject:[ZEUtil getCurrentDate:@"YYYY-MM-dd"] forKey:@"SYSCREATEDATE"];
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[SNOW_MOBILE_DEVICE]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 
                                 if([[ZEUtil getServerData:data withTabelName:SNOW_MOBILE_DEVICE] count] == 0){
                                     
                                 }else{
                                     
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
    

}

-(void)updateSystemInfo:(NSDictionary *)dic
{
    long loginTimes = [[dic objectForKey:@"LOGINTIMES"] integerValue];
    loginTimes += 1;
    
    NSDictionary * parametersDic = @{@"MASTERTABLE":SNOW_MOBILE_DEVICE,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"",
                                     @"WHERESQL":@"",
                                     @"start":@"0",
                                     @"limit":@"20",
                                     @"METHOD":@"updateSave",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSMutableDictionary * fieldsDic = [NSMutableDictionary dictionaryWithDictionary:@{@"IMEI":[SvUDIDTools UDID],
                                                                                      @"SEQKEY":[dic objectForKey:@"SEQKEY"],
                                                                                      @"LOGINTIMES":[NSString stringWithFormat:@"%ld",loginTimes],
                                                                                      @"LATESTUSE":[ZEUtil getCurrentDate:@"YYYY-MM-dd"],
                                                                                      @"SYSUPDATEDATE":[ZEUtil getCurrentDate:@"YYYY-MM-dd"]}];
    
    [fieldsDic setObject:[ZESettingLocalData getUSERNAME] forKey:@"USERACCOUNT"];
    [fieldsDic setObject:[ZESettingLocalData getNICKNAME] forKey:@"PSNNAME"];
    [fieldsDic setObject:[ZESettingLocalData getUSERCODE] forKey:@"PSNNUM"];

    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[SNOW_MOBILE_DEVICE]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 if([[ZEUtil getServerData:data withTabelName:SNOW_MOBILE_DEVICE] count] == 0){
                                     
                                 }else{
                                     
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];

}


-(void)checkUpdate
{
    NSDictionary * parametersDic = @{@"MASTERTABLE":SNOW_APP_VERSION,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"",
                                     @"WHERESQL":@"MOBILETYPE='2'",
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{@"MOBILETYPE":@"",
                                @"VERSIONCODE":@"",
                                @"VERSIONNAME":@"",
                                @"FILEURL":@"",
                                @"FILEURL2":@"",
                                @"TYPE":@""};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[SNOW_APP_VERSION]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 if ([[ZEUtil getServerData:data withTabelName:SNOW_APP_VERSION] count] > 0) {
                                     NSDictionary * dic = [ZEUtil getServerData:data withTabelName:SNOW_APP_VERSION][0];
                                     NSString* localVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
                                     if ([localVersion floatValue] < [[dic objectForKey:@"VERSIONNAME"] floatValue]) {
                                         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"经检测当前版本不是最新版本，点击确定跳转更新。" preferredStyle:UIAlertControllerStyleAlert];
                                         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                             [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dic objectForKey:@"FILEURL"]]];
                                         }];
                                         [alertController addAction:okAction];
                                         [self presentViewController:alertController animated:YES completion:nil];

                                     }
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
    
}

-(void)sendRequest
{
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":UUM_FUNCTION,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"ISPASS desc",
                                     @"WHERESQL":@"",
                                     @"start":@"0",
                                     @"METHOD":@"searchFun",
                                     @"MASTERFIELD":@"FUNCTIONID",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.biz.base.AppFunMenu",
                                     @"DETAILTABLE":@"",};
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[UUM_FUNCTION]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                       showAlertView:YES
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [mainView reloadHomeView:[ZEUtil getServerData:data withTabelName:UUM_FUNCTION]];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

-(void)initView
{
    mainView = [[ZEMainView alloc]initWithFrame:self.view.frame];
    mainView.delegate = self;
    [self.view addSubview:mainView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.tabBarController.tabBar.hidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - ZEMainViewDelegate

-(void)goLeaderView:(ENTER_MANYPERSON_POINTREG_TYPE)type
{
    ZELeaderRegVC * leaderVC = [[ZELeaderRegVC alloc]init];
    leaderVC.isLeaderOrCharge = type;
    [self.navigationController pushViewController:leaderVC animated:YES];
}

-(void)goPointReg
{
    ZEPointRegistrationVC * pointVC = [[ZEPointRegistrationVC alloc]init];
    pointVC.regType = ENTER_PERSON_POINTREG_TYPE_DEFAULT;
    [self.navigationController pushViewController:pointVC animated:YES];
}

-(void)goHistory
{
    ZEHistoryViewController * historyVC = [[ZEHistoryViewController alloc]init];
    [self.navigationController pushViewController:historyVC animated:YES];
}
-(void)goPointAudit
{
    ZEPointAuditViewController * pointAuditVC = [[ZEPointAuditViewController alloc]init];
    [self.navigationController pushViewController:pointAuditVC animated:YES];
}
-(void)goPointQuery
{
    ZEPointQueryVC * PointQueryVC = [[ZEPointQueryVC alloc]init];
    [self.navigationController pushViewController:PointQueryVC animated:YES];
}

-(void)logout{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"切换账号需重新登录？"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                           [self requestLogout];
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
-(void)requestLogout
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer logoutSuccess:^(id data) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //        if ([ZEUtil isSuccess:[data objectForKey:@"RETMSG"]]) {
        [self logoutSuccess];
        //        }
    } fail:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
}

-(void)logoutSuccess
{
    [ZESettingLocalData clearLocalData];
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    
    ZELoginViewController * loginVC = [[ZELoginViewController alloc]init];
    keyWindow.rootViewController = loginVC;
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
