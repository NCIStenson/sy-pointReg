//
//  ZESetLocalData.m
//  NewCentury
//
//  Created by Stenson on 16/1/22.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZESetLocalData.h"

static NSString * kUserInformation  = @"keyUserInformation";
static NSString * kSignCookie       = @"keySIGNCOOKIE";
static NSString * kUSERNAME         = @"kUSERNAME";
static NSString * kUSERCODE         = @"kUSERCODE";
static NSString * kISEXPERT         = @"kISEXPERT";
static NSString * kUSERINFODic      = @"kUSERINFODic";
static NSString * KValue            = @"KValue";

@implementation ZESettingLocalData

+(id)Get:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+(NSString *)GetStringWithKey:(NSString *)key
{
    id value = [self Get:key];
    
    if (value == [NSNull null] || value == nil) {
        return @"";
    }
    
    return value;
}

+(int)GetIntWithKey:(NSString *)key
{
    id value = [self Get:key];
    
    if (value == [NSNull null] || value == nil) {
        return -1;
    }
    
    return [value intValue];
}

+(void)Set:(NSString*)key value:(id)value
{
    if (value == [NSNull null] || value == nil) {
        value = @"";
    }
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - COOKIE

+(void)setCookie:(NSData *)str
{
    [self Set:kSignCookie value:str];
}

+(NSData *)getCookie
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSignCookie];
}

+(void)deleteCookie
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSignCookie];
}

#pragma mark - USERNAME
+(void)setUSERNAME:(NSString *)str
{
    [self Set:kUSERNAME value:str];
}
+(NSString *)getUSERNAME
{
    return [[self getUSERINFO] objectForKey:@"USERNAME"];
}
+(void)deleteUSERNAME
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUSERNAME];
}

#pragma mark - USERCODE

+(NSString *)getUSERCODE
{
    return [[self getUSERINFO] objectForKey:@"USERCODE"];
}

#pragma mark - ISEXPERT
+(void)setISEXPERT:(BOOL)isExpert
{
    [self Set:kISEXPERT value:[NSString stringWithFormat:@"%d",isExpert]];
    
}
+(BOOL)getISEXPERT
{
    return [self Get:kISEXPERT];
}
+(void)deleteISEXPERT
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kISEXPERT];
}

#pragma mark - USERINFODic
+(void)setUSERINFODic:(NSDictionary *)userinfo
{
    [self Set:kUSERINFODic value:userinfo];
    
}
+(NSDictionary *)getUSERINFO
{
    return [self Get:kUSERINFODic];
}
+(void)deleteUSERINFODic
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUSERINFODic];
}

/******** 修改昵称 *******/
+(void)changeNICKNAME:(NSString *)nickname
{
    NSMutableDictionary * userinfoDic = [NSMutableDictionary dictionaryWithDictionary: [self getUSERINFO]];
    [userinfoDic setValue:nickname forKey:@"USERNAME"];
    [self Set:kUSERINFODic value:userinfoDic];
}

+(NSString *)getNICKNAME
{
    return  [[self getUSERINFO] objectForKey:@"USERNAME"];
}

/********  用户主键 **********/
+(NSString *)getUSERSEQKEY
{
    return [[self getUSERINFO] objectForKey:@"SEQKEY"];
}

/**
 *  @author Stenson, 16-08-17 13:08:23
 *
 *  保存K值系数
 */
+(void)setKValue:(NSString *)k
{
    [self Set:KValue value:k];
}
+(NSString *)getKValue
{
    return [self Get:KValue];
}
+(void)deleteKValue
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KValue];
}


#pragma mark - CLEAR
+(void)clearLocalData
{
    [ZESettingLocalData deleteCookie];
    [ZESettingLocalData deleteUSERNAME];
    [ZESettingLocalData deleteISEXPERT];
    [ZESettingLocalData deleteUSERINFODic];
    [ZESettingLocalData deleteKValue];
}


@end

