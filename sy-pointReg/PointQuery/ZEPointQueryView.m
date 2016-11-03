//
//  ZEPointQueryView.m
//  sy-pointReg
//
//  Created by Stenson on 16/9/11.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#define kContentViewMarginTop   0.0f
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - 64.0f)

#define kRowHeight 45.0f

#import "ZEPointQueryView.h"

#import "ZEEPM_TEAM_RATION_REGModel.h"

@interface ZEPointQueryView ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _contentTableView;
    
    NSString * personalPoint;  //  个人总工分
    NSString * personalTime;  //  个人总工时
    
}

@property (nonatomic,strong) NSArray * listArr;

@end

@implementation ZEPointQueryView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        personalPoint = @"0";
        personalTime = @"0";
    }
    return self;
}

-(void)initView
{
    _contentTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.backgroundColor = [UIColor clearColor];
    [self addSubview:_contentTableView];
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kContentViewMarginLeft);
        make.top.offset(kContentViewMarginTop);
        make.size.mas_equalTo(CGSizeMake(kContentViewWidth, kContentViewHeight));
    }];
}

#pragma mark - Public Method

-(void)reloadHeader:(NSString *)pointStr withTimeStr:(NSString *)timeStr
{
    personalTime = timeStr;
    personalPoint = pointStr;
    [_contentTableView reloadData];
    
}
-(void)reloadContentData:(NSArray *)arr
{
    self.listArr = arr;
    [_contentTableView reloadData];
}

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kRowHeight * 4;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView * backgroundView = [UIView new];
    
    for (int i = 0 ;i < 3; i ++) {
        CALayer * lineLayer = [CALayer layer];
        lineLayer.frame = CGRectMake(0, kRowHeight + kRowHeight * i, SCREEN_WIDTH, 0.5f);
        [backgroundView.layer addSublayer:lineLayer];
        lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
        
        UIButton * headerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        headerBtn.frame = CGRectMake(10.0f, kRowHeight * i, SCREEN_WIDTH - 20.0f, kRowHeight);
        [headerBtn setTitle:@"员工工时汇总查询" forState:UIControlStateNormal];
        headerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        headerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [backgroundView addSubview:headerBtn];
        [headerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        headerBtn.titleLabel.numberOfLines = 0;

        if (i == 0) {
            headerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            [headerBtn addTarget:self action:@selector(goPointSearch) forControlEvents:UIControlEventTouchUpInside];
        }else if( i == 1){
            [headerBtn setAttributedTitle:[self getAttrText:[NSString stringWithFormat:@"你好，%@，本月工分：%@分，工时：%@小时",[ZESettingLocalData getNICKNAME],personalPoint,personalTime]  withTimeStr:personalTime withPointStr:personalPoint] forState:UIControlStateNormal];
        }else if( i == 2){
            [headerBtn setTitle:@"本月明细" forState:UIControlStateNormal];
            [headerBtn setTitleColor:kFontColor forState:UIControlStateNormal];
        }
    }
    
    
    UIView * contentTitleView = [[UIView alloc]initWithFrame:CGRectMake(0, kRowHeight * 3, SCREEN_WIDTH, kRowHeight)];
    contentTitleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:84/255.0 blue:74/255.0 alpha:0.5];
    [backgroundView addSubview:contentTitleView];
    
    UILabel * dateLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0.0f, 50.0f, kRowHeight)];
    dateLable.text = @"日期";
    dateLable.font = [UIFont systemFontOfSize:14];
    dateLable.textColor = kFontColor;
    [contentTitleView addSubview:dateLable];
    
    UILabel * taskNameLable = [[UILabel alloc]initWithFrame:CGRectMake(60, 0.0f, SCREEN_WIDTH - 180, kRowHeight)];
    taskNameLable.text = @"工作项";
    taskNameLable.textAlignment = NSTextAlignmentCenter;
    taskNameLable.font = [UIFont systemFontOfSize:14];
    taskNameLable.textColor = kFontColor;
    [contentTitleView addSubview:taskNameLable];

    UILabel * workTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 0.0f, 60.0f, kRowHeight)];
    workTimeLable.text = @"工时";
    workTimeLable.textAlignment = NSTextAlignmentCenter;
    workTimeLable.font = [UIFont systemFontOfSize:14];
    workTimeLable.textColor = kFontColor;
    [contentTitleView addSubview:workTimeLable];

    UILabel * workPointLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0.0f, 60.0f, kRowHeight)];
    workPointLable.text = @"工分";
    workPointLable.textAlignment = NSTextAlignmentCenter;
    workPointLable.font = [UIFont systemFontOfSize:14];
    workPointLable.textColor = kFontColor;
    [contentTitleView addSubview:workPointLable];
    
    return backgroundView;
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
    return kRowHeight;
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
    
    UILabel * dateLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0.0f, 50.0f, kRowHeight)];
    dateLable.text = [model.ENDDATE substringFromIndex:5];
    dateLable.font = [UIFont systemFontOfSize:14];
    dateLable.textColor = kFontColor;
    [cell.contentView addSubview:dateLable];
    
    
    UILabel * taskNameLable = [[UILabel alloc]initWithFrame:CGRectMake(60, 0.0f, SCREEN_WIDTH - 180, kRowHeight)];
    taskNameLable.text = model.RATIONNAME;
    taskNameLable.numberOfLines = 0;
    taskNameLable.textAlignment = NSTextAlignmentCenter;
    taskNameLable.font = [UIFont systemFontOfSize:14];
    if (!IPHONE6_MORE) {
        taskNameLable.font = [UIFont systemFontOfSize:13];
    }
    taskNameLable.textColor = kFontColor;
    [cell.contentView addSubview:taskNameLable];
    
    UILabel * workTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 0.0f, 60.0f, kRowHeight)];
    workTimeLable.text = [NSString stringWithFormat:@"%@",model.QUOTIETY4];
    workTimeLable.textAlignment = NSTextAlignmentCenter;
    workTimeLable.font = [UIFont systemFontOfSize:14];
    workTimeLable.textColor = kFontColor;
    [cell.contentView addSubview:workTimeLable];
    
    UILabel * workPointLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0.0f, 60.0f, kRowHeight)];
    workPointLable.text = [NSString stringWithFormat:@"%@",model.SUMPOINTS];
    workPointLable.textAlignment = NSTextAlignmentCenter;
    workPointLable.font = [UIFont systemFontOfSize:14];
    workPointLable.textColor = kFontColor;
    [cell.contentView addSubview:workPointLable];
    
    for (int i = 0 ;i < 3; i ++) {
        CALayer * lineLayer = [CALayer layer];
        lineLayer.frame = CGRectMake(60, 0, 0.5f, kRowHeight);
        [cell.contentView.layer addSublayer:lineLayer];
        lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
        
        switch (i) {
            case 1:
                lineLayer.frame = CGRectMake(SCREEN_WIDTH - 120, 0, 0.5f, kRowHeight);
                break;
            case 2:
                lineLayer.frame = CGRectMake(SCREEN_WIDTH - 60, 0, 0.5f, kRowHeight);
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

-(void)goPointSearch
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTISEARCHPOINT object:nil];
}


@end
