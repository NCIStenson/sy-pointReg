//
//  ZELeaderRegVC.h
//  sy-pointReg
//
//  Created by Stenson on 16/8/26.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZESettingRootVC.h"

@interface ZELeaderRegVC : ZESettingRootVC

@property (nonatomic,assign) ENTER_PERSON_POINTREG_TYPE regType; // 审核修改或者 历史修改

@property (nonatomic,assign) ENTER_POINTREG_TYPE pointRegType; // 是否显示各项系数

@property (nonatomic,assign) ENTER_MANYPERSON_POINTREG_TYPE isLeaderOrCharge; // 负责人录入或者班组长录入

@property (nonnull,nonatomic,strong) NSDictionary * defaultDic;
@property (nonnull,nonatomic,strong) NSArray * defaultDetailArr;

@property (nonnull,nonatomic,strong) NSArray * recordLengthArr;
@property (nonnull,nonatomic,strong) NSArray * rationTypeValueArr; // 个性化下拉框值

@end
