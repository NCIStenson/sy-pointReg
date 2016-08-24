//
//  ZEEPM_TEAM_RATION_COMMON.m
//  sy-pointReg
//
//  Created by Stenson on 16/8/23.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEEPM_TEAM_RATION_COMMON.h"

static ZEEPM_TEAM_RATION_COMMON * model = nil;

@implementation ZEEPM_TEAM_RATION_COMMON

+(ZEEPM_TEAM_RATION_COMMON *)getDetailWithDic:(NSDictionary *)dic
{
    model = [[ZEEPM_TEAM_RATION_COMMON alloc]init];
    
    model.CATEGORYCODE          = [dic objectForKey:@"CATEGORYCODE"];
    model.CATEGORYPARENTID      = [dic objectForKey:@"CATEGORYPARENTID"];
    model.CONVERSIONUNITS       = [dic objectForKey:@"CONVERSIONUNITS"];
    model.CONVERSIONCOEFFICIENT = [dic objectForKey:@"CONVERSIONCOEFFICIENT"];
    model.DESCR                 = [dic objectForKey:@"DESCR"];
    model.DISPATCHTYPE          = [dic objectForKey:@"DISPATCHTYPE"];
    model.DISPLAYORDER          = [dic objectForKey:@"DISPLAYORDER"];
    model.IFSTATISTICTYPE       = [dic objectForKey:@"IFSTATISTICTYPE"];
    model.ISVALID               = [dic objectForKey:@"ISVALID"];
    model.ORGCODE               = [dic objectForKey:@"ORGCODE"];
    model.QSTANDARD             = [dic objectForKey:@"QSTANDARD"];
    model.RATIONNAME            = [dic objectForKey:@"RATIONNAME"];
    model.RATIONCODE            = [dic objectForKey:@"RATIONCODE"];
    model.RATIONFORM            = [dic objectForKey:@"RATIONFORM"];
    model.RATIONTYPE            = [dic objectForKey:@"RATIONTYPE"];
    model.RATIONCONTENT         = [dic objectForKey:@"RATIONCONTENT"];
    model.SEQKEY                = [dic objectForKey:@"SEQKEY"];
    model.STANDARDOPERATIONNUM  = [dic objectForKey:@"STANDARDOPERATIONNUM"];
    model.STANDARDOPERATIONTIME = [dic objectForKey:@"STANDARDOPERATIONTIME"];
    model.STATISTICTYPE         = [dic objectForKey:@"STATISTICTYPE"];
    model.STDSCORE              = [NSString stringWithFormat:@"%@",[dic objectForKey:@"STDSCORE"]];
    model.SUITUNIT              = [dic objectForKey:@"SUITUNIT"];
    model.SYSDEPTID             = [dic objectForKey:@"SYSDEPTID"];
    model.SYSCOMPANYID          = [dic objectForKey:@"SYSCOMPANYID"];
    model.SYSCREATEDATE         = [dic objectForKey:@"SYSCREATEDATE"];
    model.SYSCREATORID          = [dic objectForKey:@"SYSCREATORID"];
    model.SYSDEPTID             = [dic objectForKey:@"SYSDEPTID"];
    model.SYSUPDATEDATE         = [dic objectForKey:@"SYSUPDATEDATE"];
    model.SYSUPDATORID          = [dic objectForKey:@"SYSUPDATORID"];
    model.UNIT                  = [dic objectForKey:@"UNIT"];
    model.WORKINGPROCEDURE      = [dic objectForKey:@"WORKINGPROCEDURE"];
    model.WSTANDARD             = [dic objectForKey:@"WSTANDARD"];
    
    return model;
}
@end
