//
//  ZESetLocalData.m
//  NewCentury
//
//  Created by Stenson on 16/1/22.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

static NSString * kUserInformation  = @"keyUserInformation";
static NSString * kSignCookie       = @"keySIGNCOOKIE";
static NSString * kUSERNAME         = @"kUSERNAME";
static NSString * kUSERPASSWORD         = @"kUSERPASSWORD";
static NSString * kUSERCODE         = @"kUSERCODE";
static NSString * kISEXPERT         = @"kISEXPERT";
static NSString * kUSERINFODic      = @"kUSERINFODic";
static NSString * KValue            = @"KValue";
static NSString * kISLEADER            = @"kISLEADER";

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
    return [self Get:kUSERNAME];
}
+(void)deleteUSERNAME
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUSERNAME];
}

/**
 *  @author Stenson, 16-08-12 15:08:26
 *
 *  用户密码
 *
 */
+(void)setUSERPASSWORD:(NSString *)str
{
    [self Set:kUSERPASSWORD value:str];
}
+(NSString *)getUSERPASSWORD
{
    return [self Get:kUSERPASSWORD];
}
+(void)deleteUSERPASSWORD
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUSERPASSWORD];
}

#pragma mark - USERCODE

+(NSString *)getUSERCODE
{
    if(![ZEUtil isStrNotEmpty:[[self getUSERINFO] objectForKey:@"USERCODE"]]){
        return @"";
    }
    return [[self getUSERINFO] objectForKey:@"USERCODE"];
}

#pragma mark - ISEXPERT
+(void)setISEXPERT:(BOOL)isExpert
{
    [self Set:kISEXPERT value:[NSString stringWithFormat:@"%d",isExpert]];
    
}
+(BOOL)getISEXPERT
{
    return [[self Get:kISEXPERT] boolValue];
}
+(void)deleteISEXPERT
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kISEXPERT];
}

#pragma mark - 是否是班组长
/**
 *  @author Stenson, 16-09-08 10:09:52
 *
 *  该登陆账号是否是班组长登陆
 *
 *  @param isLeader <#isLeader description#>
 */
+(void)setISLEADER:(BOOL)isLeader
{
    [self Set:kISLEADER value:[NSString stringWithFormat:@"%d",isLeader]];
}
+(BOOL)getISLEADER
{
    return [[self Get:kISLEADER] boolValue];
}
+(void)deleteISLEADER
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kISLEADER];
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

+(NSString *)getNICKNAME
{
    if(![ZEUtil isStrNotEmpty:[[self getUSERINFO] objectForKey:@"USERNAME"]]){
        return @"";
    }
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
    [ZESettingLocalData deleteISLEADER];
    [ZESettingLocalData deleteCookie];
    [ZESettingLocalData deleteUSERNAME];
    [ZESettingLocalData deleteUSERPASSWORD];
    [ZESettingLocalData deleteISEXPERT];
    [ZESettingLocalData deleteUSERINFODic];
    [ZESettingLocalData deleteKValue];
}


@end

