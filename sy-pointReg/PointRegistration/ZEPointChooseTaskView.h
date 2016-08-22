//
//  ZEPointChooseTaskView.h
//  NewCentury
//
//  Created by Stenson on 16/2/2.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZEPointChooseTaskView;
@protocol ZEPointChooseTaskViewDelegate <NSObject>

/**
 *  完成选择任务列表
 */

-(void)didSeclectTask:(ZEPointChooseTaskView *)taskView withData:(NSDictionary *)dic;
@end

@interface ZEPointChooseTaskView : UIView

-(id)initWithOptionArr:(NSArray *)options;

@property (nonatomic,weak) id <ZEPointChooseTaskViewDelegate> delegate;
@end
