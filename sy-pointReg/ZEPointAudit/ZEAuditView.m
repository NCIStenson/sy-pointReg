//
//  ZEAuditView.m
//  NewCentury
//
//  Created by Stenson on 16/2/18.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//
// 导航栏
#define kNavBarWidth SCREEN_WIDTH
#define kNavBarHeight 64.0f
#define kNavBarMarginLeft 0.0f
#define kNavBarMarginTop 0.0f

// 返回按钮位置
#define kCloseBtnWidth  60.0f
#define kCloseBtnHeight 60.0f
#define kCloseBtnMarginLeft 10.0f
#define kCloseBtnMarginTop 12.0f

// 导航栏内右侧按钮
#define kRightButtonWidth 76.0f
#define kRightButtonHeight 40.0f
#define kRightButtonMarginRight -10.0f
#define kRightButtonMarginTop 20.0f + 2.0f
// 导航栏标题
#define kNavTitleLabelWidth SCREEN_WIDTH
#define kNavTitleLabelHeight 44.0f
#define kNavTitleLabelMarginLeft 0.0f
#define kNavTitleLabelMarginTop 20.0f

#define kContentViewMarginTop   64.0f + KDateChooseViewHeight
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - kNavBarHeight - KDateChooseViewHeight - 44.0f)

#define KDateChooseViewMarginTop    64.0f
#define KDateChooseViewMarginLeft   0.0f
#define KDateChooseViewWidth        SCREEN_WIDTH
#define KDateChooseViewHeight       30.0f

#define KAuditButtonMarginTop    (SCREEN_HEIGHT - 44.0f)
#define KAuditButtonMarginLeft   0.0f
#define KAuditButtonWidth        SCREEN_WIDTH
#define KAuditButtonHeight       44.0f

#define kMaskImageTag   1

#import "ZEAuditView.h"
#import "ZEPointRegChooseDateView.h"
#import "ZEPointAuditModel.h"

@interface ZEAuditView ()
{
    JCAlertView * _alertView;
    UIButton * _dateButton;
    UITableView *_contentTableView;
    
    NSMutableArray * maskArr;
}

@property (nonatomic,retain) NSArray * auditListArr;

@end

@implementation ZEAuditView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initNavBar];
        [self initView];
    }
    return self;
}

#pragma mark - Public Method

-(void)reloadAuditViewWithData:(NSArray *)arr
{
    maskArr = [NSMutableArray array];
    for (int i = 0; i < arr.count; i ++) {
        [maskArr addObject:[NSString stringWithFormat:@"%d",NO]];
    }

    self.auditListArr = arr;
    [_contentTableView reloadData];
}

#pragma mark - initView

- (void)initNavBar
{
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(kNavBarMarginLeft, kNavBarMarginTop, kNavBarWidth, kNavBarHeight)];
    [self addSubview:navBar];
    
    [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kNavBarMarginLeft);
        make.top.offset(kNavBarMarginTop);
        make.size.mas_equalTo(CGSizeMake(kNavBarWidth, kNavBarHeight));
    }];
    navBar.backgroundColor = MAIN_NAV_COLOR;
    navBar.clipsToBounds = YES;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"全选" forState:UIControlStateNormal];
    rightBtn.backgroundColor = [UIColor clearColor];
    rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn addTarget:self action:@selector(selectAllAudit) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(kRightButtonMarginRight);
        make.top.offset(kRightButtonMarginTop);
        make.size.mas_equalTo(CGSizeMake(kRightButtonWidth, kRightButtonHeight));
    }];
    
    UILabel *navTitleLabel = [UILabel new];
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.textColor = [UIColor whiteColor];
    navTitleLabel.font = [UIFont systemFontOfSize:24.0f];
    navTitleLabel.text = @"工分审核";
    [navBar addSubview:navTitleLabel];
    [navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.rightMargin.offset(kNavTitleLabelMarginLeft);
        make.top.offset(kNavTitleLabelMarginTop);
        make.size.mas_equalTo(CGSizeMake(kNavTitleLabelWidth, kNavTitleLabelHeight));
    }];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(kCloseBtnMarginLeft, kCloseBtnMarginTop, kCloseBtnWidth, kCloseBtnHeight);
    closeBtn.backgroundColor = [UIColor clearColor];
    closeBtn.contentMode = UIViewContentModeScaleAspectFit;
    [closeBtn setImage:[UIImage imageNamed:@"icon_back" color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:closeBtn];

}

