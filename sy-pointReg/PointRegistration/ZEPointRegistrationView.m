//
//  ZEPointRegistrationView.m
//  NewCentury
//
//  Created by Stenson on 16/1/21.
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

#define kContentViewMarginTop   64.0f
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - kNavBarHeight - 44.0f)


#import "ZEPointRegistrationView.h"
#import "Masonry.h"
#import "JCAlertView.h"
#import "ZEPointRegOptionView.h"
#import "ZEPointRegChooseDateView.h"
#import "ZEPointChooseTaskView.h"
#import "ZEPointRegModel.h"
#import "ZEPointRegCache.h"
#import "ZEPointRegChooseCountView.h"
#import "MBProgressHUD.h"

@interface ZEPointRegistrationView ()<UITableViewDataSource,UITableViewDelegate,ZEPointRegOptionViewDelegate,ZEPointRegChooseDateViewDelegate,ZEPointChooseTaskViewDelegate,UITextFieldDelegate,ZEPointRegChooseCountViewDelegate>
{
    JCAlertView * _alertView;
    NSInteger _currentSelectRow;
    UITableView * _contentTableView;
    BOOL _showJobRules; // 分摊类型为 按系数分配时  需用户选择角色
    BOOL _showJobCount; // 按次数分配时 输入次数
    ENTER_POINTREG_TYPE _enterType;
    UIView *navBar;
    
    float _allScore; // 工作得分
}

@end

@implementation ZEPointRegistrationView

-(id)initWithFrame:(CGRect)rect withEnterType:(ENTER_POINTREG_TYPE)enterType;
{
    self = [super initWithFrame:rect];
    if (self) {
        _enterType = enterType;
        _showJobRules = YES;
        [self initNavBar];
        [self initView];
    }
    return self;
}

- (void)initNavBar
{
    navBar = [[UIView alloc] initWithFrame:CGRectMake(kNavBarMarginLeft, kNavBarMarginTop, kNavBarWidth, kNavBarHeight)];
    [self addSubview:navBar];

    [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kNavBarMarginLeft);
        make.top.offset(kNavBarMarginTop);
        make.size.mas_equalTo(CGSizeMake(kNavBarWidth, kNavBarHeight));
    }];
    navBar.backgroundColor = MAIN_NAV_COLOR;
    navBar.clipsToBounds = YES;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"提交" forState:UIControlStateNormal];
    rightBtn.backgroundColor = [UIColor clearColor];
    [rightBtn setImage:[UIImage imageNamed:@"icon_tick.png" color:[UIColor whiteColor]] forState:UIControlStateNormal];
    rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn addTarget:self action:@selector(goSubmit) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0,0)];
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0,0)];
    [navBar addSubview:rightBtn];
    if (_enterType == ENTER_POINTREG_TYPE_HISTORY) {
        [rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -65, 0,0)];
        [rightBtn setTitle:@"重新提交" forState:UIControlStateNormal];
    }
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
    navTitleLabel.text = @"工分登记";
    [navBar addSubview:navTitleLabel];
    [navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.rightMargin.offset(kNavTitleLabelMarginLeft);
        make.top.offset(kNavTitleLabelMarginTop);
        make.size.mas_equalTo(CGSizeMake(kNavTitleLabelWidth, kNavTitleLabelHeight));
    }];
    
//    if (_enterType != ENTER_POINTREG_TYPE_DEFAULT) {
        [self showLeftBackButton];
//    }
    
}

-(void)initView
{
    _contentTableView = [UITableView new];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.backgroundColor = [UIColor clearColor];
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_contentTableView];
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kContentViewMarginLeft);
        make.top.offset(kContentViewMarginTop);
        make.size.mas_equalTo(CGSizeMake(kContentViewWidth, kContentViewHeight));
    }];
}

