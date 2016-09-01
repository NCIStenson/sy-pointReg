//
//  ZEChooseWorkerView.h
//  sy-pointReg
//
//  Created by Stenson on 16/8/29.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZEChooseWorkerView;
@protocol ZEChooseWorkerViewDelegate <NSObject>

/**
 *  完成选择任务列表
 */

-(void)didSeclectWorkerWithData:(NSArray *)choosedWorker;

@end

@interface ZEChooseWorkerView : UIView

@property (nonatomic,weak) id <ZEChooseWorkerViewDelegate>delegate;

-(id)initWithOptionArr:(NSArray *)options;

@end