-(void)initView
{
    UIView * dateChooseView = [[UIView alloc]initWithFrame:CGRectMake(KDateChooseViewMarginLeft, KDateChooseViewMarginTop, KDateChooseViewWidth, KDateChooseViewHeight)];
    dateChooseView.backgroundColor = [UIColor clearColor];
    [self addSubview:dateChooseView];
    
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(0, KDateChooseViewHeight - 0.5, SCREEN_WIDTH, 0.5);
    [dateChooseView.layer addSublayer:lineLayer];
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
 
    for (int i = 0; i < 3; i ++) {
        UIButton * dateChooseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        dateChooseButton.frame = CGRectMake(SCREEN_WIDTH / 3 * i, 0, SCREEN_WIDTH / 3, 30.0f);
        [dateChooseView addSubview:dateChooseButton];
        dateChooseButton.titleLabel.font = [UIFont systemFontOfSize:13];
        dateChooseButton.tag = i;
        [dateChooseButton addTarget:self action:@selector(chooseDifferentDate:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            dateChooseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            dateChooseButton.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
            [dateChooseButton setTitle:@"前一天" forState:UIControlStateNormal];
        }else if (i == 1){
            NSDate * date = [NSDate date];
            NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString * dateStr = [formatter stringFromDate:date];
            [dateChooseButton setTitle:dateStr forState:UIControlStateNormal];
            dateChooseButton.titleLabel.font = [UIFont systemFontOfSize:14];
            _dateButton = dateChooseButton;
        }else{
            dateChooseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            dateChooseButton.contentEdgeInsets = UIEdgeInsetsMake(0,0, 0, 10);
            [dateChooseButton setTitle:@"后一天" forState:UIControlStateNormal];
        }
    }
    
    UIButton * auditButton = [UIButton buttonWithType:UIButtonTypeSystem];
    auditButton.frame = CGRectMake(KAuditButtonMarginLeft, KAuditButtonMarginTop, KAuditButtonWidth, KAuditButtonHeight);
    [auditButton setTitle:@"审  核" forState:UIControlStateNormal];
    [self addSubview:auditButton];
    auditButton.backgroundColor = [UIColor clearColor];
    [auditButton addTarget:self action:@selector(confirmAudit) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer * buttonLineLayer = [CALayer layer];
    buttonLineLayer.frame = CGRectMake(0, 0.0f, SCREEN_WIDTH - 10, 0.5f);
    buttonLineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    [auditButton.layer addSublayer:buttonLineLayer];

    
    _contentTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _contentTableView.backgroundColor = [UIColor clearColor];
    _contentTableView.delegate = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.dataSource = self;
    [self addSubview:_contentTableView];
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kContentViewMarginLeft);
        make.top.offset(kContentViewMarginTop);
        make.size.mas_equalTo(CGSizeMake(kContentViewWidth, kContentViewHeight));
    }];

}

#pragma mark - ZEAuditViewDelegate

-(void)chooseDifferentDate:(UIButton *)button
{
    UIButton * dateButton = [button.superview viewWithTag:1];

    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = [formatter dateFromString:dateButton.titleLabel.text];
    NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];//前一天
    NSDate *nextDat = [NSDate dateWithTimeInterval:24*60*60 sinceDate:date];//后一天
    if (button.tag == 0) {
        [dateButton setTitle:[formatter stringFromDate:lastDay] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(refreshDiffDate:withDateStr:)]) {
            [self.delegate refreshDiffDate:self withDateStr:[formatter stringFromDate:lastDay]];
        }

    }else if (button.tag == 1)
    {
        ZEPointRegChooseDateView * chooseDateView = [[ZEPointRegChooseDateView alloc]initWithFrame:CGRectZero];
        chooseDateView.delegate = self;
        _alertView = [[JCAlertView alloc]initWithCustomView:chooseDateView dismissWhenTouchedBackground:YES];
        [_alertView show];
    }else {
        [dateButton setTitle:[formatter stringFromDate:nextDat] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(refreshDiffDate:withDateStr:)]) {
            [self.delegate refreshDiffDate:self withDateStr:[formatter stringFromDate:nextDat]];
        }
    }
    
}

