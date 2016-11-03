//
//  ZEPointSearchVC.m
//  sy-pointReg
//
//  Created by Stenson on 16/9/11.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#define kContentViewMarginTop   64.0f
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - 64.0f)

#import "ZEEPM_TEAM_RATION_REGModel.h"

#import "ZEPointSearchVC.h"

#import "ZESumDeatilVC.h"
@interface ZEPointSearchVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _contentTableView;
}
@property (nonatomic,strong) NSArray * listArr;

@end
@implementation ZEPointSearchVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"汇总查询";
    
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self sendRequest];
}
-(void)sendRequest
{
    NSDictionary * parametersDic = @{@"start":@"0",
                                     @"limit":@"2000",
                                     @"MASTERTABLE":EPM_TEAM_RESULT,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"PERIODCODE DESC",
                                     @"WHERESQL":[NSString stringWithFormat:@"psnnum='#PSNNUM#' and suitunit='#SUITUNIT#' AND substr(PERIODCODE,0,4)='%@'",[[ZEUtil getCurrentMonth] substringToIndex:4]],
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RESULT]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __block ZEPointSearchVC * safeSelf = self;
    [ZEUserServer getDataWithJsonDic:packageDic
                       showAlertView:YES
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 if ([[ZEUtil getServerData:data withTabelName:EPM_TEAM_RESULT] count] > 0) {
                                     safeSelf.listArr = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RESULT];
                                     [_contentTableView reloadData];
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

-(void)initView
{
    _contentTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentTableView];
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kContentViewMarginLeft);
        make.top.offset(kContentViewMarginTop);
        make.size.mas_equalTo(CGSizeMake(kContentViewWidth, kContentViewHeight));
    }];
}

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView * contentTitleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40.0f)];
    contentTitleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:84/255.0 blue:74/255.0 alpha:0.5];
    
    UILabel * dateLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0.0f, (SCREEN_WIDTH-20)/2, 40.0f)];
    dateLable.text = @"日期";
    dateLable.font = [UIFont systemFontOfSize:14];
    dateLable.textColor = kFontColor;
    [contentTitleView addSubview:dateLable];
    
    UILabel * workPointLable = [[UILabel alloc]initWithFrame:CGRectMake( 10 + (SCREEN_WIDTH-20)/2, 0.0f, (SCREEN_WIDTH-20)/2, 40.0f)];
    workPointLable.text = @"工分";
    workPointLable.textAlignment = NSTextAlignmentCenter;
    workPointLable.font = [UIFont systemFontOfSize:14];
    workPointLable.textColor = kFontColor;
    [contentTitleView addSubview:workPointLable];
    
    return contentTitleView;
}

-(NSMutableAttributedString *)getAttrText:(NSString *)str
                              withTimeStr:(NSString *)timeStr
                             withPointStr:(NSString *)pointStr
{
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithString:str];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:kFontColor
     
                    range:NSMakeRange(0, str.length)];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:[UIColor blueColor]
     
                    range:NSMakeRange(0, str.length - 2)];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:kFontColor
     
                    range:NSMakeRange(0, str.length - 2 - timeStr.length)];
    
    
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:[UIColor blueColor]
     
                    range:NSMakeRange(0, str.length - 7 - timeStr.length)];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:kFontColor
     
                    range:NSMakeRange(0, str.length - 7 - timeStr.length - pointStr.length)];
    
    return attrStr;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArr.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ZEEPM_TEAM_RATION_REGModel * model = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:self.listArr[indexPath.row]];
    
    UILabel * dateLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0.0f, (SCREEN_WIDTH-20)/2, 40.0f)];
    dateLable.text = model.PERIODCODE;
    dateLable.font = [UIFont systemFontOfSize:14];
    dateLable.textColor = kFontColor;
    [cell.contentView addSubview:dateLable];
    
    UILabel * workPointLable = [[UILabel alloc]initWithFrame:CGRectMake( 10 + (SCREEN_WIDTH-20)/2, 0.0f, (SCREEN_WIDTH-20)/2, 40.0f)];
    workPointLable.text = [NSString stringWithFormat:@"%@",model.FINALSCORE];
    workPointLable.textAlignment = NSTextAlignmentCenter;
    workPointLable.font = [UIFont systemFontOfSize:14];
    workPointLable.textColor = kFontColor;
    [cell.contentView addSubview:workPointLable];
    
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(SCREEN_WIDTH/2, 0, 0.5f, 40.0f);
    [cell.contentView.layer addSublayer:lineLayer];
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZEEPM_TEAM_RATION_REGModel * model = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:self.listArr[indexPath.row]];

    if (![ZEUtil strIsEmpty:model.PERIODCODE]) {
        ZESumDeatilVC * sumDetailVC = [[ZESumDeatilVC alloc]init];
        sumDetailVC.PERIODCODE = model.PERIODCODE;
        [self.navigationController pushViewController:sumDetailVC animated:YES];
    }
    
}


@end
