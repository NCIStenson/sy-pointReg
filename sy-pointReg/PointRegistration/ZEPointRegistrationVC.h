//
//  ZEPointRegistrationVC.h
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZEHistoryModel.h"

@interface ZEPointRegistrationVC : UIViewController

@property (nonatomic,copy) NSString * codeStr;
/**
 * 扫码进入工分登记页面 发送请求
 * 手动点入不请求
 * 历史进入工分登记页面
 */
@property (nonatomic,retain) ZEHistoryModel * hisModel;     // 从历史界面进入工分登记修改数据

@end
