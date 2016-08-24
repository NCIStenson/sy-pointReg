//
//  ZEEPM_TEAM_RATIONTYPE.h
//  sy-pointReg
//
//  Created by Stenson on 16/8/24.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

/**
 *  @author Stenson, 16-08-24 14:08:10
 *
 *  分摊类型Model
 */

#import <Foundation/Foundation.h>

@interface ZEEPM_TEAM_RATIONTYPE : NSObject

@property (nonatomic,copy) NSString * RATIONTYPECODE;
@property (nonatomic,copy) NSString * RATIONTYPENAME;
@property (nonatomic,copy) NSString * SEQKEY;
@property (nonatomic,copy) NSString * FORMULA;
@property (nonatomic,copy) NSString * ISAVG;
@property (nonatomic,copy) NSString * ISSELECT;

+(ZEEPM_TEAM_RATIONTYPE *)getDetailWithDic:(NSDictionary *)dic;


@end
