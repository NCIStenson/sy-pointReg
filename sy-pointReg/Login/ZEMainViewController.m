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
    
    [self sendRequest];
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
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [mainView reloadHomeView:[ZEUtil getServerData:data withTabelName:UUM_FUNCTION]];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
    
    [[ZEPointRegCache instance]cacheShareType:self.view];
}

-(void)initView
{
    mainView = [[ZEMainView alloc]initWithFrame:self.view.frame];
    mainView.delegate = self;
    [self.view addSubview:mainView];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.tintColor = MAIN_NAV_COLOR;
    self.tabBarController.tabBar.hidden = NO;
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

-(void)goLeaderView
{
    ZELeaderRegVC * leaderVC = [[ZELeaderRegVC alloc]init];
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
    
    if (IS_IOS8) {
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
        
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"密码不能为空"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:@"取消", nil];
        [alertView show];
    }
    
    
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
