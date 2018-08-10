//
//  ZEMemberHistoryListView.m
//  sy-pointReg
//
//  Created by Stenson on 17/5/23.
//  Copyright © 2017年 Zenith Electronic. All rights reserved.
//
#define kContentViewMarginTop   0.0f
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - NAV_HEIGHT)

#define kRowHeight 45.0f

#import "ZEMemberHistoryListView.h"

#import "ZEEPM_TEAM_RATION_REGModel.h"

@interface ZEMemberHistoryListView ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _contentTableView;
    
    NSString * personalPoint;  //  个人总工分
    NSString * personalTime;  //  个人总工时
    
}

@property (nonatomic,strong) NSArray * listArr;

@end

@implementation ZEMemberHistoryListView

-(id)initWithFrame:(CGRect)frame withType:(ENTER_MEMBERLIST)type;
{
    self = [super initWithFrame:frame];
    if (self) {
        _enterType = type;
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

-(void)reloadViewWithArr:(NSArray *)arr
{
}
-(void)reloadContentData:(NSArray *)arr
{
    self.listArr = [NSMutableArray arrayWithArray:arr];
    [_contentTableView reloadData];
}

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kRowHeight * 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView * backgroundView = [UIView new];
    for (int i = 0 ;i < 4; i ++) {
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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                float avaPoint = 0;
                float totalSumPoints = 0.0f;
                NSInteger haveScoreCount = 0;
                for (int i = 0; i < self.listArr.count; i ++ ) {
                    ZEEPM_TEAM_RATION_REGModel * model = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:self.listArr [i]];
                    float a = [[ZEUtil decimalwithFormat:@"0.00" floatV:[model.SUMPOINTS floatValue]] floatValue];
                    if (a != 0) {
                        haveScoreCount += 1;
                    }
                    totalSumPoints += a;
                    totalSumPoints = [[ZEUtil decimalwithFormat:@"0.00" floatV:totalSumPoints] floatValue];
                }
                if (haveScoreCount > 0) {
                    avaPoint = totalSumPoints / haveScoreCount;
                }else{
                    avaPoint = totalSumPoints / self.listArr.count;
                }
                
                NSMutableAttributedString * str =[self getTeamAverageAttrText:[NSString stringWithFormat:@"班组内平均分：%@分",[ZEUtil roundUp:avaPoint afterPoint:2]] withPoint:[NSString stringWithFormat:@"%.2f",avaPoint]]  ;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [headerBtn setAttributedTitle:str forState:UIControlStateNormal];
                });
            });
            
        }else if( i == 2){
            if (self.listArr.count > 0) {
                ZEEPM_TEAM_RATION_REGModel * maxModel = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:[self.listArr firstObject]];
                NSString * maxUsername = maxModel.PSNNAME;
                NSString * maxPoint = [ZEUtil decimalwithFormat:@"0.00" floatV:[maxModel.SUMPOINTS floatValue]];
                
                ZEEPM_TEAM_RATION_REGModel * minModel = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:[self.listArr lastObject]];
                
                for (int i = 0; i < self.listArr.count; i ++ ) {
                    ZEEPM_TEAM_RATION_REGModel * model = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:self.listArr [i]];
                    float a = [[ZEUtil decimalwithFormat:@"0.00" floatV:[model.SUMPOINTS floatValue]] floatValue];
                    if (a != 0) {
                        minModel = model;
                    }
                }
                NSString * minUsername = minModel.PSNNAME;
                NSString * minPoint =  [ZEUtil decimalwithFormat:@"0.00" floatV:[minModel.SUMPOINTS floatValue]];
                
                NSString * str = [NSString stringWithFormat:@"最高分：%@ %@分 最低分：%@ %@分",maxUsername,maxPoint,minUsername,minPoint];
                
                [headerBtn setAttributedTitle:[self getAttrText:str withMaxUsername:maxUsername withMaxPoint:maxPoint withMinUsername:minUsername withMinPoint:minPoint] forState:UIControlStateNormal];
                
                [headerBtn setTitleColor:kFontColor forState:UIControlStateNormal];
            }
        }else if( i == 3){
            [headerBtn setTitle:@"当月班员工分实时统计" forState:UIControlStateNormal];
            [headerBtn setTitleColor:kFontColor forState:UIControlStateNormal];
        }
    }
    
    
    UIView * contentTitleView = [[UIView alloc]initWithFrame:CGRectMake(0, kRowHeight * 4, SCREEN_WIDTH, kRowHeight)];
    contentTitleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:84/255.0 blue:74/255.0 alpha:0.5];
    [backgroundView addSubview:contentTitleView];
    
    UILabel * dateLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0.0f, SCREEN_WIDTH - 180, kRowHeight)];
    dateLable.text = @"姓名";
    dateLable.font = [UIFont systemFontOfSize:14];
    dateLable.textColor = kFontColor;
    [contentTitleView addSubview:dateLable];
    
    UILabel * workTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 160, 0.0f, 80.0f, kRowHeight)];
    workTimeLable.text = @"工时";
    workTimeLable.textAlignment = NSTextAlignmentCenter;
    workTimeLable.font = [UIFont systemFontOfSize:14];
    workTimeLable.textColor = kFontColor;
    [contentTitleView addSubview:workTimeLable];
    
    UILabel * workPointLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 0.0f, 80.0f, kRowHeight)];
    workPointLable.text = @"工分";
    workPointLable.textAlignment = NSTextAlignmentCenter;
    workPointLable.font = [UIFont systemFontOfSize:14];
    workPointLable.textColor = kFontColor;
    [contentTitleView addSubview:workPointLable];

    return backgroundView;
}

