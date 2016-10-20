//
//  ZEPointRegistrationView.h
//  NewCentury
//
//  Created by Stenson on 16/1/21.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZEHistoryModel.h"

@class ZEPointRegistrationView;

@protocol ZEPointRegistrationViewDelegate <NSObject>

/**
 *  选择工分登记界面row
 */
-(void)view:(ZEPointRegistrationView *)pointRegView didSelectRowAtIndexpath:(NSIndexPath *)indexpath;

/**
 *  提交
 */
-(void)goSubmit:(ZEPointRegistrationView *)pointRegView;

/**
 *  返回扫描界面
 */
-(void)goBack;

/**
 *  @author Stenson, 16-08-24 11:08:14
 *
 *  获取任务详情
 *
 *  @param SEQKEY 任务主键
 */
-(void)getTaskDetail:(NSString *)SEQKEY;

/**
 *  @author Stenson, 16-08-25 14:08:59
 *
 *  根据系数显示不同类型的参数值
 *
 *  @param QUOTIETYCODE 系数code
 */
-(void)showRATIONTYPEVALUE:(NSString *)QUOTIETYCODE;

@end

@interface ZEPointRegistrationView : UIView

@property (nonatomic,strong) NSMutableDictionary * CHOOSEDRATIONTYPEVALUEDic;
@property (nonatomic,strong) NSMutableArray * USERCHOOSEDWORKERVALUEARR;  // 用户选择的人员任务系数

@property (nonatomic,strong) NSMutableArray * recordLengthArr; // 实录工序时长
@property (nonatomic,strong) NSArray * rationTypeValueArr; // 个性化下拉框值

@property (nonatomic,retain) ZEHistoryModel * historyModel;     // 从历史界面进入工分登记修改数据

@property (nonatomic,assign) id <ZEPointRegistrationViewDelegate> delegate;

-(id)initWithFrame:(CGRect)rect
     withDafaulDic:(NSDictionary *)dic
withDefaultDetailArr:(NSArray *)arr
withRecordLengthArr:(NSArray *)lengthArr
withRationTypeValue:(NSArray *)rationTypeArr
     withEnterType:(ENTER_PERSON_POINTREG_TYPE)type;

-(void)showListView:(NSArray *)listArr withLevel:(TASK_LIST_LEVEL)level withPointReg:(POINT_REG)pointReg;
/**
 *  显示日期列表
 */
-(void)showDateView;
/**
 *  显示任务列表
 */
-(void)showTaskView:(NSArray *)array withConditionType:(POINT_REG)type;
/**
 *  显示次数选择器
 */
-(void)showCountView;

/**
 *  刷新表
 */
-(void)reloadContentView;
-(void)reloadContentView:(NSArray *)recordLen withRationTypeValue:(NSArray *)peronalRationTypeValue;

/**
 *  提交成功
 */

-(void)submitSuccessReloadContentView;
/**
 *  显示隐藏加载菊花
 */
-(void)showProgress;
-(void)hiddenProgress;
@end
