//
//  ZEPointRegCache.m
//  NewCentury
//
//  Created by Stenson on 16/1/21.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEPointRegCache.h"

#import "MBProgressHUD.h"

#import "ZEEPM_TEAM_RATIONTYPE.h"

@interface ZEPointRegCache ()
{
    NSArray * _taskCachesArr;          //  常用任务列表缓存
    NSArray * _allTaskCachesArr;          //  全部任务列表缓存

    UIView * hudView;
    
    NSMutableDictionary * _optionDic; // 用户选择信息缓存
}
@property(nonatomic,retain) NSMutableDictionary * optionDic;
@property(nonatomic,retain) NSMutableDictionary * leaderOptionDic;

@property (nonatomic,strong) NSMutableDictionary * disTypeCoefficientDic;
@property (nonatomic,strong) NSMutableDictionary * RATIONTYPEVALUEDic;
@property (nonatomic,strong) NSArray * workerListArr;

@property (nonatomic,retain) NSArray * taskCachesArr;
@property (nonatomic,retain) NSArray * allTaskCachesArr;
@property (nonatomic,retain) NSArray * distributionTypeArr;
@property (nonatomic,retain) NSArray * workConditionArr;  //   工作条件
@end

static ZEPointRegCache * pointRegCahe = nil;

@implementation ZEPointRegCache

-(id)initSingle
{
    self = [super init];
    if (self) {
        self.disTypeCoefficientDic = [NSMutableDictionary dictionary];
        self.RATIONTYPEVALUEDic = [NSMutableDictionary dictionary];
    }
    return self;
}

-(id)init
{
    return [ZEPointRegCache instance];
}

+(ZEPointRegCache *)instance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        pointRegCahe = [[ZEPointRegCache alloc] initSingle];
    });
    return pointRegCahe;
}

/**
 *  存储用户第一次请求任务列表，APP运行期间 只请求一次任务列表
 */
- (void)setTaskCaches:(NSArray *)taskArr
{
    self.taskCachesArr = taskArr;
}
- (NSArray *)getTaskCaches
{
    return self.taskCachesArr;
}
/**
 *  存储用户第一次请求全部任务列表，APP运行期间 只请求一次任务列表
 */
- (void)setAllTaskCaches:(NSArray *)allTaskArr
{
    self.allTaskCachesArr = allTaskArr;
}
- (NSArray *)getAllTaskCaches
{
    return self.allTaskCachesArr;
}
/**
 *  存储用户第一次请求分配类型系数列表，APP运行期间 只请求一次分配类型系数列表
 */
- (void)setDistributionTypeCoefficient:(NSDictionary *)dic
{
    [self.disTypeCoefficientDic setValuesForKeysWithDictionary:dic];
}
- (NSDictionary *)getDistributionTypeCoefficient
{
    return self.disTypeCoefficientDic;
}

/**
 *  存储用户第一次请求 分摊类型 列表，APP运行期间 只请求一次 难度系数 列表
 */
- (void)setDistributionTypeCaches:(NSArray *)disArr
{
    self.distributionTypeArr = disArr;
}
- (NSArray *)getDistributionTypeCaches
{
    return  self.distributionTypeArr;
}

/**
 *  存储用户第一次请求分配类型系数详情列表，APP运行期间 只请求一次分配类型系数详情列表
 */
