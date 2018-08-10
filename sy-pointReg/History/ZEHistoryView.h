//
//  ZEHistoryView.h
//  NewCentury
//
//  Created by Stenson on 16/1/27.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZEHistoryView;
@protocol ZEHistoryViewDelegate <NSObject>

/**
 *  刷新界面
 */
-(void)loadNewData:(ZEHistoryView * )hisView;

/**
 *  加载更多数据
 */
-(void)loadMoreData:(ZEHistoryView * )hisView;
/**
 *  进入修改页面
 */
-(void)enterDetailView:(NSString *)seqkey;
/**
 *  开始查询
 */
-(void)beginSearch:(ZEHistoryView *)hisView withStartDate:(NSString *)startDate withEndDate:(NSString *)endDate witnPeopleName:(NSString *)name;

/**
 *  删除未审核历史记录
 */
-(void)deleteHistory:(NSString * )seqkey;

/**
 *  返回
 */
-(void)goBack;

@end

@interface ZEHistoryView : UIView

@property (nonatomic,assign) id <ZEHistoryViewDelegate> delegate;

-(id)initWithFrame:(CGRect)rect;
/**
 *  刷新数据
 */
-(void)reloadFirstView:(NSArray *)array;
/**
 *  刷新数据
 */
-(void)reloadView:(NSArray *)array;
/**
 *    没有更多数据了
 */

-(void)loadNoMoreData;
/**
 *    加载更多数据
 */
-(void)canLoadMoreData;
/**
 *  停止刷新
 */
-(void)headerEndRefreshing;
/**
 *  隐藏弹出框
 */
-(void)showAlertView:(BOOL)isShow;

@end
