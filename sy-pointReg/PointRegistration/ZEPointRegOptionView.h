//
//  PointRegOptionView.h
//  NewCentury
//
//  Created by Stenson on 16/1/21.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZEPointRegOptionViewDelegate <NSObject>
/**
 *  @author Zenith Electronic, 16-02-23 14:02:21
 *
 *  自定义弹出框提示
 *
 *  @param object 选择的数据
 *  @param row    选择弹出框第几行
 */
-(void)didSelectOption:(NSDictionary *)object withRow:(NSInteger)row;

/**
 *  隐藏常用列表弹出框
 */
-(void)hiddeAlertView;

@end;

@interface ZEPointRegOptionView : UIView

@property (nonatomic,assign) id <ZEPointRegOptionViewDelegate> delegate;

/**
 *  初始化弹出框界面
 *  showBut   是否显示 “确定” “取消” 按钮
 *  level     固定文字数组 或者 包涵json数组时处理方式不同
 */
-(id)initWithOptionArr:(NSArray *)options showButtons:(BOOL)showBut withLevel:(TASK_LIST_LEVEL)level withPointReg:(POINT_REG)pointReg;

@end
