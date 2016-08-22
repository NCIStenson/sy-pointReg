//
//  ZEPointRegChooseDateView.h
//  NewCentury
//
//  Created by Stenson on 16/1/21.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZEPointRegChooseDateViewDelegate <NSObject>
/**
 *  取消
 */
-(void)cancelChooseDate;
/**
 *  确定
 */
-(void)confirmChooseDate:(NSString *)dateStr;

@end

@interface ZEPointRegChooseDateView : UIView

@property (nonatomic,assign) id <ZEPointRegChooseDateViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame;

@end
