//
//  ZEMarcoConstant.h
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#ifndef ZEMarcoConstant_h
#define ZEMarcoConstant_h

#define IS_IOS7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
#define IS_IOS8 [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0

#define NAV_HEIGHT 64.0f   

#define SCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH     [[UIScreen mainScreen] bounds].size.width
#define FRAME_WIDTH     [[UIScreen mainScreen] applicationFrame].size.width
#define FRAME_HEIGHT    [[UIScreen mainScreen] applicationFrame].size.height
#define IPHONE5_MORE     ([[UIScreen mainScreen] bounds].size.height > 480)
#define IPHONE4S_LESS    ([[UIScreen mainScreen] bounds].size.height <= 480)
#define IPHONE5     ([[UIScreen mainScreen] bounds].size.height == 568)
#define IPHONE6_MORE     ([[UIScreen mainScreen] bounds].size.height > 568)
#define IPHONE6     ([[UIScreen mainScreen] bounds].size.height == 667)
#define IPHONE6P     ([[UIScreen mainScreen] bounds].size.height == 736)

#define HTTPMETHOD_GET @"GET"
#define HTTPMETHOD_POST @"POST"

#define kFieldDic @"fieldDic"
#define kDefaultFieldDic @"defaultFieldDic"

#define kLEADERPOINTREG @"20"  //  班组长录入

#define kNOTISEARCHPOINT @"kSearchPoint"
#define kNOTICACHEUSERINFO @"kCacheUserinfo"
#define kRelogin @"kRelogin"
#define kVerifyLogin @"kVerifyLogin"

//  测试版   http://120.27.152.63:7001/emarkspg_sy
//  正式版   http://120.27.152.63:8056/hunan_sy

#define Zenith_Server [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ZenithServerAddress"]

#endif /* ZEMarcoConstant_h */
