//
//  AppDelegate.m
//  NewCentury
//
//  Created by Stenson on 16/1/19.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#import "ZEAppDelegate.h"

#import "ZELoginViewController.h"

#import "ZEScanQRViewController.h"
#import "ZEHistoryViewController.h"
#import "ZEPointRegistrationVC.h"
#import "ZEPointAuditViewController.h"

#import "ZEMainViewController.h"

#import "ZEUserServer.h"
#import "ZESettingVC.h"
@interface ZEAppDelegate ()<UIAlertViewDelegate>

@end

@implementation ZEAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.applicationSupportsShakeToEdit = YES;
    NSLog(@"%@",Zenith_Server);
    NSLog(@"%@",NSHomeDirectory());
    /***** 检测更新  *****/
    [self checkUpdate];
    
    NSData *cookiesdata = [ZESettingLocalData getCookie];
    NSLog(@">>  %@",cookiesdata);
    if([cookiesdata length]) {
        ZEMainViewController * mainVC = [[ZEMainViewController alloc]init];
        mainVC.tabBarItem.title = @"首页";
        mainVC.tabBarItem.image = [UIImage imageNamed:@"icon_home"];
        UINavigationController * navVC = [[UINavigationController alloc]initWithRootViewController:mainVC];
        
        ZESettingVC * settingVC = [[ZESettingVC alloc]init];
        UINavigationController * settingNavVC = [[UINavigationController alloc]initWithRootViewController:settingVC];
        settingVC.tabBarItem.title = @"设置";
        settingVC.tabBarItem.image = [UIImage imageNamed:@"tab_setting_normal"];
        
        UITabBarController * tabBarVC = [[UITabBarController alloc]init];
        tabBarVC.viewControllers = @[navVC,settingNavVC];
        self.window.rootViewController = tabBarVC;
    }else{
        ZELoginViewController * loginVC = [[ZELoginViewController alloc]init];
        self.window.rootViewController = loginVC;
    }

    return YES;
}

-(void)checkUpdate
{
//    NSString* localVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    [ZEUserServer getVersionUpdateSuccess:^(id data) {
//        if ([ZEUtil isNotNull:data]) {
//            if([data objectForKey:@"data"]){
//                NSDictionary * dic = [data objectForKey:@"data"];
//                if ([localVersion floatValue] < [[dic objectForKey:@"versionName"] floatValue]) {
//                    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"经检测当前版本不是最新版本，点击确定跳转更新。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
//                    [alertView show];
//                }
//            }
//        }
//    } fail:^(NSError *errorCode) {
//        
//    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/id1103160566?mt=8"]];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
