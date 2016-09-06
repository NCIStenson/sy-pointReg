//
//  ZEEPM_TEAM_RATIONTYPEDETAIL.h
//  sy-pointReg
//
//  Created by Stenson on 16/8/25.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZEEPM_TEAM_RATIONTYPEDETAIL : NSObject

@property (nonatomic,copy) NSString * DESCR;
@property (nonatomic,copy) NSString * DISPLAYORDER;
@property (nonatomic,copy) NSString * EPMGLOBAL;
@property (nonatomic,copy) NSString * FIELDDISPLAY;
@property (nonatomic,copy) NSString * FIELDEDITOR;
@property (nonatomic,copy) NSString * FIELDNAME;
@property (nonatomic,copy) NSString * FORMULA;
@property (nonatomic,copy) NSString * FWIDTH;
@property (nonatomic,copy) NSString * ISRATION;
@property (nonatomic,copy) NSString * ISSELECT;
@property (nonatomic,copy) NSString * MINVALUE;
@property (nonatomic,copy) NSString * RATIONTYPECODE;
@property (nonatomic,copy) NSString * SEQKEY;
@property (nonatomic,copy) NSString * SUITUNIT;
@property (nonatomic,copy) NSString * TYPE;

@property (nonatomic,copy) NSString * QUOTIETYCODE;
@property (nonatomic,copy) NSString * QUOTIETYNAME;
@property (nonatomic,copy) NSString * DEFAULTCODE;
@property (nonatomic,copy) NSString * QUOTIETY;



+(ZEEPM_TEAM_RATIONTYPEDETAIL *)getDetailWithDic:(NSDictionary *)dic;


@end
