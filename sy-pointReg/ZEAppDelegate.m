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
    
    NSLog(@"%@",Zenith_Server);
    NSLog(@"%@",NSHomeDirectory());
    NSLog(@"%@",[SvUDIDTools UDID]);
 
    NSData *cookiesdata = [ZESettingLocalData getCookie];
    if([cookiesdata length]) {
        ZEMainViewController * mainVC = [[ZEMainViewController alloc]init];
        mainVC.tabBarItem.title = @"首页";
        mainVC.tabBarItem.image = [UIImage imageNamed:@"icon_home"];
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