-(void)selectAllAudit
{
    maskArr = [NSMutableArray array];
    for (int i = 0; i < self.auditListArr.count; i ++) {
        [maskArr addObject:[NSString stringWithFormat:@"%d",YES]];
    }
    [_contentTableView reloadData];
}

#pragma mark - ZEPointRegChooseDateViewDelegate

-(void)confirmChooseDate:(NSString *)dateStr
{
    [_alertView dismissWithCompletion:^{
        [_dateButton setTitle:dateStr forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(refreshDiffDate:withDateStr:)]) {
            [self.delegate refreshDiffDate:self withDateStr:dateStr];
        }
    }];
}
-(void)cancelChooseDate
{
    [_alertView dismissWithCompletion:nil];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.auditListArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
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
    
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(10, 49.5f, SCREEN_WIDTH - 10, 0.5f);
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    [cell.contentView.layer addSublayer:lineLayer];
    
    ZEPointAuditModel * pointAM = nil;
    if ([ZEUtil isNotNull:self.auditListArr]) {
        pointAM = [ZEPointAuditModel getDetailWithDic:self.auditListArr[indexPath.row]];
    }
    
    UIView * cellContent = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50.0f)];
    cellContent.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:cellContent];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 5.0f, 46.0f, 40.0f)];
    [imageView setImage:[UIImage imageNamed:@"epm_work_icon.png"]];
    [cellContent addSubview:imageView];
    
    UIImageView * maskImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30.0f, 15.0f, 20.0f, 20.0f)];
    if ([maskArr[indexPath.row] boolValue]) {
        [maskImageView setImage:[UIImage imageNamed:@"audit_yes_icon.png"]];
    }else{
        [maskImageView setImage:[UIImage imageNamed:@"audit_no_icon.png"]];
    }
    maskImageView.tag = kMaskImageTag;
    [cellContent addSubview:maskImageView];
    
    UILabel * realHourLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 80.0f, 0.0f, 50.0f, 50.0f)];
    realHourLabel.font = [UIFont systemFontOfSize:12.0f];
    realHourLabel.textColor = [UIColor lightGrayColor];
    realHourLabel.textAlignment = NSTextAlignmentRight;
    realHourLabel.text = [NSString stringWithFormat:@"+%@",pointAM.REAL_HOUR];
    [cellContent addSubview:realHourLabel];
    
    UILabel * taskNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(65.0f, 5.0f, 200.0f, 20.0f)];
    taskNameLabel.font = [UIFont systemFontOfSize:15.0f];
    taskNameLabel.text = pointAM.TT_TASK;
    [cellContent addSubview:taskNameLabel];
    
    UILabel * staffNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(65.0f, 27.0f, 200.0f, 20.0f)];
    staffNameLabel.text = pointAM.TT_CONTENT;
    staffNameLabel.font = [UIFont systemFontOfSize:13.0f];
    [cellContent addSubview:staffNameLabel];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL maskValue = [maskArr[indexPath.row] boolValue];
    [maskArr removeObjectAtIndex:indexPath.row];
    [maskArr insertObject:[NSString stringWithFormat:@"%d",!maskValue] atIndex:indexPath.row];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView * maskImageView = [cell.contentView viewWithTag:kMaskImageTag];
    if([maskArr[indexPath.row] boolValue]){
        [maskImageView setImage:[UIImage imageNamed:@"audit_yes_icon.png"]];
    }else{
        [maskImageView setImage:[UIImage imageNamed:@"audit_no_icon.png"]];
    }
}

#pragma mark - ZEAuditViewDelegate

-(void)goBack
{
    if([self.delegate respondsToSelector:@selector(goBack)]){
        [self.delegate goBack];
    }
}

-(void)confirmAudit
{
    NSMutableArray * auditArr = [NSMutableArray array];
    for(int i = 0; i < maskArr.count ; i ++){
        
        if ([maskArr[i] boolValue]) {
           ZEPointAuditModel * pointAM = [ZEPointAuditModel getDetailWithDic:self.auditListArr[i]];
            [auditArr addObject:pointAM.SEQKEY];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(goAuditWithArr:)]) {
        [self.delegate goAuditWithArr:auditArr];
    }
}

@end