-(UIView *)groupHeaderView
{
    UIView * groupHeaderView = [UIView new];
    
    for(int i = 0 ; i < 3; i ++){
        UIButton * headerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        headerBtn.frame = CGRectMake(SCREEN_WIDTH / 3 * i , 0, SCREEN_WIDTH / 3, kRowHeight * 2);
        [headerBtn setTitle:@"2017年8月" forState:UIControlStateNormal];
//        headerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        headerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [groupHeaderView addSubview:headerBtn];
        [headerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        headerBtn.titleLabel.numberOfLines = 0;
    }
    
    return groupHeaderView;
    
}

-(NSMutableAttributedString *)getAttrText:(NSString *)str
                          withMaxUsername:(NSString *)maxUsername
                             withMaxPoint:(NSString *)maxPoint
                          withMinUsername:(NSString *)minUsername
                             withMinPoint:(NSString *)minPoint
{
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithString:str];
    
    float length = str.length;
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:kFontColor
     
                    range:NSMakeRange(0, str.length)];
    
    length = length - 1;
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:[UIColor blueColor]
     
                    range:NSMakeRange(0, length)];
    length = length - minPoint.length;
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:kFontColor
     
                    range:NSMakeRange(0, length)];
    
    length = length - minUsername.length - 7;
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:[UIColor blueColor]
     
                    range:NSMakeRange(0, length)];
    
    length = length - maxPoint.length;
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:kFontColor
     
                    range:NSMakeRange(0, length)];
    
    return attrStr;
    
}

-(NSMutableAttributedString *)getTeamAverageAttrText:(NSString *)str
                    withPoint:(NSString *)point
{
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithString:str];
    
    float length = str.length;
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:kFontColor
     
                    range:NSMakeRange(0, str.length)];
    
    length = length - 1;
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:[UIColor blueColor]
     
                    range:NSMakeRange(0, length)];
    length = length - point.length;
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:kFontColor
     
                    range:NSMakeRange(0, length)];
    
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
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
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
    
    UILabel * dateLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0.0f, SCREEN_WIDTH - 180, kRowHeight)];
    dateLable.text = model.PSNNAME;
    dateLable.font = [UIFont systemFontOfSize:14];
    dateLable.textColor = kFontColor;
    [cell.contentView addSubview:dateLable];
    
    UILabel * workTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 160, 0.0f, 80.0f, kRowHeight)];
    workTimeLable.text = [NSString stringWithFormat:@"%@",model.QUOTIETY4];
    workTimeLable.textAlignment = NSTextAlignmentCenter;
    workTimeLable.font = [UIFont systemFontOfSize:14];
    workTimeLable.textColor = kFontColor;
    [cell.contentView addSubview:workTimeLable];
    
    UILabel * workPointLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 0.0f, 80.0f, kRowHeight)];
    workPointLable.text = [NSString stringWithFormat:@"%@", model.SUMPOINTS];
    NSArray * arr = [workPointLable.text componentsSeparatedByString:@"."];
    if (arr.count > 1) {
        NSString * subStr = arr[1];
        if (subStr.length > 2) {
            workPointLable.text = [NSString stringWithFormat:@"%.2f", [model.SUMPOINTS floatValue]];
        }
    }
    workPointLable.textAlignment = NSTextAlignmentCenter;
    workPointLable.font = [UIFont systemFontOfSize:14];
    workPointLable.textColor = kFontColor;
    [cell.contentView addSubview:workPointLable];
    
    for (int i = 0 ;i < 2; i ++) {
        CALayer * lineLayer = [CALayer layer];
        lineLayer.frame = CGRectMake(SCREEN_WIDTH-160, 0, 0.5f, kRowHeight);
        [cell.contentView.layer addSublayer:lineLayer];
        lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
        
        switch (i) {
            case 1:
                lineLayer.frame = CGRectMake(SCREEN_WIDTH - 80, 0, 0.5f, kRowHeight);
                break;
            case 2:

                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

-(void)goPointSearch
{
    if ([self.delegate respondsToSelector:@selector(goQueryMemberVC)]) {
        [self.delegate goQueryMemberVC];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZEEPM_TEAM_RATION_REGModel * model = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:self.listArr[indexPath.row]];
    self.block(model);
}

@end
