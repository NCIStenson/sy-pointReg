//
//  ZECacheParameters.m
//  sy-pointReg
//
//  Created by Stenson on 16/8/29.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZECacheParameters.h"

#import "ZEPointRegCache.h"
#import "ZEUserServer.h"
#import "MBProgressHUD.h"
#import "ZEEPM_TEAM_RATIONTYPE.h"


@implementation ZECacheParameters

+(void)startCache
{
    [ZECacheParameters cacheShareType];
}

#pragma mark - 缓存分摊类型

+(void)cacheShareType
{
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        for (int i = 1; i < 7; i ++) {
            [ZECacheParameters cacheCoefficientDetail:i];
        }
    });
    
    if ([[[ZEPointRegCache instance] getDistributionTypeCaches] count] > 0) {
        return;
    }
    
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATIONTYPE,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":@"pagetype = '1' and isselect = 'true' and suitunit = (case (select count(*) from epm_team_rationtype c where c.suitunit = '#SUITUNIT#') when 0 then '-1' else '#SUITUNIT#' end)",
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     @"DETAILTABLE":@"",};
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATIONTYPE]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 
                                 NSArray * arr =[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPE];
                                 [[ZEPointRegCache instance] setDistributionTypeCaches:arr];
                                 for (NSDictionary * dic in arr) {
                                     ZEEPM_TEAM_RATIONTYPE * model = [ZEEPM_TEAM_RATIONTYPE getDetailWithDic:dic];
                                     [self cacheDistributionTypeCoefficientWithCode:model.RATIONTYPECODE];
                                 }
                                 
                                 
                             } fail:^(NSError *errorCode) {
                             }];
    
}

+(void)cacheDistributionTypeCoefficientWithCode:(NSString *)rationCode
{
    NSString * WHERESQL = [NSString stringWithFormat:@"rationtypecode = '%@' and isselect = 'true' and suitunit = (case (select count(*) from epm_team_rationtype c where c.suitunit = 'XYSDLJ') when 0 then '-1' else 'XYSDLJ' end)",rationCode];
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATIONTYPEDETAIL,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":WHERESQL,
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     @"DETAILTABLE":@"",};
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATIONTYPEDETAIL]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 NSArray * arr = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPEDETAIL];
                                 if (arr.count > 0) {
                                     [[ZEPointRegCache instance] setDistributionTypeCoefficient:@{rationCode:arr}];
                                 }
                             } fail:^(NSError *errorCode) {
                             }];
}
+(void)cacheCoefficientDetail:(NSInteger)number
{
    if ([[[[ZEPointRegCache instance]getRATIONTYPEVALUE] allKeys] count] > 0) {
        return;
    }
    NSString * valueStr = [NSString stringWithFormat:@"QUOTIETY%ldCODE",(long)number];
    
    NSString * WHERESQL = [NSString stringWithFormat:@"suitunit = '#SUITUNIT#' and FIELDNAME = 'QUOTIETY%ldCODE' and secorgcode in (select case (select count(1) from EPM_TEAM_RATIONTYPEVALUE t where t.suitunit = '#SUITUNIT#' and FIELDNAME = 'QUOTIETY%ldCODE' and secorgcode = '#SECORGCODE#') when 0 then '-1' else '#SECORGCODE#' end from dual)",(long)number,number];
    
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATIONTYPEVALUE,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":WHERESQL,
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     @"DETAILTABLE":@"",};
    
    NSDictionary * fieldsDic =@{@"QUOTIETYCODE":@"",
                                @"QUOTIETYNAME":@"",
                                @"QUOTIETY":@"",
                                @"DEFAULTCODE":@""};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATIONTYPEVALUE]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [[ZEPointRegCache instance] setRATIONTYPEVALUE:@{valueStr:[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPEVALUE]}];
                             } fail:^(NSError *errorCode) {
                             }];
    
}
@end
