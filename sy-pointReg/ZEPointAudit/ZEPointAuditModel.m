//
//  ZEPointAuditModel.m
//  NewCentury
//
//  Created by Stenson on 16/2/18.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEPointAuditModel.h"

static ZEPointAuditModel * PAModel = nil;
@implementation ZEPointAuditModel

+(ZEPointAuditModel *)getDetailWithDic:(NSDictionary *)dic
{
    PAModel = [[ZEPointAuditModel alloc]init];
    
    PAModel.TT_ENDDATE    = [dic objectForKey:@"TT_ENDDATE"];
    PAModel.TT_TASK       = [dic objectForKey:@"TT_TASK"];
    PAModel.TT_CONTENT    = [dic objectForKey:@"TT_CONTENT"];
    PAModel.TT_FLAG       = [dic objectForKey:@"TT_FLAG"];
    PAModel.TT_PERIOD     = [dic objectForKey:@"TT_PERIOD"];
    PAModel.TT_REMARK     = [dic objectForKey:@"TT_REMARK"];
    PAModel.REALKEY       = [dic objectForKey:@"REALKEY"];
    PAModel.SEQKEY        = [dic objectForKey:@"seqkey"];
    PAModel.SOURCES       = [dic objectForKey:@"SOURCES"];
    PAModel.TTP_NAME      = [[dic objectForKey:@"integration"] objectForKey:@"TTP_NAME"];
    PAModel.integration   = [dic objectForKey:@"integration"];

    PAModel.REAL_HOUR     = [dic objectForKey:@"REAL_HOUR"];
    PAModel.TT_HOUR       = [dic objectForKey:@"TT_HOUR"];
    PAModel.DISPATCH_TYPE = [dic objectForKey:@"DISPATCH_TYPE"];
    PAModel.NDSX_NAME     = [dic objectForKey:@"NDSX_NAME"];
    PAModel.SJSX_NAME     = [dic objectForKey:@"SJSX_NAME"];

    if([ZEUtil isNotNull:PAModel.integration]){
        PAModel.ROLENAME      = [PAModel.integration objectForKey:@"ROLENAME"];
        PAModel.TIMES         = [PAModel.integration objectForKey:@"TIMES"];
    }
    return PAModel;
}

@end