-(void)showLeftBackButton
{
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(kCloseBtnMarginLeft, kCloseBtnMarginTop, kCloseBtnWidth, kCloseBtnHeight);
    closeBtn.backgroundColor = [UIColor clearColor];
    closeBtn.contentMode = UIViewContentModeScaleAspectFit;
    [closeBtn setImage:[UIImage imageNamed:@"icon_back" color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [navBar addSubview:closeBtn];
    
}


#pragma mark - Public

/**
 *  显示隐藏加载菊花
 */
-(void)showProgress
{
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    [self bringSubviewToFront:navBar];
}
-(void)hiddenProgress
{
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
}
/**
 *  刷新表
 */
-(void)reloadContentView:(ENTER_POINTREG_TYPE)entertype
{
    _enterType = entertype;
    _showJobRules = YES;
    _showJobCount = NO;
    NSDictionary * choosedOptionDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];

    if (_enterType == ENTER_POINTREG_TYPE_SCAN && [ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]]]) {
        NSString * shareType = [choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]];
        if ([shareType integerValue] == 1|| [shareType integerValue] == 4) {
            _showJobRules = YES;
            _showJobCount = NO;
        }else if ([shareType integerValue] == 3){
            _showJobRules = NO;
            _showJobCount = YES;
        }else{
            _showJobCount = NO;
            _showJobRules = NO;
        }
    }

    [_contentTableView reloadData];
}

-(void)showListView:(NSArray *)listArr withLevel:(TASK_LIST_LEVEL)level withPointReg:(POINT_REG)pointReg
{
    ZEPointRegOptionView * customAlertView = [[ZEPointRegOptionView alloc]initWithOptionArr:listArr showButtons:NO withLevel:level withPointReg:pointReg];
    customAlertView.delegate = self;
    _alertView = [[JCAlertView alloc]initWithCustomView:customAlertView dismissWhenTouchedBackground:YES];
    [_alertView show];
}
-(void)showTaskView:(NSArray *)array
{
    ZEPointChooseTaskView * chooseTaskView = [[ZEPointChooseTaskView alloc]initWithOptionArr:array];
    chooseTaskView.delegate = self;
    _alertView = [[JCAlertView alloc]initWithCustomView:chooseTaskView dismissWhenTouchedBackground:YES];
    [_alertView show];
}
-(void)showDateView
{
    ZEPointRegChooseDateView * chooseDateView = [[ZEPointRegChooseDateView alloc]initWithFrame:CGRectZero];
    chooseDateView.delegate = self;
    _alertView = [[JCAlertView alloc]initWithCustomView:chooseDateView dismissWhenTouchedBackground:YES];
    [_alertView show];
}

