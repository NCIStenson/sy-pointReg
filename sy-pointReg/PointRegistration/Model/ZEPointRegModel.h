//
//  ZEPointRegModel.h
//  NewCentury
//
//  Created by Stenson on 16/1/22.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZEPointRegModel : NSObject

/*      工作任务列表        */
@property (nonatomic,copy) NSString * DISPATCH_TYPE;
@property (nonatomic,copy) NSString * SUITUNIT;
@property (nonatomic,copy) NSString * TRC_ID;
@property (nonatomic,copy) NSString * TRC_NAME;
@property (nonatomic,copy) NSString * TR_HOUR;
@property (nonatomic,copy) NSString * TR_NAME;
@property (nonatomic,copy) NSString * scan_TR_NAME;
@property (nonatomic,copy) NSString * scan_TR_HOUR;
@property (nonatomic,copy) NSString * TR_REMARK;
@property (nonatomic,copy) NSString * TR_UNIT;
@property (nonatomic,copy) NSString * TR_VALID;
@property (nonatomic,copy) NSString * USER_ORGID;
@property (nonatomic,copy) NSString * seqkey;
@property (nonatomic,copy) NSString * workrole;

@property (nonatomic,copy) NSString * NDXS_LEVEL;// 难度系数
@property (nonatomic,copy) NSString * NDXS_SCORE;// 难度分数
@property (nonatomic,copy) NSString * TWR_NAME;//   工作角色
@property (nonatomic,copy) NSString * TWR_QUOTIETY;//   工作角色

+(ZEPointRegModel *)getDetailWithDic:(NSDictionary *)dic;

@end
