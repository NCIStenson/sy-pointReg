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

#import "ZEEPM_TEAM_RATION_COMMON.h"
#import "ZEV_EPM_TEAM_RATION_APP.h"
#import "ZEEPM_TEAM_RATIONTYPE.h"

@interface ZEPointRegistrationView ()<UITableViewDataSource,UITableViewDelegate,ZEPointRegOptionViewDelegate,ZEPointRegChooseDateViewDelegate,ZEPointChooseTaskViewDelegate,UITextFieldDelegate,ZEPointRegChooseCountViewDelegate>
{
    JCAlertView * _alertView;
    NSInteger _currentSelectRow;
    UITableView * _contentTableView;
    UIView *navBar;
    
    float _allScore; // 工作得分
}

@end

@implementation ZEPointRegistrationView

-(id)initWithFrame:(CGRect)rect;
{
    self = [super initWithFrame:rect];
    if (self) {
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
-(void)reloadContentView
{
    
//    NSDictionary * choosedOptionDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];

    [_contentTableView reloadData];
}

-(void)showListView:(NSArray *)listArr withLevel:(TASK_LIST_LEVEL)level withPointReg:(POINT_REG)pointReg
{
    NSLog(@" >>   %@",listArr);
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
    //  分摊类型以下的系数跟随 分摊类型产生变化 从缓存在本地的分摊类型中 分配不同的参数
    
    NSDictionary * choosedTaskDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    ZEEPM_TEAM_RATION_COMMON * taskM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
    NSArray * cacheDisType = [[[ZEPointRegCache instance] getDistributionTypeCoefficient] objectForKey:taskM.RATIONTYPE];
    
    return 4 + cacheDisType.count;
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
    
//    if(_enterType == ENTER_POINTREG_TYPE_SCAN){
//        [self setScanCodeListDetailText:indexPath.row cell:cell];
//    }else if(_enterType == ENTER_POINTREG_TYPE_HISTORY){
//        [self setHistoryListDetailText:indexPath.row cell:cell];
//    }else{
    
    [self setListDetailText:indexPath.row cell:cell];
    
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

    NSDictionary * choosedTaskDic = [choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];

    cell.textLabel.text = [ZEUtil getPointRegInformation:row];
    cell.detailTextLabel.text = @"请选择";

    switch (row) {
        case POINT_REG_TASK:
        {
            if ([ZEUtil isNotNull:choosedTaskDic]) {
                ZEEPM_TEAM_RATION_COMMON * taskM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
                cell.detailTextLabel.text = taskM.RATIONNAME;
            }
        }
            break;
            
        case POINT_REG_WORKING_HOURS:
        {
            if ([ZEUtil isNotNull:choosedOptionDic]) {
                ZEEPM_TEAM_RATION_COMMON * taskM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
                cell.detailTextLabel.text = taskM.STDSCORE;
            }
        }
            break;
            
        case POINT_REG_TYPE:
        {
            if ([ZEUtil isNotNull:choosedOptionDic]) {
                ZEEPM_TEAM_RATION_COMMON * taskM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
                for (NSDictionary * dic in [[ZEPointRegCache instance] getDistributionTypeCaches]) {
                    ZEEPM_TEAM_RATIONTYPE * model = [ZEEPM_TEAM_RATIONTYPE getDetailWithDic:dic];

                    if ([model.RATIONTYPECODE integerValue] == [taskM.RATIONTYPE integerValue]) {
                        cell.detailTextLabel.text = model.RATIONTYPENAME;
                    }
                }
            }
        }
            break;
            
        default:
        {
        }
            break;
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentSelectRow = indexPath.row;
    if ([self.delegate respondsToSelector:@selector(view:didSelectRowAtIndexpath:)]) {
        [self.delegate view:self didSelectRowAtIndexpath:indexPath];
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
-(void)didSelectOption:(id)object withRow:(NSInteger)row
{
    UITableViewCell * cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectRow inSection:0]];

    if ([object isKindOfClass:[NSDictionary class]]) {
        switch (_currentSelectRow) {
            case POINT_REG_TASK:
            {
                [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TASK]:object}];

                [_contentTableView reloadData];
//                ZEEPM_TEAM_RATION_COMMON * model = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:object];
//                cell.detailTextLabel.text = model.RATIONNAME ;
//                NSLog(@">>>  %@",model.RATIONNAME);
//                UITableViewCell * hourCell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:POINT_REG_WORKING_HOURS inSection:0]];
//                hourCell.detailTextLabel.text = model.RATIONFORM;
//
//                UITableViewCell * disTypeCell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:POINT_REG_TYPE inSection:0]];
//
//                disTypeCell.detailTextLabel.text = model.RATIONFORM;
//                for (NSDictionary * dic in [[ZEPointRegCache instance] getDistributionTypeCaches]) {
//                    ZEEPM_TEAM_RATIONTYPE * typeModel = [ZEEPM_TEAM_RATIONTYPE getDetailWithDic:dic];
//                    
//                    if ([typeModel.RATIONTYPECODE integerValue] == [model.RATIONTYPE integerValue]) {
//                        disTypeCell.detailTextLabel.text = typeModel.RATIONTYPENAME;
//                    }
//                }
//
            }
                break;
                
            default:
                break;
        }
    }
    
    [_alertView dismissWithCompletion:nil];
}

#pragma mark - 计算工作得分

-(void)calculationAllScore
{
    [_contentTableView reloadData];
    
}

-(void)calculationDefaultAllScore
{
//    NSDictionary * choosedDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];
//    _allScore = 0;
//    if ([ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]) {
//        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]];
//        _allScore = [pointReg.TR_HOUR floatValue];
//    }
//    
//    if ([ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]]) {
//        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]];
//        _allScore = _allScore * [pointReg.NDXS_SCORE floatValue];
//    }
//    
//    if ([ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]]) {
//        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]];
//        _allScore = _allScore * [pointReg.NDXS_SCORE floatValue];
//    }
//    
//    if ([[choosedDic objectForKey:@"shareType"] integerValue] == 4) {
//        if ([ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]]) {
//            ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]];
//            _allScore = _allScore * [pointReg.TWR_QUOTIETY floatValue];
//        }else if([[choosedDic objectForKey:@"workRoleScore"] floatValue] > 0) {
//            _allScore = _allScore * [[choosedDic objectForKey:@"workRoleScore"] floatValue];
//        }
//    }
//    
//    
//    if ([ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]]) {
//        _allScore = _allScore * [[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]] integerValue];
//    }
}

-(void)calculationResubmitAllScore
{
//    NSDictionary * resubmitDic =  [[ZEPointRegCache instance] getResubmitCachesDic];
//    _allScore = [[resubmitDic objectForKey:@"hour"] floatValue];
//    if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]) {
//        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]];
//        _allScore = [pointReg.TR_HOUR floatValue];
//    }
//    
//    if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]]) {
//        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DIFF_DEGREE]]];
//        _allScore = _allScore * [pointReg.NDXS_SCORE floatValue];
//    }else{
//        _allScore = _allScore * [[resubmitDic objectForKey:@"ndxsScore"] floatValue];
//    }
//    
//    if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]]) {
//        ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME_DEGREE]]];
//        _allScore = _allScore * [pointReg.NDXS_SCORE floatValue];
//    }else{
//        _allScore = _allScore * [[resubmitDic objectForKey:@"sjxsScore"] floatValue];
//    }
//    
//    if ([[resubmitDic objectForKey:@"shareType"] integerValue] == 4) {
//        if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]] && [[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]] isKindOfClass:[NSDictionary class]]) {
//            ZEPointRegModel * pointReg =  [ZEPointRegModel getDetailWithDic:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]];
//            _allScore = _allScore * [pointReg.TWR_QUOTIETY floatValue];
//        }else if([[resubmitDic objectForKey:@"workRoleScore"] floatValue] > 0) {
//            _allScore = _allScore * [[resubmitDic objectForKey:@"workRoleScore"] floatValue];
//        }
//    }
//    
//    if ([ZEUtil isNotNull:[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]]) {
//        _allScore = _allScore * [[resubmitDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]] integerValue];
//    }

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
    [[ZEPointRegCache instance] setUserChoosedOptionDic:@{@"date":dateStr}];

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
//    if (_enterType == ENTER_POINTREG_TYPE_HISTORY) {
//        [[ZEPointRegCache instance] changeResubmitCache:@{[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]:countStr}];
//    }else{
//        [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]:countStr}];
//    }
    [self calculationAllScore];
    [_alertView dismissWithCompletion:nil];
}


#pragma mark - ZEPointRegChooseTaskViewDelegate

-(void)didSeclectTask:(ZEPointChooseTaskView *)taskView withData:(NSDictionary *)dic
{
    ZEV_EPM_TEAM_RATION_APP * model = [ZEV_EPM_TEAM_RATION_APP getDetailWithDic:dic];
    if ([self.delegate respondsToSelector:@selector(getTaskDetail:)]) {
        [_alertView dismissWithCompletion:nil];
        [self.delegate getTaskDetail:model.SEQKEY];
    }
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
