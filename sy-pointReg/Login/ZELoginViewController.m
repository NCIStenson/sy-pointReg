//
//  ZELoginViewController.m
//  NewCentury
//
//  Created by Stenson on 16/1/22.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZELoginViewController.h"
#import "MBProgressHUD.h"
#import "ZELoginView.h"

#import "ZEUserServer.h"

#import "ZEMainViewController.h"
#import "ZESettingVC.h"
#import "ZEPointRegCache.h"

@interface ZELoginViewController ()<ZELoginViewDelegate>

@end

@implementation ZELoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self initView];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

-(void)initView
{
    ZELoginView * loginView = [[ZELoginView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    loginView.delegate = self;
    [self.view addSubview:loginView];
}
#pragma mark - ZELoginViewDelegate

-(void)goLogin:(NSString *)username password:(NSString *)pwd
{
    if ([username isEqualToString:@""]) {
        [self initView];
        if (IS_IOS8) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"用户名不能为空" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }else{
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"用户名不能为空" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        return;
    }else if (![ZEUtil isStrNotEmpty:pwd]){
        [self initView];
        if (IS_IOS8) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"密码不能为空"
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                               style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }else{
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"密码不能为空"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"好的"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
        return;
    }

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer loginWithNum:username
                  withPassword:pwd
                       success:^(id data) {
                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                           if ([[data objectForKey:@"RETMSG"] isEqualToString:@"null"]) {
                               [ZESettingLocalData setUSERNAME:username];
                               [ZESettingLocalData setUSERPASSWORD:pwd];
                               [self cacheUserInfo];
                               [self getKValue];
                               [self goHome];
                           }else{
                               [ZESettingLocalData deleteCookie];
                               [ZESettingLocalData deleteUSERNAME];
                               [ZESettingLocalData deleteUSERPASSWORD];
                               [ZEUtil showAlertView:[data objectForKey:@"RETMSG"] viewController:self];
                           }
                       } fail:^(NSError *errorCode) {
                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                       }];
}

-(void)cacheUserInfo
{
    NSDictionary * parametersDic = @{@"limit":@"2000",
                                     @"MASTERTABLE":V_UUM_USER_ST,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":@"",
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{@"USERACCOUNT":[ZESettingLocalData getUSERNAME],
                                @"USERID":@"",
                                @"USERNAME":@"",
                                @"USERCODE":@"",
                                @"PLURALIST":@""};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[V_UUM_USER_ST]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 NSDictionary * userinfoDic= [ZEUtil getServerData:data withTabelName:V_UUM_USER_ST][0];
                                 
                                 if ([[userinfoDic objectForKey:@"USERCODE"] isEqualToString:[userinfoDic objectForKey:@"PLURALIST"]]) {
                                     [ZESettingLocalData setISLEADER:YES];
                                 }
                                 [ZESettingLocalData setUSERINFODic:userinfoDic];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kNOTICACHEUSERINFO object:nil];
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

#pragma mark - 获取K值系数

-(void)getKValue
{
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_K_VALUE,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":@"suitunit = '#SUITUNIT#'",
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    NSDictionary * fieldsDic =@{@"KVALUE":@""};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_K_VALUE]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 if ([[ZEUtil getServerData:data withTabelName:EPM_TEAM_K_VALUE] count] > 0) {
                                     NSDictionary * dic = [ZEUtil getServerData:data withTabelName:EPM_TEAM_K_VALUE][0];
                                     [ZESettingLocalData setKValue:[dic objectForKey:@"KVALUE"]];
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}


-(void)showAlertView:(NSString *)alertMes
{
   
    if (IS_IOS8) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:alertMes message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                           style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:alertMes
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)goHome
{
    ZEMainViewController * mainVC = [[ZEMainViewController alloc]init];
    mainVC.tabBarItem.title = @"首页";
    mainVC.tabBarItem.image = [UIImage imageNamed:@"icon_home"];
    UINavigationController * navVC = [[UINavigationController alloc]initWithRootViewController:mainVC];
    
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    keyWindow.rootViewController = navVC;
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
