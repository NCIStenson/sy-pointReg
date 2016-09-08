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
//    NSString * sqrt = @"sqrtmethod11*4method2/4";
//    
//    NSRange resultRange = [sqrt rangeOfString:@"method1" options:NSBackwardsSearch range:NSMakeRange(0,sqrt.length)];
//    NSRange resultRange1 = [sqrt rangeOfString:@"method2" options:NSBackwardsSearch range:NSMakeRange(0,sqrt.length)];
//    NSRange sqrtRange = [sqrt rangeOfString:@"sqrtmethod1" options:NSBackwardsSearch range:NSMakeRange(0,sqrt.length)];
//    NSRange replaceRange = NSMakeRange(sqrtRange.location , resultRange1.location + resultRange1.length);
//    NSRange range = NSMakeRange(resultRange.location + resultRange.length, resultRange1.location - resultRange.location - resultRange.length);
//    
//    NSLog(@"%d  %d",replaceRange.location,replaceRange.length);
//    
//    NSString * resultStr = [sqrt substringWithRange:range];
//
//    NSString * resultSqrt = [sqrt stringByReplacingCharactersInRange:replaceRange withString:resultStr];
//    
//    NSLog( @"  %@  === %@ ",resultStr ,resultSqrt );
//
//    NSString * finalStr = @"1+[K]*([QUOTIETY4]-[STANDARDOPERATIONTIME])/[STANDARDOPERATIONTIME]";
//    
//    finalStr = [finalStr stringByReplacingOccurrencesOfString:@"[]" withString:@"[aaaaaa]"];
//    
//    NSInteger strLength = finalStr.length;
//    for (int i = 0 ; i < strLength; i ++) {
//        
//        if (strLength <= 0) {
//            break;
//        }
//        
//        NSRange resultRange = [finalStr rangeOfString:@"[" options:NSBackwardsSearch range:NSMakeRange(0,strLength)];
//        NSRange resultRange1 = [finalStr rangeOfString:@"]" options:NSBackwardsSearch range:NSMakeRange(0,strLength)];
//        
//        NSRange range = NSMakeRange(resultRange.location + resultRange.length, resultRange1.location - resultRange.location - resultRange1.length);
//        
//        NSString * resultStr = [finalStr substringWithRange:range];
//                
//        NSRange replaceRange = NSMakeRange(resultRange.location , resultRange1.location - resultRange.location + 1);
//
//        finalStr = [finalStr stringByReplacingCharactersInRange:replaceRange withString:@"8"];
//
//        strLength = resultRange.location;
//        NSLog(@"%@",finalStr);
//
//        NSLog(@" %ld %@",(long)strLength,resultStr);
//    }
//    
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