-(void)showCountView
{
    ZEPointRegChooseCountView * chooseCountView = [[ZEPointRegChooseCountView alloc]initWithFrame:CGRectZero];
    chooseCountView.delegate = self;
    _alertView = [[JCAlertView alloc]initWithCustomView:chooseCountView dismissWhenTouchedBackground:YES];
    [_alertView show];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSString * shareType = [[[ZEPointRegCache instance] getResubmitCachesDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]];
    
    if(_enterType == ENTER_POINTREG_TYPE_HISTORY && [shareType integerValue] == 2){
        return 7;
    }
    
    if (!_showJobCount&&!_showJobRules){
        return 7;
    }
    return 8;
}
-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (_showJobRules == YES) {
        cell.textLabel.text = [ZEUtil getPointRegInformation:indexPath.row];
    }else if(_showJobCount == YES){
        cell.textLabel.text = [ZEUtil getPointRegInformation:indexPath.row];
        if (indexPath.row == 7 ) {
            cell.textLabel.text = [ZEUtil getPointRegInformation:indexPath.row + 1];
        }
    }else{
        cell.textLabel.text = [ZEUtil getPointRegInformation:indexPath.row];
    }
    if(_enterType == ENTER_POINTREG_TYPE_SCAN){
        [self setScanCodeListDetailText:indexPath.row cell:cell];
    }else if(_enterType == ENTER_POINTREG_TYPE_HISTORY){
        [self setHistoryListDetailText:indexPath.row cell:cell];
    }else{
        [self setListDetailText:indexPath.row cell:cell];
    }
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = MAIN_COLOR;
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(10, 43.5f, SCREEN_WIDTH - 10, 0.5f);
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    [cell.contentView.layer addSublayer:lineLayer];
    
    return cell;
}
#pragma mark - 默认界面
-(void)setListDetailText:(NSInteger)row cell:(UITableViewCell *)cell
{
    NSDictionary * choosedOptionDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];
    cell.detailTextLabel.text = @"请选择";
    switch (row) {
        case POINT_REG_TASK:
        {
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]) {
                ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)",model.TR_NAME,model.TR_HOUR];
            }
        }
            break;
        case POINT_REG_TIME:
        {
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME]]]) {
                cell.detailTextLabel.text = [choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME]];
            }else {
                NSDate * date = [NSDate date];
                NSDateFormatter * matter = [[NSDateFormatter alloc]init];
                matter.dateFormat = @"yyyy-MM-dd";
                NSString * dateStr = [matter stringFromDate:date];
                [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TIME]:dateStr}];
                cell.detailTextLabel.text = dateStr;
            }
        }
            break;
        case POINT_REG_WORKING_HOURS:
        {
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]) {
                ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]];
                cell.detailTextLabel.text = model.TR_HOUR;
            }else{
                cell.detailTextLabel.text = @"";
            }
        }
            break;
        case POINT_REG_TYPE:
        {
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]]]) {
                NSString * shareType = [choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]];
                cell.detailTextLabel.text = [ZEUtil getPointRegShareType:[shareType integerValue]];
            }else{
                [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TYPE]:@"1"}];
                cell.detailTextLabel.text = [ZEUtil getPointRegShareType:[[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]] integerValue]];
            }
        }
            break;
        case POINT_REG_DIFF_DEGREE:
        {
            cell.detailTextLabel.text = @"正常天气";
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]]) {
                ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]];
                cell.detailTextLabel.text = model.NDXS_LEVEL;
            }
        }
            break;
            
        case POINT_REG_TIME_DEGREE:
        {
            cell.detailTextLabel.text = @"正常工作日";
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]]) {
                ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]];
                cell.detailTextLabel.text = model.NDXS_LEVEL;
            }
        }
            break;
        case POINT_REG_ALLSCORE:
        {
            cell.detailTextLabel.text = [self decimalwithFormat:@"0.00" floatV:_allScore];
        }
            break;
        case POINT_REG_JOB_ROLES:
            if (_showJobRules) {
                if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]]) {
                    ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]];
                    
                    cell.detailTextLabel.text = model.TWR_NAME;
                }
                
            }else if (_showJobCount){
                cell.detailTextLabel.text = @"1次";
                
                if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]]) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@次",[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]];
                }
            }
            break;
            
        default:
            break;
    }
}
#pragma mark - 扫描界面
/**
 *   扫描界面进入工分登记界面不同
 */
