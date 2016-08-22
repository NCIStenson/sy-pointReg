//
//  ZEAlertSearchView.h
//  NewCentury
//
//  Created by Stenson on 16/2/1.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZEAlertSearchViewDlegate <NSObject>

/**
 *  取消查询
 */

-(void)cancelSearch;

/**
 *  确定查询
 */

-(void)confirmSearchStartDate:(NSString *)startDate endDate:(NSString *)endDate;


@end

@interface ZEAlertSearchView : UIView
@property (nonatomic,assign) id <ZEAlertSearchViewDlegate> delegate;

-(id)initWithFrame:(CGRect)frame;

@end
