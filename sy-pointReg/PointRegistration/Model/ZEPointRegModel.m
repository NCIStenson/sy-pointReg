//
//  ZEPointRegModel.m
//  NewCentury
//
//  Created by Stenson on 16/1/22.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEPointRegModel.h"

static ZEPointRegModel * pointReg = nil;
@implementation ZEPointRegModel

+(ZEPointRegModel *)getDetailWithDic:(NSDictionary *)dic
{
    pointReg = [[ZEPointRegModel alloc]init];
    
    pointReg.DISPATCH_TYPE  = [dic objectForKey:@"dispatchType"];
    pointReg.SUITUNIT       = [dic objectForKey:@"suitunit"];
    pointReg.TRC_ID         = [dic objectForKey:@"trcId"];
    pointReg.TRC_NAME       = [dic objectForKey:@"trcName"];
    pointReg.TR_HOUR        = [NSString stringWithFormat:@"%.2f",[[dic objectForKey:@"trHour"] floatValue]];
    pointReg.TR_NAME        = [dic objectForKey:@"trName"];
    pointReg.scan_TR_NAME   = [dic objectForKey:@"TR_NAME"];
    pointReg.scan_TR_HOUR   = [NSString stringWithFormat:@"%.2f",[[dic objectForKey:@"TR_HOUR"] floatValue]];
    pointReg.TR_REMARK      = [dic objectForKey:@"trRemark"];
    pointReg.TR_UNIT        = [dic objectForKey:@"userUnitid"];
    pointReg.TR_VALID       = [dic objectForKey:@"trValid"];
    pointReg.USER_ORGID     = [dic objectForKey:@"userOrgid"];
    pointReg.seqkey         = [dic objectForKey:@"seqkey"];
    pointReg.workrole       = [dic objectForKey:@"workrole"];
    
    pointReg.NDXS_LEVEL     = [dic objectForKey:@"NDXS_LEVEL"];
    pointReg.NDXS_SCORE     = [dic objectForKey:@"NDXS_SCORE"];
    pointReg.TWR_NAME       = [dic objectForKey:@"TWR_NAME"];
    pointReg.TWR_QUOTIETY   = [dic objectForKey:@"TWR_QUOTIETY"];
    
    return pointReg;
}

@end
