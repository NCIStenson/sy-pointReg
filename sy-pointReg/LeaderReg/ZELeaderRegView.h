//
//  ZELeaderRegView.h
//  sy-pointReg
//
//  Created by Stenson on 16/8/26.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZELeaderRegView;

@protocol ZELeaderRegViewDelegate <NSObject>

/**
 *  选择工分登记界面row
 */
-(void)didSelectRowAtIndexpath:(NSIndexPath *)indexpath;



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

/**
 *  @author Stenson, 16-08-29 15:08:28
 *
 *  显示工作人员列表
 */
-(void)showWorkerListView;

@end

@interface ZELeaderRegView : UIView

@property (nonatomic,strong) NSMutableDictionary * CHOOSEDRATIONTYPEVALUEDic;
@property (nonatomic,strong) NSMutableArray * USERCHOOSEDWORKERVALUEARR;  // 用户选择的人员任务系数
@property (nonatomic,strong) NSMutableArray * recordLengthArr; // 实录工序时长

@property (nonatomic,weak) id <ZELeaderRegViewDelegate> delegate;

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
 *  @author Stenson, 16-08-29 15:08:34
 *
 *  显示工作人员列表
 *
 *  @param arr <#arr description#>
 */
-(void)showWorkerListView:(NSArray *)arr;
/**
 *  刷新表
 */
-(void)reloadContentView;
-(void)reloadContentView:(NSArray *)recordLen withRationTypeValue:(NSArray *)peronalRationTypeValue;
/**
 *  提交成功
 */
-(void)submitSuccessReloadContentView;

@end
