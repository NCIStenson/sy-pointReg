//
//  AppDelegate.m
//  NewCentury
//
//  Created by Stenson on 16/1/19.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#import "ZEAppDelegate.h"

#import "ZELoginViewController.h"

#import "ZEHistoryViewController.h"
#import "ZEPointRegistrationVC.h"
#import "ZEPointAuditViewController.h"

#import "ZEMainViewController.h"

#import "ZEFormulaStringCalcUtility.h"

#import "ZEUserServer.h"
#import "ZESettingVC.h"

#import "SvUDIDTools.h"
@interface ZEAppDelegate ()<UIAlertViewDelegate>

@end

@implementation ZEAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.applicationSupportsShakeToEdit = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLogin) name:kRelogin object:nil];
 
    if([[ZESettingLocalData getUSERNAME] length] > 0 && [[ZESettingLocalData getUSERPASSWORD] length] > 0) {
        ZEMainViewController * mainVC = [[ZEMainViewController alloc]init];
        UINavigationController * navVC = [[UINavigationController alloc]initWithRootViewController:mainVC];
        
        self.window.rootViewController = navVC;
    }else{
        ZELoginViewController * loginVC = [[ZELoginViewController alloc]init];
        self.window.rootViewController = loginVC;
    }

    return YES;
}
//   强制使用系统输入法
//- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
//{
//    if ([extensionPointIdentifier isEqualToString:@"com.apple.keyboard-service"]) {
//        return NO;
//    }
//    return YES;
//}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kRelogin object:nil];;
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
    [self reLogin];
}

-(void)reLogin{
    if([ZESettingLocalData getUSERNAME].length > 0 && [ZESettingLocalData getUSERPASSWORD].length > 0){
        [self goLogin:[ZESettingLocalData getUSERNAME] password:[ZESettingLocalData getUSERPASSWORD]];
    }
}
-(void)goLogin:(NSString *)username password:(NSString *)pwd
{
    [ZEUserServer loginWithNum:username
                  withPassword:pwd
                       success:^(id data) {
                            if ([[data objectForKey:@"RETMSG"] isEqualToString:@"null"]) {
                               [ZESettingLocalData setUSERNAME:username];
                               [ZESettingLocalData setUSERPASSWORD:pwd];
                               [[NSNotificationCenter defaultCenter]postNotificationName:kVerifyLogin object:nil];
                           }else{
                               [ZESettingLocalData deleteCookie];
                               [ZESettingLocalData deleteUSERNAME];
                               [ZESettingLocalData deleteUSERPASSWORD];
                               [self goLoginVC:[data objectForKey:@"RETMSG"]];
                           }
                       } fail:^(NSError *errorCode) {
                       }];
}
-(void)goLoginVC:(NSString *)str
{
    ZELoginViewController * loginVC = [[ZELoginViewController alloc]init];
    self.window.rootViewController = loginVC;
    [ZEUtil showAlertView:str viewController:loginVC];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