- (void)setRATIONTYPEVALUE:(NSDictionary *)dic
{
    [self.RATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
}
- (NSDictionary *)getRATIONTYPEVALUE
{
    return self.RATIONTYPEVALUEDic;
}

/**
 *  @author Stenson, 16-08-30 09:08:32
 *
 *  存储用户第一次请求 工作人员 列表，APP运行期间 只请求一次 工作人员 列表
 *
 */
- (void)setWorkerList:(NSArray *)arr
{
    self.workerListArr = arr;
}
- (NSArray *)getWorkerList
{
    return self.workerListArr;
}


/**
 *  存储用户选择过的选项
 */

- (void)setUserChoosedOptionDic:(NSDictionary *)choosedDic
{
    _optionDic = [NSMutableDictionary dictionaryWithDictionary:[self getUserChoosedOptionDic]];
    if ([ZEUtil isNotNull:choosedDic]) {
        [_optionDic setValue:choosedDic.allValues[0] forKey:choosedDic.allKeys[0]];
    }
}
- (NSDictionary * )getUserChoosedOptionDic
{
    return _optionDic;
}

/**
 *  多人工分登记
 *  存储用户选择过的选项
 */
- (void)setLeaderChoosedOptionDic:(NSDictionary *)choosedDic
{
    _optionDic = [NSMutableDictionary dictionaryWithDictionary:[self getUserChoosedOptionDic]];
    if ([ZEUtil isNotNull:choosedDic]) {
        [_optionDic setValuesForKeysWithDictionary:choosedDic];
    }
}
- (NSDictionary * )getLeaderChoosedOptionDic
{
    return _leaderOptionDic;
}

/**
 *  @author Zenith Electronic, 16-02-23 14:02:17
 *
 *  存储用户重新提交审核数据的历史数据信息
 *
 *  @param dic 历史数据信息
 */
//-(void)setResubmitCaches:(NSDictionary *)dic
//{
//    self.resubmitDataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
//}
//-(void)changeResubmitCache:(NSDictionary *)dic
//{
//    self.resubmitDataDic = [NSMutableDictionary dictionaryWithDictionary:[self getResubmitCachesDic]];
//    [self.resubmitDataDic setValue:dic.allValues[0] forKey:dic.allKeys[0]];
//}
//- (NSDictionary * )getResubmitCachesDic
//{
//    return self.resubmitDataDic;
//}

- (void)setWorkCondition:(NSArray *)disArr
{
    self.workConditionArr = disArr;
}
- (NSArray *)getWorkCondition
{
    return self.workConditionArr;
}

/**
 *  清除用户选择过的信息
 */
-(void)clearUserOptions
{
    _optionDic          = nil;    // 用户选择信息缓存
}

/**
 *  清空缓存
 */

- (void)clear
{
    _workConditionArr      = nil;
    _taskCachesArr         = nil;//  任务列表缓存
    _optionDic             = nil;// 用户选择信息缓存
    _RATIONTYPEVALUEDic    = nil;
    _allTaskCachesArr      = nil;
    _distributionTypeArr   = nil;
    _disTypeCoefficientDic = nil;
    _workerListArr         = nil;
    self.disTypeCoefficientDic = [NSMutableDictionary dictionary];
    self.RATIONTYPEVALUEDic = [NSMutableDictionary dictionary];
}

#pragma mark - 缓存分摊类型

-(void)cacheShareType:(UIView *)view
{
    
    hudView = view;
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        for (int i = 1; i < 7; i ++) {
            [self cacheCoefficientDetail:i];
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
    [MBProgressHUD showHUDAddedTo:view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:view animated:YES];
                                 NSArray * arr =[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPE];
                                 [[ZEPointRegCache instance] setDistributionTypeCaches:arr];
                                 for (NSDictionary * dic in arr) {
                                     ZEEPM_TEAM_RATIONTYPE * model = [ZEEPM_TEAM_RATIONTYPE getDetailWithDic:dic];
                                     [self cacheDistributionTypeCoefficientWithCode:model.RATIONTYPECODE];
                                 }
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:view animated:YES];
                             }];
    
}

-(void)cacheDistributionTypeCoefficientWithCode:(NSString *)rationCode
{
    NSString * WHERESQL = [NSString stringWithFormat:@"rationtypecode = '%@' and isselect = 'true' and suitunit = (case (select count(*) from epm_team_rationtype c where c.suitunit = 'XYSDLJ') when 0 then '-1' else 'XYSDLJ' end)",rationCode];
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATIONTYPEDETAIL,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"FIELDNAME",
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
                                 [MBProgressHUD hideHUDForView:hudView animated:YES];
                                 NSArray * arr = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPEDETAIL];
                                 if (arr.count > 0) {
                                     [[ZEPointRegCache instance] setDistributionTypeCoefficient:@{rationCode:arr}];
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:hudView animated:YES];
                             }];
}
-(void)cacheCoefficientDetail:(NSInteger)number
{
    if ([[[[ZEPointRegCache instance]getRATIONTYPEVALUE] allKeys] count] > 0) {
        return;
    }
    NSString * valueStr = [NSString stringWithFormat:@"QUOTIETY%ldCODE",(long)number];
    NSString * WHERESQL = [NSString stringWithFormat:@"suitunit = '#SUITUNIT#' and FIELDNAME = 'QUOTIETY%ldCODE' and RATIONCODE = '-1' and secorgcode = (case (select count(1) from EPM_TEAM_RATIONTYPEVALUE t where t.suitunit = '#SUITUNIT#' and FIELDNAME = 'QUOTIETY%ldCODE' and secorgcode = '#SECORGCODE#') when 0 then '-1' else '#SECORGCODE#' end)",(long)number,(long)number];
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
                                 [MBProgressHUD hideHUDForView:hudView animated:YES];
                                 [[ZEPointRegCache instance] setRATIONTYPEVALUE:@{valueStr:[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPEVALUE]}];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:hudView animated:YES];
                             }];
    
}


@end
