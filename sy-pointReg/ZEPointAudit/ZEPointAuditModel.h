//
//  ZEPointAuditModel.h
//  NewCentury
//
//  Created by Stenson on 16/2/18.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZEPointAuditModel : NSObject

@property (nonatomic,copy) NSString * REALKEY;          //  实际工时
@property (nonatomic,copy) NSString * SEQKEY;           //   工作任务
@property (nonatomic,copy) NSString * SOURCES;          //   发生日期
@property (nonatomic,copy) NSString * TT_CONTENT;       //   核定工时
@property (nonatomic,copy) NSString * TT_ENDDATE;       //      结束时间
@property (nonatomic,copy) NSString * TT_FLAG;          //    是否审核
@property (nonatomic,copy) NSString * TT_PERIOD;        //
@property (nonatomic,copy) NSString * TT_REMARK;        //   备注
@property (nonatomic,copy) NSString * TTP_NAME;        //   备注

/*************   任务名称  ****************/
@property (nonatomic,copy) NSString * TT_TASK;


@property (nonatomic,copy) NSString * REAL_HOUR;            //   实际工时
@property (nonatomic,copy) NSString * TT_HOUR;              //   核定工时
@property (nonatomic,copy) NSString * DISPATCH_TYPE;        //   分摊类型
@property (nonatomic,copy) NSString * NDSX_NAME;            //   难度系数（中文）
@property (nonatomic,copy) NSString * SJSX_NAME;            //   时间系数（中文）
@property (nonatomic,copy) NSString * SJXS;                 //   时间系数（数值）
@property (nonatomic,copy) NSString * NDXS;                 //   难度系数（数值）
@property (nonatomic,copy) NSString * ROLENAME;     //  工作角色
@property (nonatomic,copy) NSString * TIMES;        //  工作次数
@property (nonatomic,copy) NSString * TTP_QUOTIETY; //  角色系数

@property (nonatomic,retain) NSDictionary * integration;

+(ZEPointAuditModel *)getDetailWithDic:(NSDictionary *)dic;

@end
