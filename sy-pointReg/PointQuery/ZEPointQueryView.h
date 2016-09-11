//
//  ZEPointQueryView.h
//  sy-pointReg
//
//  Created by Stenson on 16/9/11.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZEPointQueryView : UIView

-(id)initWithFrame:(CGRect)frame;

#pragma mark - Public Method

-(void)reloadHeader:(NSString *)pointStr withTimeStr:(NSString *)timeStr;

-(void)reloadContentData:(NSArray *)arr;

@end
