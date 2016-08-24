//
//  ZEUUM_FUNCTION_MODEL.h
//  sy-pointReg
//
//  Created by Stenson on 16/8/23.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZEUUM_FUNCTION_MODEL : NSObject

@property (nonatomic,copy) NSString * ENTRYURL;
@property (nonatomic,copy) NSString * FUNCTIONCODE;
@property (nonatomic,copy) NSString * FUNCTIONID;
@property (nonatomic,copy) NSString * FUNCTIONNAME;
@property (nonatomic,copy) NSString * ICON;
@property (nonatomic,copy) NSString * PARENTFUNCTIONID;

+(ZEUUM_FUNCTION_MODEL *)getDetailWithDic:(NSDictionary *)dic;

@end