-(void)setScanCodeListDetailText:(NSInteger)row cell:(UITableViewCell *)cell
{
    NSDictionary * choosedOptionDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];
    cell.detailTextLabel.text = @"请选择";
    switch (row) {
        case POINT_REG_TASK:
        {
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]) {
                ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)",model.TR_NAME,model.TR_HOUR];
            }
        }
            break;
        case POINT_REG_TIME:
        {
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME]]]) {
                cell.detailTextLabel.text = [choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME]];
            }else {
                NSDate * date = [NSDate date];
                NSDateFormatter * matter = [[NSDateFormatter alloc]init];
                matter.dateFormat = @"yyyy-MM-dd";
                NSString * dateStr = [matter stringFromDate:date];
                [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TIME]:dateStr}];
                cell.detailTextLabel.text = dateStr;
            }
        }
            break;
        case POINT_REG_WORKING_HOURS:
        {
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]) {
                ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]];
                cell.detailTextLabel.text = model.TR_HOUR;
            }
        }
            break;
        case POINT_REG_TYPE:
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]]]) {
                cell.detailTextLabel.text = [ZEUtil getPointRegShareType:[[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]] integerValue]];
            }
            break;
        case POINT_REG_DIFF_DEGREE:
        {
            cell.detailTextLabel.text = @"正常天气";
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]]) {
                ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]];
                cell.detailTextLabel.text = model.NDXS_LEVEL;
            }
        }
            break;
            
        case POINT_REG_TIME_DEGREE:
        {
            cell.detailTextLabel.text = @"正常工作日";
            if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]]) {
                ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]];
                cell.detailTextLabel.text = model.NDXS_LEVEL;
            }
        }
            break;
        case POINT_REG_ALLSCORE:
        {
            if (_allScore > 0) {
                cell.detailTextLabel.text = [self decimalwithFormat:@"0.00" floatV:_allScore];
            }else{
                ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]];
                cell.detailTextLabel.text = model.TR_HOUR;
            }
        }
            break;
        case POINT_REG_JOB_ROLES:
            if (_showJobRules) {
                if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]]) {
                    ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]];
                    cell.detailTextLabel.text = model.TWR_NAME;
                }
            }else if (_showJobCount){
                cell.detailTextLabel.text = @"次";
                if ([ZEUtil isNotNull:[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]]) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@次",[choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]];
                }
            }
            break;
            
        default:
            break;
    }

}
#pragma mark - 历史界面
-(void)setHistoryListDetailText:(NSInteger)row cell:(UITableViewCell *)cell
{
    NSDictionary * resubmitDic = [[ZEPointRegCache instance] getResubmitCachesDic];
    if ([ZEUtil isNotNull:[resubmitDic objectForKey:@"workrole"]]) {
        [[ZEPointRegCache instance] changeResubmitCache:@{[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]:[resubmitDic objectForKey:@"workrole"]}];
    }
    switch (row ) {
        case POINT_REG_TASK:
        {
            cell.detailTextLabel.text = _historyModel.TT_TASK;
            if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]) {
                ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)",model.TR_NAME,model.TR_HOUR];
                }
        }
            break;
        case POINT_REG_TIME:
        {
            cell.detailTextLabel.text = _historyModel.TT_ENDDATE;
            if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME]]]) {
                cell.detailTextLabel.text = [resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME]];
            }
        }
            break;
        case POINT_REG_WORKING_HOURS:
        {
            cell.detailTextLabel.text = _historyModel.TT_HOUR;
            if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]) {
                ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]];
                cell.detailTextLabel.text = model.TR_HOUR;
            }
        }
            break;
        case POINT_REG_TYPE:
        {
            cell.detailTextLabel.text = [ZEUtil getPointRegShareType:[_historyModel.DISPATCH_TYPE integerValue]];
            if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]]]) {
                cell.detailTextLabel.text = [ZEUtil getPointRegShareType:[[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]] integerValue]];
            }
        }
            break;
        case POINT_REG_DIFF_DEGREE:
        {
            cell.detailTextLabel.text = _historyModel.NDSX_NAME;
            if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]]) {
                ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]];
                cell.detailTextLabel.text = pointReg.NDXS_LEVEL;
            }
        }
            break;
            
        case POINT_REG_TIME_DEGREE:
        {
            cell.detailTextLabel.text = _historyModel.SJSX_NAME;
            if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]]) {
                ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]];
                cell.detailTextLabel.text = pointReg.NDXS_LEVEL;
            }
        }
            break;
        case POINT_REG_ALLSCORE:
        {
            cell.detailTextLabel.text =[resubmitDic objectForKey:@"allScore"];
            if(_allScore > 0){
                cell.detailTextLabel.text = [self decimalwithFormat:@"0.00" floatV:_allScore];
            }
        }
            break;
            
        case POINT_REG_JOB_ROLES:
        {
            if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]]]) {
                NSString * dispatch_type = [resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]];
                if ([dispatch_type integerValue] == 1 ||[dispatch_type integerValue] == 4  ) {
                    cell.detailTextLabel.text = @"请选择";
                    _showJobRules = YES;
                    _showJobCount = NO;
                    
                    ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:resubmitDic];
                    if ([pointReg.workrole isKindOfClass:[NSDictionary class]]) {
                        if ([[(NSDictionary *)pointReg.workrole objectForKey:@"TWR_NAME"] isEqualToString:@""]) {
                            cell.detailTextLabel.text = @"请选择";
                        }else{
                            cell.detailTextLabel.text = [(NSDictionary *)pointReg.workrole objectForKey:@"TWR_NAME"];
                        }
                    }else{
                        if ([pointReg.workrole isEqualToString:@""]) {
                            cell.detailTextLabel.text = @"请选择";
                        }else{
                            cell.detailTextLabel.text = pointReg.workrole;
                        }
                    }
                    cell.textLabel.text = [ZEUtil getPointRegInformation:POINT_REG_JOB_ROLES];
                }else if ([dispatch_type integerValue] == 3){
                    _showJobCount = YES;
                    _showJobRules = NO;
                    cell.textLabel.text = [ZEUtil getPointRegInformation:POINT_REG_JOB_COUNT];
                    cell.detailTextLabel.text = @"1次";
                    if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]]) {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@次",[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]];
                    }
                }else{
                    _showJobRules = NO;
                    _showJobCount = NO;
                }
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentSelectRow = indexPath.row;

    if ([self.delegate respondsToSelector:@selector(view:didSelectRowAtIndexpath:withShowRules:)]) {
        [self.delegate view:self didSelectRowAtIndexpath:indexPath withShowRules:_showJobRules];
    }
}


