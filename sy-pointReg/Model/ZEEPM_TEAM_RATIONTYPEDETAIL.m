//
//  ZEEPM_TEAM_RATIONTYPEDETAIL.m
//  sy-pointReg
//
//  Created by Stenson on 16/8/25.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEEPM_TEAM_RATIONTYPEDETAIL.h"

static ZEEPM_TEAM_RATIONTYPEDETAIL * model = nil;

@implementation ZEEPM_TEAM_RATIONTYPEDETAIL

+(ZEEPM_TEAM_RATIONTYPEDETAIL *)getDetailWithDic:(NSDictionary *)dic
{
    model = [[ZEEPM_TEAM_RATIONTYPEDETAIL alloc]init];
    
    model.DESCR          = [dic objectForKey:@"DESCR"];
    model.DISPLAYORDER   = [dic objectForKey:@"DISPLAYORDER"];
    model.EPMGLOBAL      = [dic objectForKey:@"EPMGLOBAL"];
    model.FIELDDISPLAY   = [dic objectForKey:@"FIELDDISPLAY"];
    model.FIELDEDITOR    = [dic objectForKey:@"FIELDEDITOR"];
    model.FIELDNAME      = [dic objectForKey:@"FIELDNAME"];
    model.FORMULA        = [dic objectForKey:@"FORMULA"];
    model.FWIDTH         = [dic objectForKey:@"FWIDTH"];
    model.ISRATION       = [dic objectForKey:@"ISRATION"];
    model.ISSELECT       = [dic objectForKey:@"ISSELECT"];
    model.MINVALUE       = [dic objectForKey:@"MINVALUE"];
    model.RATIONTYPECODE = [dic objectForKey:@"RATIONTYPECODE"];
    model.SUITUNIT       = [dic objectForKey:@"SUITUNIT"];
    model.SEQKEY         = [dic objectForKey:@"SEQKEY"];
    model.DISRANGE       = [dic objectForKey:@"DISRANGE"];
    model.TYPE           = [dic objectForKey:@"TYPE"];

    model.QUOTIETYCODE = [dic objectForKey:@"QUOTIETYCODE"];
    model.QUOTIETYNAME = [dic objectForKey:@"QUOTIETYNAME"];
    model.DEFAULTCODE  = [dic objectForKey:@"DEFAULTCODE"];
    model.QUOTIETY     = [dic objectForKey:@"QUOTIETY"];

    
    return  model;
}

@end
