//
//  ZESettingLocalData.h
//  nbsj-know
//
//  Created by Stenson on 16/8/9.
//  Copyright © 2016年 Hangzhou Zenith Electronic Technology Co., Ltd. All rights reserved.
//

/**
 *  @author Stenson, 16-08-11 14:08:39
 *
 *  本地存储类
 *
 */

#import <Foundation/Foundation.h>

@interface ZESettingLocalData : NSObject

/**
 *  @author Stenson, 16-08-11 14:08:52
 *
 *  保存Cookie到本地
 *
 */
+(void)setCookie:(NSData *)str;
+(NSData *)getCookie;
+(void)deleteCookie;
/**
 *  @author Stenson, 16-08-12 15:08:26
 *
 *  用户名
 *
 */
+(void)setUSERNAME:(NSString *)str;
+(NSString *)getUSERNAME;
+(void)deleteUSERNAME;

/**
 *  @author Stenson, 16-08-12 15:08:00
 *
 *  保存用户唯一标示
 *
 */
+(NSString *)getUSERCODE;
/**
 *  @author Stenson, 16-08-12 15:08:00
 *
 *  保存是否是专家
 *
 */
+(void)setISEXPERT:(BOOL)isExpert;
+(BOOL)getISEXPERT;
+(void)deleteISEXPERT;

/**
 *  @author Stenson, 16-08-17 13:08:23
 *
 *  存储个人用户数据信息
 */
+(void)setUSERINFODic:(NSDictionary *)userinfo;
+(NSDictionary *)getUSERINFO;
+(void)deleteUSERINFODic;

/**
 *  @author Stenson, 16-08-17 13:08:23
 *
 *  保存K值系数
 */
+(void)setKValue:(NSString *)k;
+(NSString *)getKValue;
+(void)deleteKValue;

/******** 修改昵称 *******/
+(void)changeNICKNAME:(NSString *)nickname;
/*********** 获取用户昵称 ********/
+(NSString *)getNICKNAME;

/********  用户主键 **********/
+(NSString *)getUSERSEQKEY;

+(void)clearLocalData;

@end
