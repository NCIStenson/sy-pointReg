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

    NSMutableDictionary * _optionDic; // 用户选择信息缓存
}
@property(nonatomic,retain) NSMutableDictionary * optionDic;
@property(nonatomic,retain) NSMutableDictionary * leaderOptionDic;

@property(nonatomic,retain) NSMutableDictionary * resubmitDataDic;

@property (nonatomic,strong) NSMutableDictionary * disTypeCoefficientDic;
@property (nonatomic,strong) NSMutableDictionary * RATIONTYPEVALUEDic;
@property (nonatomic,strong) NSArray * workerListArr;

@property (nonatomic,retain) NSArray * taskCachesArr;
@property (nonatomic,retain) NSArray * allTaskCachesArr;
@property (nonatomic,retain) NSArray * distributionTypeArr;

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
    self.leaderOptionDic = nil;
}

/**
 *  清除用户选择过的信息
 */
-(void)clearUserOptions
{
    _optionDic          = nil;    // 用户选择信息缓存
    _resubmitDataDic    = nil;
}

/**
 *  清空缓存
 */

- (void)clear
{
    _taskCachesArr         = nil;//  任务列表缓存
    _optionDic             = nil;// 用户选择信息缓存
    _resubmitDataDic       = nil;
    _RATIONTYPEVALUEDic    = nil;
    _allTaskCachesArr      = nil;
    _distributionTypeArr   = nil;
    _disTypeCoefficientDic = nil;
    _workerListArr         = nil;
}

@end