#pragma mark - ZEPointRegistrationViewDelegate
-(void)goBack
{
    [[ZEPointRegCache instance] clearResubmitCaches];
    [[ZEPointRegCache instance] clearUserOptions];
    if ([self.delegate respondsToSelector:@selector(goBack)]) {
        [self.delegate goBack];
    }
}
-(void)goSubmit{
    _allScore = 0;
    if ([self.delegate respondsToSelector:@selector(goSubmit:withShowRoles:withShowCount:)]) {
        [self.delegate goSubmit:self withShowRoles:_showJobRules withShowCount:_showJobCount];
    }
}
#pragma mark - ZEPointRegOptionViewDelegate
/**
 *  @author Zenith Electronic, 16-05-12 16:05:04
 *
 *  选择中弹出框的某一行
 *
 *  @param object 某一行返回数据
 *  @param row    选中第几行
 */
-(void)didSelectOption:(NSDictionary *)object withRow:(NSInteger)row
{
    
    UITableViewCell * cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectRow inSection:0]];
    if ([object isKindOfClass:[NSDictionary class]]) {
        if (_currentSelectRow == POINT_REG_TASK) {
            NSDictionary * dic = [NSDictionary dictionaryWithObject:object forKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
                        
            if (_enterType == ENTER_POINTREG_TYPE_HISTORY) {
                [[ZEPointRegCache instance] changeResubmitCache:dic];
            }else{
                [[ZEPointRegCache instance] setUserChoosedOptionDic:dic];
            }
            
            ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:object];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)",model.TR_NAME,model.TR_HOUR];
            UITableViewCell * taskHoursCell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
            taskHoursCell.detailTextLabel.text = model.TR_HOUR;
            [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TYPE]:model.DISPATCH_TYPE}];
            if ([model.DISPATCH_TYPE integerValue] == 3) {
                _showJobCount = YES;
                _showJobRules = NO;
            }else if ([model.DISPATCH_TYPE  integerValue] == 1 || [model.DISPATCH_TYPE integerValue] == 4){
                _showJobCount = NO;
                _showJobRules = YES;
            }else{
                _showJobCount = NO;
                _showJobRules = NO;
            }
        }else if (_currentSelectRow == POINT_REG_DIFF_DEGREE){
            if (_enterType == ENTER_POINTREG_TYPE_HISTORY) {
                [[ZEPointRegCache instance] changeResubmitCache:@{[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]:object}];
            }else{
                [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]:object}];
            }
            ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:object];
            cell.detailTextLabel.text = model.NDXS_LEVEL;
        }else if (_currentSelectRow == POINT_REG_TIME_DEGREE){
            if (_enterType == ENTER_POINTREG_TYPE_HISTORY) {
                [[ZEPointRegCache instance] changeResubmitCache:@{[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]:object}];
            }else{
                [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]:object}];
            }
            ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:object];
            cell.detailTextLabel.text = model.NDXS_LEVEL;
        }else if (_currentSelectRow == POINT_REG_JOB_ROLES &&  _showJobRules){
            if (_enterType == ENTER_POINTREG_TYPE_HISTORY) {
                [[ZEPointRegCache instance] changeResubmitCache:@{[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]:object}];
            }else{
                [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]:object}];
            }
            ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:object];
            cell.detailTextLabel.text = model.TWR_NAME;
        }
        [self calculationAllScore];

    }else{
        if(_currentSelectRow == POINT_REG_TYPE){
            if (_enterType == ENTER_POINTREG_TYPE_HISTORY) {
                [[ZEPointRegCache instance] changeResubmitCache:@{[ZEUtil getPointRegField:POINT_REG_TYPE]:[NSString stringWithFormat:@"%ld",(long)row + 1]}];
            }else{
                [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TYPE]:[NSString stringWithFormat:@"%ld",(long)row + 1]}];
            }
            NSDictionary * dic = [[ZEPointRegCache instance] getUserChoosedOptionDic];
            cell.detailTextLabel.text = [ZEUtil getPointRegShareType:[[dic objectForKey:[ZEUtil getPointRegField:POINT_REG_TYPE]] integerValue]];
            [self showDifferentListByShareTypeWithData:object];
        }else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",object];
        }
    }
    
    [_alertView dismissWithCompletion:nil];
  
}

