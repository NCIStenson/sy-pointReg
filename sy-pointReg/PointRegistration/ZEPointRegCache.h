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
 *  存储用户第一次请求分配类型系数详情列表，APP运行期间 只请求一次分配类型系数详情列表
 */
- (void)setRATIONTYPEVALUE:(NSDictionary *)dic;
- (NSDictionary *)getRATIONTYPEVALUE;


/**
 *  @author Stenson, 16-08-30 09:08:32
 *
 *  存储用户第一次请求 工作人员 列表，APP运行期间 只请求一次 工作人员 列表
 *
 */
- (void)setWorkerList:(NSArray *)arr;
- (NSArray *)getWorkerList;

/**
 *  存储用户选择过的选项
 */
- (void)setUserChoosedOptionDic:(NSDictionary *)choosedDic;
- (NSDictionary * )getUserChoosedOptionDic;

/**
 *  多人工分登记
 *  存储用户选择过的选项
 */
- (void)setLeaderChoosedOptionDic:(NSDictionary *)choosedDic;
- (NSDictionary * )getLeaderChoosedOptionDic;

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
 *  清除用户选择过的信息
 */
-(void)clearUserOptions;

/**
 *  清空缓存
 */
- (void)clear;

-(void)cacheShareType:(UIView *)view;

@end
