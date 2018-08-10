//
//  ZEUtil.m
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#import "ZEUtil.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>

#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#include <ifaddrs.h>
#include <arpa/inet.h>

#import <sys/utsname.h>
#import "SvUDIDTools.h"
@implementation ZEUtil

+ (BOOL)isNotNull:(id)object
{
    
    if ([object isEqual:[NSNull null]]) {
        return NO;
    } else if ([object isKindOfClass:[NSNull class]]) {
        return NO;
    } else if (object == nil) {
        return NO;
    }
    return YES;
}

+ (BOOL)isStrNotEmpty:(NSString *)str
{
    if ([ZEUtil isNotNull:str]) {
        if ([str isEqualToString:@""]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

+ (BOOL)strIsEmpty:(NSString *)str
{
    if ([str isEqualToString:@"(null)"]) {
        return YES;
    }
    if ([str isEqualToString:@""]) {
        return YES;
    }
    return NO;
}
+(int)compareDate:(NSString*)date01 withDate:(NSString*)date02{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dt1 = nil;
    NSDate *dt2 = nil;
    dt1 = [df dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",date01]];
    dt2 = [df dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",date02]];
    
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending: ci=1; break;
            //date02比date01小
        case NSOrderedDescending: ci=-1; break;
            //date02=date01
        case NSOrderedSame: ci=0; break;
    }
    return ci;
}
+ (double)heightForString:(NSString *)str font:(UIFont *)font andWidth:(float)width
{
    double height = 0.0f;
    if (IS_IOS7) {
        CGRect rect = [str boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
        height = ceil(rect.size.height);
    }
    return height;
}

+ (double)widthForString:(NSString *)str font:(UIFont *)font maxSize:(CGSize)maxSize
{
    double width = 0.0f;
    if (IS_IOS7) {
        CGRect rect = [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
        width = rect.size.width;
    }
    return width;
}


+ (NSDictionary *)getSystemInfo
{
    NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *systemName = [[UIDevice currentDevice] systemName];
    
//    NSString *device = [[UIDevice currentDevice] model];
    
//    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    
//    NSString *appVersion = [bundleInfo objectForKey:@"CFBundleShortVersionString"];
//    
//    NSString *appBuildVersion = [bundleInfo objectForKey:@"CFBundleVersion"];
    
//    NSArray *languageArray = [NSLocale preferredLanguages];
    
//    NSString *language = [languageArray objectAtIndex:0];
    
//    NSLocale *locale = [NSLocale currentLocale];
    
//    NSString *country = [locale localeIdentifier];
    
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    
    // 手机型号
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
//    NSString *deviceModel = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    [infoDic setObject:[ZEUtil correspondVersion] forKey:@"BRAND"];
    [infoDic setObject:[[SvUDIDTools UDID] stringByReplacingOccurrencesOfString:@"-" withString:@""] forKey:@"IMEI"];
    [infoDic setObject:[ZEUtil getIPAddress] forKey:@"IP"];
    [infoDic setObject:[ZEUtil macaddress] forKey:@"MAC"];
    [infoDic setObject:[self correspondVersion] forKey:@"PHONEMODEL"];
    [infoDic setObject:systemName forKey:@"SYS"];
    [infoDic setObject:systemVersion forKey:@"SYSVERSION"];
    [infoDic setObject:userPhoneName forKey:@"SYSVERSIONCODE"];
    [infoDic setObject:@"" forKey:@"TELNUMBER"];
    
    
    if(![ZEUtil strIsEmpty:[ZESettingLocalData getUSERNAME]]){
        [infoDic setObject:[ZESettingLocalData getUSERNAME] forKey:@"USERACCOUNT"];
    }
    if(![ZEUtil strIsEmpty:[ZESettingLocalData getNICKNAME]]){
        [infoDic setObject:[ZESettingLocalData getNICKNAME] forKey:@"PSNNAME"];
    }
    if(![ZEUtil strIsEmpty:[ZESettingLocalData getUSERCODE]]){
        [infoDic setObject:[ZESettingLocalData getUSERCODE] forKey:@"PSNNUM"];
    }

    return infoDic;
}

/********* 获取mac地址 **********/
+ (NSString *)macaddress
{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    //    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
//    NSLog(@"outString:%@", outstring);
    
    free(buf);
    
    return [outstring uppercaseString];
}

/*********** 本机IP *************/

+(NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}
/*********** 获取iPhone型号 *************/
+(NSString *)getDeviceVersionInfo
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithFormat:@"%s", systemInfo.machine];
    
    return platform;
}

+(NSString *)correspondVersion
{
    NSString *correspondVersion = [ZEUtil getDeviceVersionInfo];
    
    if ([correspondVersion isEqualToString:@"i386"])        return@"Simulator";
    if ([correspondVersion isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([correspondVersion isEqualToString:@"iPhone1,1"])   return@"iPhone 1";
    if ([correspondVersion isEqualToString:@"iPhone1,2"])   return@"iPhone 3";
    if ([correspondVersion isEqualToString:@"iPhone2,1"])   return@"iPhone 3S";
    if ([correspondVersion isEqualToString:@"iPhone3,1"] || [correspondVersion isEqualToString:@"iPhone3,2"])   return@"iPhone 4";
    if ([correspondVersion isEqualToString:@"iPhone4,1"])   return@"iPhone 4S";
    if ([correspondVersion isEqualToString:@"iPhone5,1"] || [correspondVersion isEqualToString:@"iPhone5,2"])   return @"iPhone 5";
    if ([correspondVersion isEqualToString:@"iPhone5,3"] || [correspondVersion isEqualToString:@"iPhone5,4"])   return @"iPhone 5C";
    if ([correspondVersion isEqualToString:@"iPhone6,1"] || [correspondVersion isEqualToString:@"iPhone6,2"])   return @"iPhone 5S";
    if ([correspondVersion isEqualToString:@"iPhone6,1"])  return @"iPhone 5s (A1453/A1533)";
    if ([correspondVersion isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([correspondVersion isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([correspondVersion isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    if ([correspondVersion isEqualToString:@"iPhone8,1"])   return @"iPhone 6S";
    if ([correspondVersion isEqualToString:@"iPhone8,2"])   return @"iPhone 6S Plus";
    
    if ([correspondVersion isEqualToString:@"iPod1,1"])     return@"iPod Touch 1";
    if ([correspondVersion isEqualToString:@"iPod2,1"])     return@"iPod Touch 2";
    if ([correspondVersion isEqualToString:@"iPod3,1"])     return@"iPod Touch 3";
    if ([correspondVersion isEqualToString:@"iPod4,1"])     return@"iPod Touch 4";
    if ([correspondVersion isEqualToString:@"iPod5,1"])     return@"iPod Touch 5";
    
    if ([correspondVersion isEqualToString:@"iPad1,1"])     return@"iPad 1";
    if ([correspondVersion isEqualToString:@"iPad2,1"] || [correspondVersion isEqualToString:@"iPad2,2"] || [correspondVersion isEqualToString:@"iPad2,3"] || [correspondVersion isEqualToString:@"iPad2,4"])     return@"iPad 2";
    if ([correspondVersion isEqualToString:@"iPad2,5"] || [correspondVersion isEqualToString:@"iPad2,6"] || [correspondVersion isEqualToString:@"iPad2,7"] )      return @"iPad Mini";
    if ([correspondVersion isEqualToString:@"iPad3,1"] || [correspondVersion isEqualToString:@"iPad3,2"] || [correspondVersion isEqualToString:@"iPad3,3"] || [correspondVersion isEqualToString:@"iPad3,4"] || [correspondVersion isEqualToString:@"iPad3,5"] || [correspondVersion isEqualToString:@"iPad3,6"])      return @"iPad 3";
    
    return correspondVersion;
}

+ (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage * image = nil;
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMdd_HHmmssSSS"];
    return [df stringFromDate:date];
}

+ (NSString *)getPointRegInformation:(POINT_REG)point_reg
{
    switch (point_reg) {
        case POINT_REG_TASK:
            return @"工作任务";
            break;
        case POINT_REG_DATE:
            return @"发生日期";
            break;
        case POINT_REG_CONDITION:
            return @"工作对象";
            break;

//        case POINT_REG_WORKING_HOURS:
//            return @"标准工时";
//            break;
//        case POINT_REG_WORKING_POINTS:
//            return @"标准工分";
//            break;
//        case POINT_REG_TYPE:
//            return @"分摊类型";
//            break;
        case POINT_REG_JOB_COUNT:
            return @"工作数量";
            break;
        case POINT_REG_DEGREE:
            return @"修正系数";
            break;
        case POINT_REG_JOB_ROLES:
            return @"工作角色";
            break;
        case POINT_REG_JOB_TIME:
            return @"工作耗时";
            break;
        case POINT_REG_QUALITY:
            return @"工作质量";
            break;
        case POINT_REG_EXPLAIN:
            return @"工作说明";
            break;
        case POINT_REG_ALLSCORE:
            return @"工作得分";
            break;
        default:
            return @"工作任务";
            break;
    }
}

+ (NSString *)getPointRegField:(POINT_REG)point_reg
{
    switch (point_reg) {
        case POINT_REG_TASK:
            return @"task";
            break;
        case POINT_REG_DATE:
            return @"date";
            break;
        case POINT_REG_CONDITION:
            return @"condition";
            break;

        default:
            return @"task";
            break;
    }
}

//  获取分配类型中文
+ (NSString *)getPointRegShareType:(POINT_REG_SHARE_TYPE)point_reg_type
{
    switch (point_reg_type) {
        case POINT_REG_SHARE_TYPE_COE:
            return @"按系数分配";
            break;
        case POINT_REG_SHARE_TYPE_PEO:
            return @"按人头均摊";
            break;
        case POINT_REG_SHARE_TYPE_COUNT:
            return @"按次分配";
            break;
        case POINT_REG_SHARE_TYPE_WP:
            return @"按工分*系数分配";
        default:
            return @"按系数分配";
            break;
    }
}

+ (void)showAlertView:(NSString *)str viewController:(UIViewController *)viewCon
{

    if (IS_IOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:okAction];
        [viewCon presentViewController:alertController animated:YES completion:nil];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:str message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

#pragma mark - 服务器固定格式提取工具类 进行简化提取
+(NSDictionary *)getServerDic:(NSDictionary *)dic withTabelName:(NSString *)tableName
{
    NSDictionary * tableDic = [[dic objectForKey:@"DATAS"] objectForKey:tableName];
    
    return tableDic;
}

+ (NSMutableArray *)getServerData:(NSDictionary *)dic withTabelName:(NSString *)tableName
{
    NSMutableDictionary * tableDic = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"DATAS"] objectForKey:tableName]];
    NSMutableArray * serverDatasArr = [NSMutableArray arrayWithArray:[tableDic objectForKey:@"datas"]];
    
    return serverDatasArr;
}

+(BOOL)isSuccess:(NSString *)dicStr
{
    if ([dicStr isEqualToString:@"操作成功！"]) {
        return YES;
    }else if ([dicStr isEqualToString:@"null"]){
        return YES;
    }else{
        return NO;
    }
}

+(NSString *)getCurrentMonth
{
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYYMM"];
    NSString * dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}
+(NSString *)getCurrentDate:(NSString *)dateFormatter
{
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:dateFormatter];
    NSString * dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}

+(NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}


+(NSString *)roundUp:(float)number afterPoint:(int)position{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:number];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

    return [NSString stringWithFormat:@"%@",roundedOunces];
}

@end
