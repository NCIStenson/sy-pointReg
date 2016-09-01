//
//  ZESettingVC.m
//  WeiXueTang
//
//  Created by Stenson on 16/4/26.
//  Copyright © 2016年 Zenith Electronic Technology Co., Ltd. All rights reserved.
//

#import "ZESettingVC.h"
#import "ZEUserCenterVC.h"
#import "ZELoginViewController.h"
#import "ZEPointRegCache.h"

@interface ZESettingVC ()<UIAlertViewDelegate>

@end

@implementation ZESettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;

    [self initView];
    self.title = @"设置";
    [self disableLeftBtn];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden = NO;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.tabBarController.tabBar.hidden = YES;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.tabBarController.tabBar.hidden = NO;
}

-(void)initView
{
    UIButton * userCenterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    userCenterBtn.frame = CGRectMake(-1, NAV_HEIGHT, SCREEN_WIDTH+2, 44);
    //    [userCenterBtn setBackgroundColor:MAIN_ARM_COLOR];
    userCenterBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft ;//设置文字位置，现设为居左，默认的是居中
    [userCenterBtn setTitle:@"    个人信息" forState:UIControlStateNormal];
    [userCenterBtn addTarget:self action:@selector(goUserCenter) forControlEvents:UIControlEventTouchUpInside];
    [userCenterBtn setTitleColor:MAIN_NAV_COLOR forState:UIControlStateNormal];
    [self.view addSubview:userCenterBtn];
    userCenterBtn.layer.borderColor = [MAIN_LINE_COLOR CGColor];
    userCenterBtn.layer.borderWidth = 1;
    
    UIButton * logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.frame = CGRectMake(0, NAV_HEIGHT + 55, SCREEN_WIDTH, 44);
    //    [userCenterBtn setBackgroundColor:MAIN_ARM_COLOR];
    logoutBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft ;//设置文字位置，现设为居左，默认的是居中
    [logoutBtn setTitle:@"    退出登录" forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [logoutBtn setTitleColor:MAIN_NAV_COLOR forState:UIControlStateNormal];
    [self.view addSubview:logoutBtn];
    logoutBtn.layer.borderColor = [MAIN_LINE_COLOR CGColor];
    logoutBtn.layer.borderWidth = 1;
}

-(void)goUserCenter
{
    ZEUserCenterVC * userCenterVC = [[ZEUserCenterVC alloc]init];
    [self.navigationController pushViewController:userCenterVC animated:YES];
}

-(void)logout{
    
    if (IS_IOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定退出登录？"
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
    [self progressBegin:@"正在退出登录"];
    [ZEUserServer logoutSuccess:^(id data) {
        [self progressEnd:nil];
        [self logoutSuccess];
    } fail:^(NSError *error) {
        [self progressEnd:nil];
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
