//
//  ZEPointRegCache.m
//  NewCentury
//
//  Created by Stenson on 16/1/21.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEPointRegCache.h"

@interface ZEPointRegCache ()
{
    NSArray * _taskCachesArr;          //  常用任务列表缓存
    NSArray * _allTaskCachesArr;          //  全部任务列表缓存
    NSArray * _diffCoeCachesArr;       //  难度系数
    NSArray * _timesCoeCachesArr;      //  时间系数
    NSArray * _workRulesCachesArr;     //  工作角色
    NSMutableDictionary * _optionDic; // 用户选择信息缓存
}
@property(nonatomic,retain) NSMutableDictionary * optionDic;
@property(nonatomic,retain) NSMutableDictionary * scanOptionDic;
@property(nonatomic,retain) NSMutableDictionary * resubmitDataDic;
@property (nonatomic,retain) NSArray * taskCachesArr;
@property (nonatomic,retain) NSArray * allTaskCachesArr;
@property (nonatomic,retain) NSArray * diffCoeCachesArr;
@property (nonatomic,retain) NSArray * timesCoeCachesArr;
@property (nonatomic,retain) NSArray * workRulesCachesArr;

@end

static ZEPointRegCache * pointRegCahe = nil;

@implementation ZEPointRegCache

-(id)initSingle
{
    self = [super init];
    if (self) {
//        self.optionDic = [NSMutableDictionary dictionary];
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
 *  存储用户第一次请求 难度系数 列表，APP运行期间 只请求一次 难度系数 列表
 */
- (void)setDiffCoeCaches:(NSArray *)diffCoeArr
{
    self.diffCoeCachesArr = diffCoeArr;
}
- (NSArray *)getDiffCoeCaches
{
    return self.diffCoeCachesArr;
}
/**
 *  存储用户第一次请求时间系数列表，APP运行期间 只请求一次时间系数列表
 */
- (void)setTimesCoeCaches:(NSArray *)timesCoeArr
{
    self.timesCoeCachesArr = timesCoeArr;
}
- (NSArray *)getTimesCoeCaches
{
    return self.timesCoeCachesArr;
}

/**
 *  存储用户第一次请求 工作角色 列表，APP运行期间 只请求一次 工作角色 列表
 */
- (void)setWorkRulesCaches:(NSArray *)workRulesArr
{
    self.workRulesCachesArr = workRulesArr;
}
- (NSArray *)getWorkRulesCaches
{
    return self.workRulesCachesArr;
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
 *  用户扫描得到的登记信息
 */
- (void)setScanCodeChoosedOptionDic:(NSDictionary *)choosedDic
{
    self.scanOptionDic = [NSMutableDictionary dictionaryWithDictionary:choosedDic];
}
- (NSDictionary * )getScanCodeChoosedOptionDic
{
    return self.scanOptionDic;
}
/**
 *  @author Zenith Electronic, 16-02-23 14:02:17
 *
 *  存储用户重新提交审核数据的历史数据信息
 *
 *  @param dic 历史数据信息
 */
-(void)setResubmitCaches:(NSDictionary *)dic
{
    self.resubmitDataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
}
-(void)changeResubmitCache:(NSDictionary *)dic
{
    self.resubmitDataDic = [NSMutableDictionary dictionaryWithDictionary:[self getResubmitCachesDic]];
    [self.resubmitDataDic setValue:dic.allValues[0] forKey:dic.allKeys[0]];
}
- (NSDictionary * )getResubmitCachesDic
{
    return self.resubmitDataDic;
}
/**
 *  清空审核修改数据
 */
-(void)clearResubmitCaches
{
    [self.resubmitDataDic removeAllObjects];
    self.resubmitDataDic = nil;
}

/**
 *  清除输入次数缓存
 */
-(void)clearCount
{
    if ([ZEUtil isNotNull:[_optionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]]) {
        [_optionDic removeObjectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]];
        [_resubmitDataDic removeObjectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]];
    }
}

/**
 *  清除工作角色缓存
 */
-(void)clearRoles
{
    if ([ZEUtil isNotNull:[_optionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]]) {
        [_optionDic removeObjectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]];
        [_resubmitDataDic removeObjectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]];
    }
}
/**
 *  清除用户选择过的信息
 */
-(void)clearUserOptions
{
    _optionDic          = nil;    // 用户选择信息缓存
    _scanOptionDic      = nil;    // 用户扫描结果缓存
}

/**
 *  清空缓存
 */

- (void)clear
{
    _scanOptionDic      = nil;         // 用户扫描结果缓存
    _taskCachesArr      = nil;        //  任务列表缓存
    _diffCoeCachesArr   = nil;       //  难度系数
    _timesCoeCachesArr  = nil;      //  时间系数
    _workRulesCachesArr = nil;     //  工作角色
    _optionDic          = nil;    // 用户选择信息缓存
}

@end
