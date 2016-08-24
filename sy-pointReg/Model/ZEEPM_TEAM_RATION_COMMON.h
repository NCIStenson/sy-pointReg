//
//  ZEEPM_TEAM_RATION_COMMON.h
//  sy-pointReg
//
//  Created by Stenson on 16/8/23.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

/**
 *  @author Stenson, 16-08-24 14:08:51
 *
 *  任务详情Model
 *
 
 */

#import <Foundation/Foundation.h>

@interface ZEEPM_TEAM_RATION_COMMON : NSObject

@property (nonatomic,copy) NSString * CATEGORYCODE;
@property (nonatomic,copy) NSString * CATEGORYPARENTID;
@property (nonatomic,copy) NSString * CONVERSIONCOEFFICIENT;
@property (nonatomic,copy) NSString * CONVERSIONUNITS;
@property (nonatomic,copy) NSString * DESCR;
@property (nonatomic,copy) NSString * DISPATCHTYPE;
@property (nonatomic,copy) NSString * DISPLAYORDER;
@property (nonatomic,copy) NSString * IFSTATISTICTYPE;
@property (nonatomic,copy) NSString * ISVALID;
@property (nonatomic,copy) NSString * ORGCODE;
@property (nonatomic,copy) NSString * QSTANDARD;
@property (nonatomic,copy) NSString * RATIONCODE;
@property (nonatomic,copy) NSString * RATIONCONTENT;
@property (nonatomic,copy) NSString * RATIONFORM;
@property (nonatomic,copy) NSString * RATIONNAME;
@property (nonatomic,copy) NSString * RATIONTYPE;
@property (nonatomic,copy) NSString * SEQKEY;
@property (nonatomic,copy) NSString * STANDARDOPERATIONNUM;
@property (nonatomic,copy) NSString * STANDARDOPERATIONTIME;
@property (nonatomic,copy) NSString * STATISTICTYPE;
@property (nonatomic,copy) NSString * STDSCORE;
@property (nonatomic,copy) NSString * SUITUNIT;
@property (nonatomic,copy) NSString * SYSCOMPANYID;
@property (nonatomic,copy) NSString * SYSCREATEDATE;
@property (nonatomic,copy) NSString * SYSCREATORID;
@property (nonatomic,copy) NSString * SYSDEPTID;
@property (nonatomic,copy) NSString * SYSUPDATEDATE;
@property (nonatomic,copy) NSString * SYSUPDATORID;
@property (nonatomic,copy) NSString * UNIT;
@property (nonatomic,copy) NSString * WORKINGPROCEDURE;
@property (nonatomic,copy) NSString * WSTANDARD;

+(ZEEPM_TEAM_RATION_COMMON *)getDetailWithDic:(NSDictionary *)dic;

@end