#pragma mark - 计算工作得分

-(void)calculationAllScore
{
    if(_enterType == ENTER_POINTREG_TYPE_HISTORY){
        [self calculationResubmitAllScore];
    }else{
        [self calculationDefaultAllScore];
    }
    [_contentTableView reloadData];
    
}

-(void)calculationDefaultAllScore
{
    NSDictionary * choosedDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];
    _allScore = 0;
    if ([ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]) {
        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]];
        _allScore = [pointReg.TR_HOUR floatValue];
    }
    
    if ([ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]]) {
        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]];
        _allScore = _allScore * [pointReg.NDXS_SCORE floatValue];
    }
    
    if ([ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]]) {
        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]];
        _allScore = _allScore * [pointReg.NDXS_SCORE floatValue];
    }
    
    if ([[choosedDic objectForKey:@"shareType"] integerValue] == 4) {
        if ([ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]]) {
            ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]];
            _allScore = _allScore * [pointReg.TWR_QUOTIETY floatValue];
        }else if([[choosedDic objectForKey:@"workRoleScore"] floatValue] > 0) {
            _allScore = _allScore * [[choosedDic objectForKey:@"workRoleScore"] floatValue];
        }
    }
    
    
    if ([ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]]) {
        _allScore = _allScore * [[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]] integerValue];
    }
}

-(void)calculationResubmitAllScore
{
    NSDictionary * resubmitDic =  [[ZEPointRegCache instance] getResubmitCachesDic];
    _allScore = [[resubmitDic objectForKey:@"hour"] floatValue];
    if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]) {
        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]];
        _allScore = [pointReg.TR_HOUR floatValue];
    }
    
    if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]]) {
        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]];
        _allScore = _allScore * [pointReg.NDXS_SCORE floatValue];
    }else{
        _allScore = _allScore * [[resubmitDic objectForKey:@"ndxsScore"] floatValue];
    }
    
    if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]]) {
        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]];
        _allScore = _allScore * [pointReg.NDXS_SCORE floatValue];
    }else{
        _allScore = _allScore * [[resubmitDic objectForKey:@"sjxsScore"] floatValue];
    }
    
    if ([[resubmitDic objectForKey:@"shareType"] integerValue] == 4) {
        if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]] && [[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]] isKindOfClass:[NSDictionary class]]) {
            ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]];
            _allScore = _allScore * [pointReg.TWR_QUOTIETY floatValue];
        }else if([[resubmitDic objectForKey:@"workRoleScore"] floatValue] > 0) {
            _allScore = _allScore * [[resubmitDic objectForKey:@"workRoleScore"] floatValue];
        }
    }
    
    if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]]) {
        _allScore = _allScore * [[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]] integerValue];
    }

}

-(void)hiddeAlertView{
    [_alertView dismissWithCompletion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowAllTaskList object:nil];
    }];
}

#pragma mark - 选择不同分摊类型 界面效果不同
/**
 *  @author Zenith Electronic, 16-02-23 14:02:56
 *
 *  根据不同的分摊类型 刷新表界面
 *
 *  @param object 选择数据
 */
