//
//  ZEPointRegChooseCountView.h
//  NewCentury
//
//  Created by Stenson on 16/3/15.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZEPointRegChooseCountViewDelegate <NSObject>
/**
 *  取消
 */
-(void)cancelChooseCount;
/**
 *  确定
 */
-(void)confirmChooseCount:(NSString *)countStr;

@end
@interface ZEPointRegChooseCountView : UIView

@property (nonatomic,weak) id <ZEPointRegChooseCountViewDelegate> delegate;

@end
