//
//  ZbarOverlayView.h
//  MeiNianTJ
//
//  Created by limi on 15/8/12.
//  Copyright (c) 2015年 limi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZbarOverlayView;

@protocol ZbarOverlayViewDelegate <NSObject>

-(void)logout;

/**
 * 返回主界面
 */
-(void)goBack;

@end

@interface ZbarOverlayView : UIView{

}
/**
 *  透明扫描框的区域
 */
@property (nonatomic, assign) CGRect transparentArea;
@property (nonatomic, assign) id <ZbarOverlayViewDelegate> delegate;
-(void)startAnimation;
-(void)stopAnimation;
@end
