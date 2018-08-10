//
//  ZEEPM_TEAM_RATION_REGModel.m
//  sy-pointReg
//
//  Created by Stenson on 16/9/6.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEEPM_TEAM_RATION_REGModel.h"

static ZEEPM_TEAM_RATION_REGModel * model = nil;

@implementation ZEEPM_TEAM_RATION_REGModel

+(ZEEPM_TEAM_RATION_REGModel *)getDetailWithDic:(NSDictionary *)dic
{
    model = [[ZEEPM_TEAM_RATION_REGModel alloc]init];
    
    if([ZEUtil isNotNull:[dic objectForKey:@"ADDMODE"]]){
        model.ADDMODE               = [dic objectForKey:@"ADDMODE"];
    }
    model.BEGINDATE             = [dic objectForKey:@"BEGINDATE"];
    model.CATEGORYCODE          = [dic objectForKey:@"CATEGORYCODE"];
    model.CATEGORYNAME          = [dic objectForKey:@"CATEGORYNAME"];
    model.CONVERSIONCOEFFICIENT = [dic objectForKey:@"CONVERSIONCOEFFICIENT"];
    model.CONVERSIONUNITS       = [dic objectForKey:@"CONVERSIONUNITS"];
    if ([ZEUtil isNotNull:[dic objectForKey:@"DESCR"]]) {
        model.DESCR                 = [dic objectForKey:@"DESCR"];
    }
    model.DISPATCHTYPE          = [dic objectForKey:@"DISPATCHTYPE"];
    model.DISPLAYORDER          = [dic objectForKey:@"DISPLAYORDER"];
    model.ENDDATE               = [[dic objectForKey:@"ENDDATE"] stringByReplacingOccurrencesOfString:@" 00:00:00.0" withString:@""];
    model.FUNCTIONMODEL         = [dic objectForKey:@"FUNCTIONMODEL"];
    model.ORGCODE               = [dic objectForKey:@"ORGCODE"];
    model.PERIODCODE            = [dic objectForKey:@"PERIODCODE"];
    model.PSNNAME               = [dic objectForKey:@"PSNNAME"];
    model.PSNNUM              = [dic objectForKey:@"PSNNUM"];

    model.QSTANDARD             = [dic objectForKey:@"QSTANDARD"];
    model.QUOTIETY1             = [dic objectForKey:@"QUOTIETY1"];
    if ([ZEUtil isNotNull:[dic objectForKey:@"QUOTIETY1CODE"]]) {
        model.QUOTIETY1CODE         = [dic objectForKey:@"QUOTIETY1CODE"];
    }
    model.QUOTIETY2             = [dic objectForKey:@"QUOTIETY2"];
    model.QUOTIETY2CODE         = [dic objectForKey:@"QUOTIETY2CODE"];
    model.QUOTIETY3             = [dic objectForKey:@"QUOTIETY3"];
    model.QUOTIETY3CODE         = [dic objectForKey:@"QUOTIETY3CODE"];
    model.QUOTIETY4             = [dic objectForKey:@"QUOTIETY4"];
    model.QUOTIETY4CODE         = [dic objectForKey:@"QUOTIETY4CODE"];
    model.QUOTIETY5             = [dic objectForKey:@"QUOTIETY5"];
    model.QUOTIETY5CODE         = [dic objectForKey:@"QUOTIETY5CODE"];
    model.QUOTIETY6             = [dic objectForKey:@"QUOTIETY6"];
    model.QUOTIETY6CODE         = [dic objectForKey:@"QUOTIETY6CODE"];
    model.RATIONCODE            = [dic objectForKey:@"RATIONCODE"];
    model.RATIONCONTENT         = [dic objectForKey:@"RATIONCONTENT"];
    model.RATIONFORM            = [dic objectForKey:@"RATIONFORM"];
    model.RATIONID              = [dic objectForKey:@"RATIONID"];
    model.RATIONNAME            = [dic objectForKey:@"RATIONNAME"];
    model.RATIONTYPE            = [dic objectForKey:@"RATIONTYPE"];
    model.SELF                  = [dic objectForKey:@"SELF"];
    model.SEQKEY                = [dic objectForKey:@"SEQKEY"];
    model.STANDARDOPERATIONNUM  = [dic objectForKey:@"STANDARDOPERATIONNUM"];
    if ([ZEUtil isNotNull:[dic objectForKey:@"STANDARDOPERATIONTIME"]]) {
        model.STANDARDOPERATIONTIME         = [dic objectForKey:@"STANDARDOPERATIONTIME"];
    }

    if ([ZEUtil isNotNull:[dic objectForKey:@"STATISTICTYPE"]]) {
        model.STATISTICTYPE         = [dic objectForKey:@"STATISTICTYPE"];
    }
    model.STATUS                = [dic objectForKey:@"STATUS"];
    model.STDSCORE              = [dic objectForKey:@"STDSCORE"];
    model.SUITUNIT              = [dic objectForKey:@"SUITUNIT"];
    model.SYSCOMPANYID          = [dic objectForKey:@"SYSCOMPANYID"];
    model.SYSCREATEDATE         = [dic objectForKey:@"SYSCREATEDATE"];
    model.SYSCREATORID          = [dic objectForKey:@"SYSCREATORID"];
    model.SYSDEPTID             = [dic objectForKey:@"SYSDEPTID"];
    model.SYSUPDATEDATE         = [dic objectForKey:@"SYSUPDATEDATE"];
    model.SYSUPDATORID          = [dic objectForKey:@"SYSUPDATORID"];
    model.UNIT                  = [dic objectForKey:@"UNIT"];
    if ([ZEUtil isNotNull:[dic objectForKey:@"WORKINGPROCEDURE"]]) {
        model.WORKINGPROCEDURE      = [dic objectForKey:@"WORKINGPROCEDURE"];
    }
    model.SUMPOINTS             = [dic objectForKey:@"SUMPOINTS"];
    model.FINALSCORE            = [dic objectForKey:@"FINALSCORE"];
    
    model.TASKID            = [dic objectForKey:@"TASKID"];
    model.WORKPOINTS            = [dic objectForKey:@"WORKPOINTS"];

    return model;
}

@end
