//
//  ZEHistoryDetailView.h
//  NewCentury
//
//  Created by Stenson on 16/2/17.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZEHistoryModel.h"

@protocol ZEHistoryDetailViewDelegate <NSObject>

/**
 *  返回
 */
-(void)goBack;

/**
 *  确认审核
 */
-(void)confirmAudit:(NSString *)auditKey;

@end

@interface ZEHistoryDetailView : UIView<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property(nonatomic,assign) id <ZEHistoryDetailViewDelegate> delegate;

-(id)initWithFrame:(CGRect)rect withModel:(id)model withEnterType:(ENTER_FIXED_POINTREG_TYPE)enterType;

@end
