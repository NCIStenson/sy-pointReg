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
-(void)view:(ZEPointRegistrationView *)pointRegView didSelectRowAtIndexpath:(NSIndexPath *)indexpath withShowRules:(BOOL)showRules;

/**
 *  提交
 */
-(void)goSubmit:(ZEPointRegistrationView *)pointRegView withShowRoles:(BOOL)showRoles withShowCount:(BOOL)showCount;

/**
 *  返回扫描界面
 */
-(void)goBack;

@end

@interface ZEPointRegistrationView : UIView

@property (nonatomic,retain) ZEHistoryModel * historyModel;     // 从历史界面进入工分登记修改数据
@property (nonatomic,assign) id <ZEPointRegistrationViewDelegate> delegate;

-(id)initWithFrame:(CGRect)rect withEnterType:(ENTER_POINTREG_TYPE)enterType;

-(void)showListView:(NSArray *)listArr withLevel:(TASK_LIST_LEVEL)level withPointReg:(POINT_REG)pointReg;
/**
 *  显示日期列表
 */
-(void)showDateView;
/**
 *  显示任务列表
 */
-(void)showTaskView:(NSArray *)array;
/**
 *  显示次数选择器
 */
-(void)showCountView;

/**
 *  刷新表
 */
-(void)reloadContentView:(ENTER_POINTREG_TYPE)entertype;

/**
 *  显示隐藏加载菊花
 */
-(void)showProgress;
-(void)hiddenProgress;
@end
