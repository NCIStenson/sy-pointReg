//
//  ZEUUM_FUNCTION_MODEL.m
//  sy-pointReg
//
//  Created by Stenson on 16/8/23.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

/**
 *  @author Stenson, 16-08-24 14:08:23
 *
 *  首页按钮Model
 */

#import "ZEUUM_FUNCTION_MODEL.h"

static ZEUUM_FUNCTION_MODEL * model = nil;

@implementation ZEUUM_FUNCTION_MODEL
+(ZEUUM_FUNCTION_MODEL *)getDetailWithDic:(NSDictionary *)dic
{
    model = [[ZEUUM_FUNCTION_MODEL alloc]init];
    
    model.ENTRYURL         = [dic objectForKey:@"ENTRYURL"];
    model.FUNCTIONCODE     = [dic objectForKey:@"FUNCTIONCODE"];
    model.FUNCTIONID       = [dic objectForKey:@"FUNCTIONID"];
    model.FUNCTIONNAME     = [dic objectForKey:@"FUNCTIONNAME"];
    model.ICON             = [dic objectForKey:@"ICON"];
    model.PARENTFUNCTIONID = [dic objectForKey:@"PARENTFUNCTIONID"];
    
    return model;
}

@end
