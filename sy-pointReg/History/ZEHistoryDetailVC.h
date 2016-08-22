//
//  ZEHistoryDetailVC.h
//  NewCentury
//
//  Created by Stenson on 16/2/17.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZEHistoryModel.h"

@interface ZEHistoryDetailVC : UIViewController

@property (nonatomic,retain) id model;
@property (nonatomic,assign) ENTER_FIXED_POINTREG_TYPE enterType;

@end
