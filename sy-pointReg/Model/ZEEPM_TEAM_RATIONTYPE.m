//
//  ZEEPM_TEAM_RATIONTYPE.m
//  sy-pointReg
//
//  Created by Stenson on 16/8/24.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEEPM_TEAM_RATIONTYPE.h"

static ZEEPM_TEAM_RATIONTYPE * model = nil;

@implementation ZEEPM_TEAM_RATIONTYPE

+(ZEEPM_TEAM_RATIONTYPE *)getDetailWithDic:(NSDictionary *)dic
{
    model = [[ZEEPM_TEAM_RATIONTYPE alloc]init];
    
    model.RATIONTYPECODE = [NSString stringWithFormat:@"%@",[dic objectForKey:@"RATIONTYPECODE"]];
    model.RATIONTYPENAME = [dic objectForKey:@"RATIONTYPENAME"];
    model.FORMULA        = [dic objectForKey:@"FORMULA"];
    model.ISAVG          = [dic objectForKey:@"ISAVG"];
    model.ISSELECT       = [dic objectForKey:@"ISSELECT"];
    model.SEQKEY         = [dic objectForKey:@"SEQKEY"];

    return  model;
}

@end
