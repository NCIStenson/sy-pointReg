//
//  ZELeaderRegVC.h
//  sy-pointReg
//
//  Created by Stenson on 16/8/26.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZESettingRootVC.h"

@interface ZELeaderRegVC : ZESettingRootVC

@property (nonatomic,assign) ENTER_PERSON_POINTREG_TYPE regType;

@property (nonnull,nonatomic,strong) NSDictionary * defaultDic;
@property (nonnull,nonatomic,strong) NSArray * defaultDetailArr;


@end
