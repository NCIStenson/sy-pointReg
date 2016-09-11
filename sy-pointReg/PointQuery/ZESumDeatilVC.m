//
//  ZESumDeatilVC.m
//  sy-pointReg
//
//  Created by Stenson on 16/9/11.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#define kContentViewMarginTop   64.0f
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - 64.0f)

#import "ZESumDeatilVC.h"
#import "ZEEPM_TEAM_RATION_REGModel.h"
@interface ZESumDeatilVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _contentTableView;
}
@property (nonatomic,strong) NSArray * listArr;

@end


@implementation ZESumDeatilVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"汇总详情";
    
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self sendRequest];
}
-(void)sendRequest
{
    NSString * whereSQL = [NSString stringWithFormat:@"psnnum='%@' and suitunit='%@' and PERIODCODE='%@' and status in ('2','3','4','5','6','7')",[ZESettingLocalData getUSERCODE],@"SYBDYWS",_PERIODCODE];
    
    NSDictionary * parametersDic = @{@"start":@"0",
                                     @"limit":@"2000",
                                     @"MASTERTABLE":EPM_TEAM_RATION_REG_DETAIL,
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"MENUAPP":@"EMARK_APP",
                                     @"WHERESQL":whereSQL,
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION_REG_DETAIL]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    __block ZESumDeatilVC * safeSelf = self;
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 if ([[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATION_REG_DETAIL] count] > 0) {
                                     safeSelf.listArr = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RATION_REG_DETAIL];
                                     [_contentTableView reloadData];
                                 }
                             } fail:^(NSError *errorCode) {
                                 
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
    
    UILabel * dateLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0.0f, 90.0f, 40.0f)];
    dateLable.text = @"日期";
    dateLable.font = [UIFont systemFontOfSize:14];
    dateLable.textColor = kFontColor;
    [contentTitleView addSubview:dateLable];
    
    UILabel * taskNameLable = [[UILabel alloc]initWithFrame:CGRectMake(100, 0.0f, SCREEN_WIDTH - 220, 40.0f)];
    taskNameLable.text = @"工作项";
    taskNameLable.textAlignment = NSTextAlignmentCenter;
    taskNameLable.font = [UIFont systemFontOfSize:14];
    taskNameLable.textColor = kFontColor;
    [contentTitleView addSubview:taskNameLable];
    
    UILabel * workTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 0.0f, 60.0f, 40.0f)];
    workTimeLable.text = @"工时";
    workTimeLable.textAlignment = NSTextAlignmentCenter;
    workTimeLable.font = [UIFont systemFontOfSize:14];
    workTimeLable.textColor = kFontColor;
    [contentTitleView addSubview:workTimeLable];
    
    UILabel * workPointLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0.0f, 60.0f, 40.0f)];
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
    
    UILabel * dateLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0.0f, 90.0f, 40.0f)];
    dateLable.text = model.ENDDATE;
    dateLable.font = [UIFont systemFontOfSize:14];
    dateLable.textColor = kFontColor;
    [cell.contentView addSubview:dateLable];
    
    
    UILabel * taskNameLable = [[UILabel alloc]initWithFrame:CGRectMake(100, 0.0f, SCREEN_WIDTH - 220, 40.0f)];
    taskNameLable.text = model.RATIONNAME;
    taskNameLable.textAlignment = NSTextAlignmentCenter;
    taskNameLable.font = [UIFont systemFontOfSize:14];
    taskNameLable.textColor = kFontColor;
    [cell.contentView addSubview:taskNameLable];
    
    UILabel * workTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 0.0f, 60.0f, 40.0f)];
    workTimeLable.text = [NSString stringWithFormat:@"%@",model.QUOTIETY4];
    workTimeLable.textAlignment = NSTextAlignmentCenter;
    workTimeLable.font = [UIFont systemFontOfSize:14];
    workTimeLable.textColor = kFontColor;
    [cell.contentView addSubview:workTimeLable];
    
    UILabel * workPointLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0.0f, 60.0f, 40.0f)];
    workPointLable.text = [NSString stringWithFormat:@"%@",model.SUMPOINTS];
    workPointLable.textAlignment = NSTextAlignmentCenter;
    workPointLable.font = [UIFont systemFontOfSize:14];
    workPointLable.textColor = kFontColor;
    [cell.contentView addSubview:workPointLable];
    
    for (int i = 0 ;i < 3; i ++) {
        CALayer * lineLayer = [CALayer layer];
        lineLayer.frame = CGRectMake(100, 0, 0.5f, 40.0f);
        [cell.contentView.layer addSublayer:lineLayer];
        lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
        
        switch (i) {
            case 1:
                lineLayer.frame = CGRectMake(SCREEN_WIDTH - 120, 0, 0.5f, 40.0f);
                break;
            case 2:
                lineLayer.frame = CGRectMake(SCREEN_WIDTH - 60, 0, 0.5f, 40.0f);
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}


@end
