//
//  ZEUserServer.m
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#import "ZEPackageServerData.h"
#import "ZEUserServer.h"
#import "ZELoginViewController.h"
@implementation ZEUserServer


+(void)loginWithNum:(NSString *)username
       withPassword:(NSString *)password
            success:(ServerResponseSuccessBlock)successBlock
               fail:(ServerResponseFailBlock)failBlock
{
    NSDictionary * dataDic = [ZEPackageServerData getLoginServerDataWithUsername:username
                                                                    withPassword:password];
    
    NSString * loginServer = [NSString stringWithFormat: @"%@/do/app/login",Zenith_Server];
    
    [[ZEServerEngine sharedInstance]requestWithJsonDic:dataDic
                                     withServerAddress:loginServer
                                               success:^(id data) {
                                                   successBlock(data);
                                               } fail:^(NSError *errorCode) {
                                                   NSLog(@"请求失败 >>  %@",errorCode);
                                                   failBlock(errorCode);
                                               }];
}

+(void)logoutSuccess:(ServerResponseSuccessBlock)successBlock
                fail:(ServerResponseFailBlock)failBlock
{
    NSDictionary * dataDic = [ZEPackageServerData getLogoutServerData];
    NSLog(@">>  %@",dataDic);
    NSString * logoutServer = [NSString stringWithFormat: @"%@/do/app/logout",Zenith_Server];
    [[ZEServerEngine sharedInstance]requestWithJsonDic:dataDic
                                     withServerAddress:logoutServer
                                               success:^(id data) {
                                                   successBlock(data);
                                               } fail:^(NSError *errorCode) {
                                                   NSLog(@"请求失败 >>  %@",errorCode);
                                                   failBlock(errorCode);
                                               }];
}

+(void)getDataWithJsonDic:(NSDictionary *)dic
                  success:(ServerResponseSuccessBlock)successBlock
                     fail:(ServerResponseFailBlock)failBlock
{
    
    NSString * commonServer = [NSString stringWithFormat: @"%@/do/app/uiaction",Zenith_Server];
    
    [[ZEServerEngine sharedInstance]requestWithJsonDic:dic
                                     withServerAddress:commonServer
                                               success:^(id data) {
                                                   if ([ZEUtil isSuccess:[data objectForKey:@"RETMSG"]]) {
                                                       successBlock(data);
                                                   }else{
                                                       [ZESettingLocalData clearLocalData];
                                                       NSLog(@" failBlock ==  %@ ",[data objectForKey:@"RETMSG"]);
                                                       NSLog(@" failData ==  %@ ",data);
                                                       [ZEUserServer logoutSucce];
                                                       NSError *errorCode = nil;
                                                       failBlock(errorCode);
                                                   }
                                               } fail:^(NSError *errorCode) {
                                                   failBlock(errorCode);
                                               }];
}

+(void)logoutSucce
{
    
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:nil message:@"登陆过期，请重新登陆。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:action];
    
    [ZESettingLocalData clearLocalData];
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    
    ZELoginViewController * loginVC = [[ZELoginViewController alloc]init];
    keyWindow.rootViewController = loginVC;
    
    [loginVC presentViewController:alertC animated:YES completion:nil];
    
}

#pragma mark - 进行操作前 预先进行查询操作

+(void)searchDataISExistWithTableName:(NSString *)tableName
                      withMASTERFIELD:(NSString *)MASTERFIELD
                        withFieldsDic:(NSDictionary *)fieldsDic
                             complete:(void(^)(BOOL isExist,NSString * SEQKEY))complete
{
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":tableName,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"",
                                     @"WHERESQL":@"",
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"MASTERFIELD":MASTERFIELD,
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     @"DETAILTABLE":@"",};
    
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[tableName]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    __block BOOL isExist;
    
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 NSString * SEQKEY = nil;
                                 NSDictionary * userinfoDic = [[data objectForKey:@"DATAS"] objectForKey:tableName];
                                 if ([[userinfoDic objectForKey:@"totalCount"] integerValue] == 0) {
                                     isExist = NO;
                                 }else{
                                     isExist = YES;
                                     SEQKEY = [[ZEUtil getServerData:data withTabelName:tableName][0] objectForKey:@"SEQKEY"];
                                 }
                                 
                                 complete(isExist,SEQKEY);
                             } fail:^(NSError *errorCode) {
                                 NSLog(@">>  %@",errorCode);
                             }];
    
}


@end
