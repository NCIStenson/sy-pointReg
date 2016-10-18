//
//  ZEEPM_TEAM_RATION_REGModel.h
//  sy-pointReg
//
//  Created by Stenson on 16/9/6.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

/**
 *  @author Stenson, 16-09-06 15:09:29
 *
 *  历史查询界面
 */

#import <Foundation/Foundation.h>

@interface ZEEPM_TEAM_RATION_REGModel : NSObject

@property (nonatomic,copy) NSString * ADDMODE;
@property (nonatomic,copy) NSString * BEGINDATE;
@property (nonatomic,copy) NSString * CATEGORYCODE;
@property (nonatomic,copy) NSString * CATEGORYNAME;
@property (nonatomic,copy) NSString * CONVERSIONCOEFFICIENT;
@property (nonatomic,copy) NSString * CONVERSIONUNITS;
@property (nonatomic,copy) NSString * DESCR;
@property (nonatomic,copy) NSString * DISPATCHTYPE;
@property (nonatomic,copy) NSString * DISPLAYORDER;
@property (nonatomic,copy) NSString * ENDDATE;
@property (nonatomic,copy) NSString * FUNCTIONMODEL;
@property (nonatomic,copy) NSString * ORGCODE;
@property (nonatomic,copy) NSString * ORGNAME;
@property (nonatomic,copy) NSString * PERIODCODE;
@property (nonatomic,copy) NSString * PSNNAME;
@property (nonatomic,copy) NSString * PSNNUM;
@property (nonatomic,copy) NSString * QSTANDARD;
@property (nonatomic,copy) NSString * QUOTIETY1;
@property (nonatomic,copy) NSString * QUOTIETY1CODE;
@property (nonatomic,copy) NSString * QUOTIETY2;
@property (nonatomic,copy) NSString * QUOTIETY2CODE;
@property (nonatomic,copy) NSString * QUOTIETY3;
@property (nonatomic,copy) NSString * QUOTIETY3CODE;
@property (nonatomic,copy) NSString * QUOTIETY4;
@property (nonatomic,copy) NSString * QUOTIETY4CODE;
@property (nonatomic,copy) NSString * QUOTIETY5;
@property (nonatomic,copy) NSString * QUOTIETY5CODE;
@property (nonatomic,copy) NSString * QUOTIETY6;
@property (nonatomic,copy) NSString * QUOTIETY6CODE;
@property (nonatomic,copy) NSString * RATIONCODE;
@property (nonatomic,copy) NSString * RATIONCONTENT;
@property (nonatomic,copy) NSString * RATIONFORM;
@property (nonatomic,copy) NSString * RATIONID;
@property (nonatomic,copy) NSString * RATIONNAME;
@property (nonatomic,copy) NSString * RATIONTYPE;
@property (nonatomic,copy) NSString * SELF;
@property (nonatomic,copy) NSString * SEQKEY;
@property (nonatomic,copy) NSString * STANDARDOPERATIONNUM;
@property (nonatomic,copy) NSString * STANDARDOPERATIONTIME;
@property (nonatomic,copy) NSString * STATISTICTYPE;
@property (nonatomic,copy) NSString * STATUS;
@property (nonatomic,copy) NSString * STDSCORE;
@property (nonatomic,copy) NSString * SUITUNIT;
@property (nonatomic,copy) NSString * SYSCOMPANYID;
@property (nonatomic,copy) NSString * SYSCREATEDATE;
@property (nonatomic,copy) NSString * SYSCREATORID;
@property (nonatomic,copy) NSString * SYSDEPTID;
@property (nonatomic,copy) NSString * SYSUPDATEDATE;
@property (nonatomic,copy) NSString * SYSUPDATORID;
@property (nonatomic,copy) NSString * SUMPOINTS;

@property (nonatomic,copy) NSString * UNIT;
@property (nonatomic,copy) NSString * WORKINGPROCEDURE;

//  汇总表数据
@property (nonatomic,copy) NSString * FINALSCORE;

// 实录工序时长
//CATEGORYCODE = auto614;
//DISPLAYORDER = "";
//RATIONCODE = "auto614_2800";
//SEQKEY = 85;
//STANDARDOPERATIONTIME = "0.05";
//SUITUNIT = SYBDYWS;
//SYSCOMPANYID = "";
//SYSCREATEDATE = "2016-10-13 00:00:00.0";
//SYSCREATORID = 10573047;
//SYSDEPTID = 10183668;
//SYSUPDATEDATE = "";
//SYSUPDATORID = "";
//WORKINGPROCEDURE = "\U52a8\U4ee4";

//@property (nonatomic,copy) NSString * STANDARDOPERATIONTIME;
//@property (nonatomic,copy) NSString * WORKINGPROCEDURE;


+(ZEEPM_TEAM_RATION_REGModel *)getDetailWithDic:(NSDictionary *)dic;


@end
