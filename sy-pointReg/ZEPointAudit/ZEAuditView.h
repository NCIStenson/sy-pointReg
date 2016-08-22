//
//  ZEAuditView.h
//  NewCentury
//
//  Created by Stenson on 16/2/18.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCAlertView.h"
#import "ZEPointRegChooseDateView.h"
@class ZEAuditView;

@protocol ZEAuditViewDelegate <NSObject>

/**
 *  返回
 */

-(void)goBack;
/**
 *  审核
 */
-(void)goAuditWithArr:(NSArray * )auditArr;

/**
 *  根据时间获取不同的审核列表
 */
-(void)refreshDiffDate:(ZEAuditView *)auditView withDateStr:(NSString *)dateStr;

@end

@interface ZEAuditView : UIView<ZEPointRegChooseDateViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign) id <ZEAuditViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame;

-(void)reloadAuditViewWithData:(NSArray *)arr;

@end