-(void)showDifferentListByShareTypeWithData:(NSDictionary *)object
{
    if (_currentSelectRow == 3) {
        if ([[NSString stringWithFormat:@"%@",object] isEqualToString:[ZEUtil getPointRegShareType:POINT_REG_SHARE_TYPE_COE]]) {
            [[ZEPointRegCache instance] clearCount];
            [[ZEPointRegCache instance] changeResubmitCache:@{[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]:@"1"}];
            _showJobRules = YES;
            _showJobCount = NO;
        }else if ([[NSString stringWithFormat:@"%@",object] isEqualToString:[ZEUtil getPointRegShareType:POINT_REG_SHARE_TYPE_COUNT ]] ){
            [[ZEPointRegCache instance] clearRoles];
            [[ZEPointRegCache instance] changeResubmitCache:@{[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]:@"1"}];
            _showJobRules = NO;
            _showJobCount = YES;
        }else if ([[NSString stringWithFormat:@"%@",object] isEqualToString:[ZEUtil getPointRegShareType:POINT_REG_SHARE_TYPE_WP]]){
            [[ZEPointRegCache instance] clearCount];
            [[ZEPointRegCache instance] changeResubmitCache:@{[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]:@"1"}];
            _showJobRules = YES;
            _showJobCount = NO;
        }else if ([[NSString stringWithFormat:@"%@",object] isEqualToString:[ZEUtil getPointRegShareType:POINT_REG_SHARE_TYPE_PEO]]){
            [[ZEPointRegCache instance] clearCount];
            [[ZEPointRegCache instance] clearRoles];
            [[ZEPointRegCache instance] changeResubmitCache:@{[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]:@"1"}];
            _showJobRules = NO;
            _showJobCount = NO;
        }
        [self calculationAllScore];
    }
}
#pragma mark - ZEPointRegChooseDateViewDelegate

-(void)cancelChooseDate
{
    [_alertView dismissWithCompletion:nil];
}
-(void)confirmChooseDate:(NSString *)dateStr
{
    UITableViewCell * cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectRow inSection:0]];
    cell.detailTextLabel.text = dateStr;
    if (_enterType == ENTER_POINTREG_TYPE_HISTORY) {
        [[ZEPointRegCache instance] changeResubmitCache:@{@"date":dateStr}];
    }else{
        [[ZEPointRegCache instance] setUserChoosedOptionDic:@{@"date":dateStr}];
    }

    [_alertView dismissWithCompletion:nil];
}
#pragma mark - ZEPointRegChooseCountViewDelegate

-(void)cancelChooseCount
{
    [_alertView dismissWithCompletion:nil];
}
-(void)confirmChooseCount:(NSString *)countStr
{
    UITableViewCell * cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectRow inSection:0]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@次",countStr];
    if (_enterType == ENTER_POINTREG_TYPE_HISTORY) {
        [[ZEPointRegCache instance] changeResubmitCache:@{[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]:countStr}];
    }else{
        [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]:countStr}];
    }
    [self calculationAllScore];
    [_alertView dismissWithCompletion:nil];
}


#pragma mark - ZEPointRegChooseTaskViewDelegate

-(void)didSeclectTask:(ZEPointChooseTaskView *)taskView withData:(NSDictionary *)dic
{
    NSDictionary * diction = [NSDictionary dictionaryWithObject:dic forKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    if(_enterType == ENTER_POINTREG_TYPE_HISTORY){
        [[ZEPointRegCache instance] changeResubmitCache:diction];
    }else{
        [[ZEPointRegCache instance] setUserChoosedOptionDic:diction];
    }
    
    UITableViewCell * cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectRow inSection:0]];
    
    ZEPointRegModel * model = [ZEPointRegModel getDetailWithDic:dic];
    cell.detailTextLabel.text = model.TR_NAME;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)",model.TR_NAME,model.TR_HOUR];
    [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TYPE]:model.DISPATCH_TYPE}];
    if ([model.DISPATCH_TYPE integerValue] == 3) {
        _showJobCount = YES;
        _showJobRules = NO;
    }else if ([model.DISPATCH_TYPE  integerValue] == 1 || [model.DISPATCH_TYPE integerValue] == 4){
        _showJobCount = NO;
        _showJobRules = YES;
    }else{
        _showJobCount = NO;
        _showJobRules = NO;
    }
    [self calculationAllScore];    
    [_alertView dismissWithCompletion:nil];
}

#pragma mark - 小数点四舍五入

//格式话小数 四舍五入类型
- (NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}


@end
