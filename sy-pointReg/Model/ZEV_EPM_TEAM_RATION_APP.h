//
//  ZEV_EPM_TEAM_RATION_APP.h
//  sy-pointReg
//
//  Created by Stenson on 16/8/23.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

/**
 *  @author Stenson, 16-08-24 14:08:35
 *
 *  全部任务列表Model
 *
 */

#import <Foundation/Foundation.h>

@interface ZEV_EPM_TEAM_RATION_APP : NSObject

@property (nonatomic,copy) NSString * CATEGORYCODE;
@property (nonatomic,copy) NSString * CATEGORYNAME;
@property (nonatomic,copy) NSString * DISPLAYORDER;
@property (nonatomic,copy) NSString * ORGCODE;
@property (nonatomic,copy) NSString * RATIONCODE;
@property (nonatomic,copy) NSString * RATIONNAME;
@property (nonatomic,copy) NSString * SEQKEY;
@property (nonatomic,copy) NSString * SUITUNIT;

@property (nonatomic,copy) NSString * WORKPLACE;   ///  工作对象 展示列表
@property (nonatomic,copy) NSString * WORKPLACECODE;   ///  工作对象 展示列表
@property (nonatomic,copy) NSString * COMPREHENSIVECOEFFICIENT;  //  工作对象系数


+(ZEV_EPM_TEAM_RATION_APP *)getDetailWithDic:(NSDictionary *)dic;

@end
