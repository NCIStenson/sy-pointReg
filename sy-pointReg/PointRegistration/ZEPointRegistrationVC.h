//
//  ZEPointRegistrationVC.h
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZEHistoryModel.h"

#import "ZEEPM_TEAM_RATION_REGModel.h"

@interface ZEPointRegistrationVC : UIViewController

@property (nonatomic,assign) ENTER_PERSON_POINTREG_TYPE regType;

@property (nonnull,nonatomic,strong) NSDictionary * defaultDic;
@property (nonnull,nonatomic,strong) NSArray * defaultDetailDic;

@end
