//
//  ZEHistoryDetailVC.m
//  NewCentury
//
//  Created by Stenson on 16/2/17.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEHistoryDetailVC.h"
#import "ZEHistoryDetailView.h"
#import "MBProgressHUD.h"
#import "ZEUserServer.h"
@interface ZEHistoryDetailVC ()<ZEHistoryDetailViewDelegate>

@end

@implementation ZEHistoryDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
    // Do any additional setup after loading the view.
}
-(void)initView
{
    ZEHistoryDetailView * detailView = [[ZEHistoryDetailView alloc]initWithFrame:self.view.frame withModel:_model withEnterType:_enterType];
    detailView.delegate = self;
    [self.view addSubview:detailView];
}

#pragma  mark - ZEHistoryDetailViewDelegate

-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiRefreshAuditView object:nil];
    }];
}

-(void)confirmAudit:(NSString *)auditKey
{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [ZEUserServer auditingTeamTask:@[auditKey]
//                           success:^(id data) {
//                               if ([ZEUtil isNotNull:data]) {
//                                   if ([[data objectForKey:@"data"] integerValue] == 1) {
//                                       [self goBack];
//                                       [[NSNotificationCenter defaultCenter] postNotificationName:kNotiRefreshAuditView object:nil];
//                                   }
//                               }
//                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                           } fail:^(NSError *errorCode) {
//                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                           }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
