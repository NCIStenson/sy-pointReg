//
//  ZEHistoryDetailView.m
//  NewCentury
//
//  Created by Stenson on 16/2/17.
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
#define kRightButtonWidth 70.0f
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

#import "ZEHistoryDetailView.h"
#import "ZEPointRegModel.h"
#import "ZEPointAuditModel.h"
@interface ZEHistoryDetailView ()
{
    ZEHistoryModel * _historyModel;
    ENTER_FIXED_POINTREG_TYPE _enterType;
    UITextField * _countField;
    BOOL _isAudit; //是否审核通过，通过审核的历史记录不能进行修改，未审核的历史记录可以进行修改。
}
@end

@implementation ZEHistoryDetailView

-(id)initWithFrame:(CGRect)rect withModel:(id)model withEnterType:(ENTER_FIXED_POINTREG_TYPE)enterType
{
    self = [super initWithFrame:rect];
    if (self) {
        _enterType = enterType;
        _historyModel = model;
        [self initNavBar];
        [self initView];
    }
    return self;
}

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
        
    UILabel *navTitleLabel = [UILabel new];
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.textColor = [UIColor whiteColor];
    navTitleLabel.font = [UIFont systemFontOfSize:24.0f];
    if(_enterType == ENTER_FIXED_POINTREG_TYPE_HIS){
        navTitleLabel.text = @"历史查询";
    }else{
        navTitleLabel.text = @"工分审核";
    }
    [navBar addSubview:navTitleLabel];
    [navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.rightMargin.offset(kNavTitleLabelMarginLeft);
        make.top.offset(kNavTitleLabelMarginTop);
        make.size.mas_equalTo(CGSizeMake(kNavTitleLabelWidth, kNavTitleLabelHeight));
    }];
    
    if(_enterType == ENTER_FIXED_POINTREG_TYPE_AUDIT && [_historyModel.TT_FLAG isEqualToString:@"未审核"]){
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitle:@"审核" forState:UIControlStateNormal];
        rightBtn.backgroundColor = [UIColor clearColor];
        [rightBtn setImage:[UIImage imageNamed:@"icon_tick.png" color:[UIColor whiteColor]] forState:UIControlStateNormal];
        rightBtn.contentMode = UIViewContentModeScaleAspectFit;
        [rightBtn addTarget:self action:@selector(goAudit) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0,0)];
        [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0,0)];
        [navBar addSubview:rightBtn];
        [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(kRightButtonMarginRight);
            make.top.offset(kRightButtonMarginTop);
            make.size.mas_equalTo(CGSizeMake(kRightButtonWidth, kRightButtonHeight));
        }];
    }
    
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
    UITableView * _contentTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    [self addSubview:_contentTableView];
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kContentViewMarginLeft);
        make.top.offset(kContentViewMarginTop);
        make.size.mas_equalTo(CGSizeMake(kContentViewWidth, kContentViewHeight));
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_historyModel.DISPATCH_TYPE integerValue] == 2) {
        return 8;
    }
    return 9;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = MAIN_COLOR;
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(10, 43.5f, SCREEN_WIDTH - 10, 0.5f);
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    [cell.contentView.layer addSublayer:lineLayer];

    [self setListDetailText:indexPath.row cell:cell];
    
    return cell;
}

-(void)setListDetailText:(NSInteger)row cell:(UITableViewCell *)cell
{
    cell.textLabel.text = [ZEUtil getPointRegInformation:row - 1];

    if (row == 0) {
        cell.textLabel.text = @"工作人员";
//        cell.detailTextLabel.text = [ZESetLocalData getUsername];
    }
    
//    switch (row - 1) {
//        case POINT_REG_TASK:
//        {
//            cell.detailTextLabel.text = _historyModel.TT_TASK;
//        }
//            break;
//        case POINT_REG_TIME:
//        {
//            cell.detailTextLabel.text = _historyModel.TT_ENDDATE;
//        }
//            break;
//        case POINT_REG_WORKING_HOURS:
//        {
//            cell.detailTextLabel.text = _historyModel.TT_HOUR;
//        }
//            break;
//        case POINT_REG_TYPE:
//        {
//            cell.detailTextLabel.text = [ZEUtil getPointRegShareType:[_historyModel.DISPATCH_TYPE integerValue]];
//        }
//            break;
//        case POINT_REG_DIFF_DEGREE:
//        {
//            cell.detailTextLabel.text = _historyModel.NDSX_NAME;
//        }
//            break;
//            
//        case POINT_REG_TIME_DEGREE:
//        {
//            cell.detailTextLabel.text = _historyModel.SJSX_NAME;
//        }
//            break;
//        case POINT_REG_ALLSCORE:
//            cell.detailTextLabel.text = _historyModel.REAL_HOUR;
//            break;
//        case POINT_REG_JOB_ROLES:
//           {
//               if([_historyModel.DISPATCH_TYPE integerValue] == 1 ||[_historyModel.DISPATCH_TYPE integerValue] == 4 ){
//                   //按系数分配的情况
//                   cell.detailTextLabel.text = _historyModel.ROLENAME;
//               }else if ([_historyModel.DISPATCH_TYPE integerValue] == 3){
//                   cell.textLabel.text = [ZEUtil getPointRegInformation:row];
//                   cell.detailTextLabel.text = [NSString stringWithFormat: @"%@次",_historyModel.TIMES];
//               }
//            }
//            break;
//            
//        default:
//            break;
//    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_historyModel.TT_FLAG isEqualToString:@"未审核"]) {
        
    }
}


#pragma mark - DetailViewDelegate

-(void)goBack
{  
    if ([self.delegate respondsToSelector:@selector(goBack)]) {
        [self.delegate goBack];
    }
}

-(void)goAudit
{
    ZEPointAuditModel * pointM = (ZEPointAuditModel *)_historyModel;
    if ([self.delegate respondsToSelector:@selector(confirmAudit:)]) {
        [self.delegate confirmAudit:pointM.SEQKEY];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
