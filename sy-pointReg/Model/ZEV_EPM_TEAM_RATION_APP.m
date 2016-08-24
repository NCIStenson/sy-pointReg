//
//  ZEV_EPM_TEAM_RATION_APP.m
//  sy-pointReg
//
//  Created by Stenson on 16/8/23.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEV_EPM_TEAM_RATION_APP.h"
static ZEV_EPM_TEAM_RATION_APP * model = nil;

@implementation ZEV_EPM_TEAM_RATION_APP

+(ZEV_EPM_TEAM_RATION_APP *)getDetailWithDic:(NSDictionary *)dic
{
    model = [[ZEV_EPM_TEAM_RATION_APP alloc]init];
    
    model.CATEGORYCODE = [dic objectForKey:@"CATEGORYCODE"];
    model.CATEGORYNAME = [dic objectForKey:@"CATEGORYNAME"];
    model.DISPLAYORDER = [dic objectForKey:@"DISPLAYORDER"];
    model.ORGCODE      = [dic objectForKey:@"ORGCODE"];
    model.RATIONCODE   = [dic objectForKey:@"RATIONCODE"];
    model.RATIONNAME   = [dic objectForKey:@"RATIONNAME"];
    model.SEQKEY       = [dic objectForKey:@"SEQKEY"];
    model.SUITUNIT     = [dic objectForKey:@"SUITUNIT"];
    
    return model;
}


@end
