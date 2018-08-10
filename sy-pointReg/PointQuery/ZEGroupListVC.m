//
//  ZEGroupListVC.m
//  sy-pointReg
//
//  Created by Stenson on 2018/8/9.
//  Copyright © 2018年 Zenith Electronic. All rights reserved.
//

#import "ZEGroupListVC.h"
#import "ZEMemberHistoryListVC.h"
@interface ZEGroupListVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray * _listDataArr;
    UITableView * _contentTableView;
}
@end

@implementation ZEGroupListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"班组工分查看";
    [self initView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sendRequest];
}
-(void)initView{
    _contentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT) style:UITableViewStylePlain];
    
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentTableView];
}

-(void)sendRequest{

    NSDictionary * parametersDic = @{@"start":@"0",
                                     @"limit":@"-1",
                                     @"MASTERTABLE":V_EPM_TEAM_SUITUNIT_ORG,
                                     @"MASTERFIELD":@"",
                                     @"MENUAPP":@"EMARK_APP",
                                     @"WHERESQL":@"SUITUNIT = '#SUITUNIT#'",
                                     @"ORDERSQL":@"displayorder",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[V_EPM_TEAM_SUITUNIT_ORG]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    NSLog(@" = %@",packageDic);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 if ([[ZEUtil getServerData:data withTabelName:V_EPM_TEAM_SUITUNIT_ORG] count] > 0) {
                                     _listDataArr = [ZEUtil getServerData:data withTabelName:V_EPM_TEAM_SUITUNIT_ORG];
                                     [_contentTableView reloadData];
                                 }
                             } fail:^(NSError *errorCode) {
                                 NSLog(@" == == = =%@",errorCode);
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listDataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"CELL";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    while (cell.contentView.subviews.lastObject) {
        [cell.contentView.subviews.lastObject removeFromSuperview];
    }
    
    UIView * lineView = [UIView new];
    lineView.frame = CGRectMake(0, 43.5, SCREEN_WIDTH, .5f);
    lineView.backgroundColor = MAIN_LINE_COLOR;
    [cell.contentView addSubview:lineView];
    
    NSDictionary * dic = _listDataArr[indexPath.row];
    cell.textLabel.text = dic[@"ORGNAME"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

-(UIView * )tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor whiteColor];
//    for (int i = 0 ;i < 1; i ++) {
//        CALayer * lineLayer = [CALayer layer];
//        lineLayer.frame = CGRectMake(0, 44 * i, SCREEN_WIDTH, 0.5f);
//        [backgroundView.layer addSublayer:lineLayer];
//        lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
//
//        UIButton * headerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        headerBtn.frame = CGRectMake(10.0f, 44 * i, SCREEN_WIDTH - 20.0f, 44);
//        headerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        headerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        [backgroundView addSubview:headerBtn];
//        [headerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        headerBtn.titleLabel.numberOfLines = 0;
//        [headerBtn setTitle:@"班组列表" forState:UIControlStateNormal];
//        [headerBtn setTitleColor:kFontColor forState:UIControlStateNormal];
//    }
    
    UIView * contentTitleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    contentTitleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:84/255.0 blue:74/255.0 alpha:0.5];
    [backgroundView addSubview:contentTitleView];
    
    UILabel * dateLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0.0f, SCREEN_WIDTH - 20, 44)];
    dateLable.text = @"班组列表";
    dateLable.font = [UIFont systemFontOfSize:14];
    dateLable.textColor = kFontColor;
    [contentTitleView addSubview:dateLable];
    
    return backgroundView;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dic = _listDataArr[indexPath.row];

    ZEMemberHistoryListVC * listVC = [[ZEMemberHistoryListVC alloc]init];
    listVC.ORGCODE = dic[@"ORGCODE"];
    [self.navigationController pushViewController:listVC animated:YES];
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
