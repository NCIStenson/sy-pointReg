//
//  ZEMemberHistoryListView.h
//  sy-pointReg
//
//  Created by Stenson on 17/5/23.
//  Copyright © 2017年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZEEPM_TEAM_RATION_REGModel.h"

typedef void(^selectBlock)(ZEEPM_TEAM_RATION_REGModel * model);

@class ZEMemberHistoryListView;

@protocol ZEMemberHistoryListViewDelegate <NSObject>

-(void)goQueryMemberVC;

@end


@interface ZEMemberHistoryListView : UIView

@property (nonatomic,weak) id <ZEMemberHistoryListViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame withType:(ENTER_MEMBERLIST)type;

-(void)reloadContentData:(NSArray *)arr;

@property(nonatomic,assign) ENTER_MEMBERLIST enterType;
@property (nonatomic, copy) selectBlock block;



@end
