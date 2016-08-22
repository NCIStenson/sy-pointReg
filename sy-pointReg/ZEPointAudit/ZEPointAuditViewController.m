//
//  ZEPointAuditViewController.m
//  NewCentury
//
//  Created by Stenson on 16/2/17.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEPointAuditViewController.h"
#import "ZEUserServer.h"
#import "MBProgressHUD.h"
#import "ZEAuditViewController.h"

#import "ZEHistoryDetailVC.h"

@interface ZEPointAuditViewController ()
{
    ZEPointAuditView * _pointAuditView;
    ZEPointAuditModel * _pointAuditM;
    NSInteger _currentPage;
}
@end

@implementation ZEPointAuditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currentPage = 0;
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
    [self sendRequest];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(auditRefreshView) name:kNotiRefreshAuditView object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiRefreshAuditView object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}
#pragma mark - initView
-(void)initView
{
    _pointAuditView = [[ZEPointAuditView alloc]initWithFrame:self.view.frame];
    _pointAuditView.delegate = self;
    [self.view addSubview:_pointAuditView];
}

#pragma mark - SendRequest

-(void)auditRefreshView
{
    _currentPage = 0;
    [self sendRequest];
}

/******  审核列表   ****/
-(void)sendRequest
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [ZEUserServer getPointAuditWithPage:[NSString stringWithFormat:@"%ld",(long)_currentPage] success:^(id data) {
//        NSArray * dataArr = [data objectForKey:@"data"];
//        if ([ZEUtil isNotNull:dataArr]) {
//            if (_currentPage == 0) {
//                [_pointAuditView reloadFirstView:dataArr];
//            }else{
//                [_pointAuditView reloadView:dataArr];
//            }
//            if (dataArr.count%20 == 0) {
//                _currentPage += 1;
//            }
//        }else{
//            [_pointAuditView loadNoMoreData];
//            [_pointAuditView headerEndRefreshing];
//        }
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    } fail:^(NSError *errorCode) {
//        [_pointAuditView headerEndRefreshing];
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    }];
}


#pragma mark - ZEPointAuditDelegate

-(void)loadNewData:(ZEPointAuditView *)hisView
{
    _currentPage = 0;
    [self sendRequest];
}

-(void)loadMoreData:(ZEPointAuditView *)hisView
{
    [self sendRequest];
}
-(void)goAuditVC
{
    ZEAuditViewController * auditVC = [[ZEAuditViewController alloc]init];
    [self presentViewController:auditVC animated:YES completion:nil];
}

-(void)confirmWeatherAudit:(ZEPointAuditView *)hisView withModel:(ZEPointAuditModel *)pointAM
{
    _pointAuditM = pointAM;
    ZEHistoryDetailVC * detailVC = [[ZEHistoryDetailVC alloc]init];
    detailVC.model = pointAM;
    detailVC.enterType = ENTER_FIXED_POINTREG_TYPE_AUDIT;
    [self presentViewController:detailVC animated:YES completion:nil];
    
//    if (IS_IOS8) {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定审核该任务？" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
//                                                           style:UIAlertActionStyleDefault
//                                                         handler:^(UIAlertAction * _Nonnull action) {
//                                                             [self confirmAudit:pointAM.SEQKEY];
//                                                         }];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
//        [alertController addAction:okAction];
//        [alertController addAction:cancelAction];
//        [self presentViewController:alertController animated:YES completion:nil];
//        
//    }else{
//        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您确定审核该任务？" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
//        alertView.delegate = self;
//        [alertView show];
//    }
}

-(void)deleteNoAuditHistory:(NSString *)seqkey
{
    __block ZEPointAuditViewController * safeSelf = self;
//    [ZEUserServer deleteTeamTask:seqkey success:^(id data) {
//        if ([ZEUtil isNotNull:data]) {
//            if ([[data objectForKey:@"data"] integerValue] == 1) {
//                _currentPage = 0 ;
//                [safeSelf sendRequest];
//            }else{
//                [ZEUtil showAlertView:@"删除失败，请重试" viewController:self];
//            }
//        }
//    } fail:^(NSError *errorCode) {
//        
//    }];
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
