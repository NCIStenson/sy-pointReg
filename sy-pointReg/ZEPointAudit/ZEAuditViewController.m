//
//  ZEAuditViewController.m
//  NewCentury
//
//  Created by Stenson on 16/2/18.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEAuditViewController.h"
#import "MBProgressHUD.h"
#import "ZEUserServer.h"
@interface ZEAuditViewController ()
{
    ZEAuditView * _auditView;
    NSString * _currentDateStr;
}
@end

@implementation ZEAuditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateStr = [formatter stringFromDate:date];
    _currentDateStr = dateStr;
    
    [self sendRequestWithDateStr:dateStr];
}

#pragma mark - Request

-(void)sendRequestWithDateStr:(NSString *)dateStr
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [ZEUserServer queryTeamTaskByDate:dateStr success:^(id data) {
//        if([ZEUtil isNotNull:[data objectForKey:@"data"]]){
//            [_auditView reloadAuditViewWithData:[data objectForKey:@"data"]];
//        }
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    } fail:^(NSError *errorCode) {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    }];
}
-(void)confirmAuditWithArr:(NSArray *)auditArr
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [ZEUserServer auditingTeamTask:auditArr
//                           success:^(id data) {
//                               if ([ZEUtil isNotNull:data]) {
//                                   if ([[data objectForKey:@"data"] boolValue]) {
//                                       [self sendRequestWithDateStr:_currentDateStr];
//                                       [[NSNotificationCenter defaultCenter] postNotificationName:kNotiRefreshAuditView object:nil];
//                                   }
//                               }
//                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                           } fail:^(NSError *errorCode) {
//                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                           }];
}

#pragma mark - initView

-(void)initView
{
    _auditView = [[ZEAuditView alloc]initWithFrame:self.view.frame];
    _auditView.delegate = self;
    [self.view addSubview:_auditView];
}

#pragma mark - ZEAuditViewDelegate
-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)refreshDiffDate:(ZEAuditView *)auditView withDateStr:(NSString *)dateStr
{
    _currentDateStr = dateStr;
    [self sendRequestWithDateStr:dateStr];
}
-(void)goAuditWithArr:(NSArray * )auditArr
{
    [self confirmAuditWithArr:auditArr];
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
