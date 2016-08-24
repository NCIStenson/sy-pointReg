//
//  ZEPointRegCache.h
//  NewCentury
//
//  Created by Stenson on 16/1/21.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZEPointRegCache : NSObject

+ (ZEPointRegCache*)instance;

/**
 *  存储用户第一次请求常用任务列表，APP运行期间 只请求一次任务列表
 */
- (void)setTaskCaches:(NSArray *)taskArr;
- (NSArray *)getTaskCaches;

/**
 *  存储用户第一次请求全部任务列表，APP运行期间 只请求一次任务列表
 */
- (void)setAllTaskCaches:(NSArray *)allTaskArr;
- (NSArray *)getAllTaskCaches;

/**
 *  存储用户第一次请求分配系数列表，APP运行期间 只请求一次分配系数列表
*/
- (void)setDistributionTypeCaches:(NSArray *)disArr;
- (NSArray *)getDistributionTypeCaches;


/**
 *  存储用户第一次请求分配类型系数列表，APP运行期间 只请求一次分配类型系数列表
 */
- (void)setDistributionTypeCoefficient:(NSDictionary *)dic;
- (NSDictionary *)getDistributionTypeCoefficient;
/**
 *  存储用户第一次请求时间系数列表，APP运行期间 只请求一次时间系数列表
 */
- (void)setTimesCoeCaches:(NSArray *)timesCoeArr;
- (NSArray *)getTimesCoeCaches;

/**
 *  存储用户第一次请求 工作角色 列表，APP运行期间 只请求一次 工作角色 列表
 */
- (void)setWorkRulesCaches:(NSArray *)workRulesArr;
- (NSArray *)getWorkRulesCaches;

/**
 *  存储用户选择过的选项
 */
- (void)setUserChoosedOptionDic:(NSDictionary *)choosedDic;
- (NSDictionary * )getUserChoosedOptionDic;
/**
 *  用户扫描得到的登记信息
 */
- (void)setScanCodeChoosedOptionDic:(NSDictionary *)choosedDic;
- (NSDictionary * )getScanCodeChoosedOptionDic;

/**
 *  @author Zenith Electronic, 16-02-23 14:02:17
 *
 *  存储用户重新提交审核数据的历史数据信息
 *
 *  @param dic 历史数据信息
 */
-(void)setResubmitCaches:(NSDictionary *)dic;
-(void)changeResubmitCache:(NSDictionary *)dic;
- (NSDictionary * )getResubmitCachesDic;
/**
 *  清空审核修改数据
 */
-(void)clearResubmitCaches;

/**
 *  清除输入次数缓存
 */
-(void)clearCount;

/**
 *  清除工作角色缓存
 */
-(void)clearRoles;
/**
 *  清除用户选择过的信息
 */
-(void)clearUserOptions;

/**
 *  清空缓存
 */
- (void)clear;

@end
