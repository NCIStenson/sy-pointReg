//
//  ZEMainView.h
//  WeiXueTang
//
//  Created by Stenson on 16/3/3.
//  Copyright © 2016年  Zenith Electronic Technology Co., Ltd. All rights reserved.
//

@class ZEMainView;
@protocol ZEMainViewDelegate <NSObject>

/**
 *  @author Stenson, 16-03-07 09:03:24
 *
 *  进入扫描页面
 */
-(void)goLeaderView;

/**
 *  进入工分登记页面
 */
-(void)goPointReg;

/**
 *  进入历史查询界面
 */
-(void)goHistory;

/**
 *  进入工分审核界面
 */
-(void)goPointAudit;
/**
 *  工时查看
 */
-(void)goPointQuery;
/**
 *  退出登录
 */
-(void)logout;

@end


#import <UIKit/UIKit.h>

@interface ZEMainView : UIView

@property (nonatomic,assign) id <ZEMainViewDelegate> delegate;

-(id)initWithFrame:(CGRect)rect;

-(void)reloadHomeView:(NSArray *)data;

@end
