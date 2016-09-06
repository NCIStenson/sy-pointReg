//
//  ZECalculateTotalPoint.h
//  sy-pointReg
//
//  Created by Stenson on 16/8/26.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZECalculateTotalPoint : NSObject

+(instancetype)instance;

-(void)getTotalPointTaskDic:(NSDictionary *)rationDic withPersonalDetailArr:(NSArray *)personalData;

-(NSDictionary *)getResultDic;

@end
