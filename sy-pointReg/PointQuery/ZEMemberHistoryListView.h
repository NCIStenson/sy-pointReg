//
//  ZEMemberHistoryListView.h
//  sy-pointReg
//
//  Created by Stenson on 17/5/23.
//  Copyright © 2017年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZEMemberHistoryListView;

@protocol ZEMemberHistoryListViewDelegate <NSObject>

-(void)goQueryMemberVC;

@end


@interface ZEMemberHistoryListView : UIView

@property (nonatomic,weak) id <ZEMemberHistoryListViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame;

-(void)reloadContentData:(NSArray *)arr;
@end
