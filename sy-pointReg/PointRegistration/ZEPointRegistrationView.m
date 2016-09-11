//
//  ZEPointRegistrationView.m
//  NewCentury
//
//  Created by Stenson on 16/1/21.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#define kCOMMONPOINTREG @"20"  //  个人录入

#define kPERSONALEXPLAIN 10000

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
#define kContentViewHeight      (SCREEN_HEIGHT - kNavBarHeight)


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
#import "ZEEPM_TEAM_RATIONTYPEDETAIL.h"
#import "ZEEPM_TEAM_RATION_REGModel.h"

#import "ZECalculateTotalPoint.h"
@interface ZEPointRegistrationView ()<UITableViewDataSource,UITableViewDelegate,ZEPointRegOptionViewDelegate,ZEPointRegChooseDateViewDelegate,ZEPointChooseTaskViewDelegate,UITextFieldDelegate,ZEPointRegChooseCountViewDelegate,UITextFieldDelegate>
{
    JCAlertView * _alertView;
    NSInteger _currentSelectRow;
    UITableView * _contentTableView;
    UIView *navBar;
    
    UITextField * _currentTextField;
    
    ENTER_PERSON_POINTREG_TYPE _enterType;
    float _allScore; // 工作得分
}
@property (nonatomic,strong) NSMutableArray * commmonRationTypeValueArr;  // 跟随任务的选项系数
@property (nonatomic,strong) NSMutableArray * personalRationTypeValueArr; // 跟随人员的选项系数

@end

@implementation ZEPointRegistrationView

-(id)initWithFrame:(CGRect)rect withDafaulDic:(NSDictionary *)dic withDefaultDetailArr:(NSArray *)arr withEnterType:(ENTER_PERSON_POINTREG_TYPE)type
{
    self = [super initWithFrame:rect];
    if (self) {
        self.USERCHOOSEDWORKERVALUEARR = [NSMutableArray arrayWithArray:arr];
        self.CHOOSEDRATIONTYPEVALUEDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        
        _enterType = type;
        if (_enterType != ENTER_PERSON_POINTREG_TYPE_DEFAULT) {
            [self initDefaultData];
        }
        
        [self initNavBar];
        [self initView];
    }
    return self;
}

- (void)initNavBar
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:textField];

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
    if(_enterType == ENTER_PERSON_POINTREG_TYPE_AUDIT){
        [rightBtn setTitle:@"审核" forState:UIControlStateNormal];
    }else{
        [rightBtn setTitle:@"提交" forState:UIControlStateNormal];
    }
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
    [self isFollowTask];

    [self setWorkerDefaultData];
}

#pragma mark - 修改数据时  默认的数据

-(void)initDefaultData
{
    [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TASK]:_CHOOSEDRATIONTYPEVALUEDic}];
    
    NSDictionary * choosedTaskDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    
    ZEEPM_TEAM_RATION_COMMON * taskDetailM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
    NSArray * choosedCacheDisType = [[[ZEPointRegCache instance] getDistributionTypeCoefficient] objectForKey:taskDetailM.RATIONTYPE];

    self.commmonRationTypeValueArr = [NSMutableArray array];
    self.personalRationTypeValueArr = [NSMutableArray array];
    
    for (NSDictionary * dic in choosedCacheDisType) {
        ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
        if ([model.ISRATION boolValue]) {
            [self.commmonRationTypeValueArr addObject:dic];
        }else{
            [self.personalRationTypeValueArr addObject:dic];
        }
    }
    [self setDefaultWorkerData];
}

-(void)setDefaultWorkerData
{
    [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TASK]:_CHOOSEDRATIONTYPEVALUEDic}];
    
    NSDictionary * choosedTaskDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    
    ZEEPM_TEAM_RATION_REGModel * taskDetailM = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:choosedTaskDic];
    [self.CHOOSEDRATIONTYPEVALUEDic setObject:taskDetailM.SEQKEY forKey:@"SEQKEY"];
    for (NSDictionary * dic in self.commmonRationTypeValueArr) {
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
        if (![detailM.FIELDEDITOR boolValue]) {
            NSDictionary * valueDic = [[ZEPointRegCache instance] getRATIONTYPEVALUE];
            //          展示默认的选项值
            if ([[valueDic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSArray class]]) {
                for (NSDictionary * valueDetailDic in [valueDic objectForKey:detailM.FIELDNAME]) {
                    ZEEPM_TEAM_RATIONTYPEDETAIL * valueModel = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:valueDetailDic];
                    NSString * quotiety = [choosedTaskDic objectForKey:[detailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
                    if ([valueModel.QUOTIETY floatValue] == [quotiety floatValue]) {
                        NSDictionary * dic = @{detailM.FIELDNAME:valueDetailDic};
                        [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
                    }
                }
            }
        }else{
            NSString * quotiety = [choosedTaskDic objectForKey:[detailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];

            NSDictionary * dic = @{detailM.FIELDNAME:quotiety};
            [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
        }
    }
    if (_USERCHOOSEDWORKERVALUEARR.count > 0) {
        NSMutableDictionary * defaultDetailDic = [NSMutableDictionary dictionaryWithDictionary:_USERCHOOSEDWORKERVALUEARR[0]];
        
        for (NSDictionary * dic in self.personalRationTypeValueArr) {
            ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
            if (![detailM.FIELDEDITOR boolValue]) {
                NSDictionary * valueDic = [[ZEPointRegCache instance] getRATIONTYPEVALUE];
                //          展示默认的选项值
                if ([[valueDic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSArray class]]) {
                    for (NSDictionary * valueDetailDic in [valueDic objectForKey:detailM.FIELDNAME]) {
                        ZEEPM_TEAM_RATIONTYPEDETAIL * valueModel = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:valueDetailDic];
                        NSString * quotiety = [defaultDetailDic objectForKey:[detailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
                        if ([valueModel.QUOTIETY floatValue] == [quotiety floatValue]) {
                            NSDictionary * dic = @{detailM.FIELDNAME:valueDetailDic};
                            [defaultDetailDic setValuesForKeysWithDictionary:dic];
                            break;
                        }
                    }
                }
            }else{
                NSString * quotiety = [defaultDetailDic objectForKey:[detailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
                
                NSDictionary * dic = @{detailM.FIELDNAME:quotiety};
                
                [defaultDetailDic setValuesForKeysWithDictionary:dic];
            }
        }
        
        [self.USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:0 withObject:defaultDetailDic];
    }
}


#pragma mark - initData
/**
 *  @author Stenson, 16-08-31 09:08:27
 *
 *  初始化数据 根据分配类型 ISRATION 的选项系数是跟随任务 或者跟随个人
 *
 */
-(void)isFollowTask
{
    NSDictionary * choosedTaskDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    
    ZEEPM_TEAM_RATION_COMMON * taskDetailM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
    NSArray * choosedCacheDisType = [[[ZEPointRegCache instance] getDistributionTypeCoefficient] objectForKey:taskDetailM.RATIONTYPE];
    
    NSString * dateStr = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_DATE]];
    
    self.CHOOSEDRATIONTYPEVALUEDic = [NSMutableDictionary dictionaryWithDictionary: @{@"ENDDATE":dateStr,
                                                                                       @"RATIONNAME":taskDetailM.RATIONNAME,
                                                                                       @"STDSCORE":taskDetailM.STDSCORE,
                                                                                       @"STANDARDOPERATIONTIME":taskDetailM.STANDARDOPERATIONTIME,
                                                                                       @"STANDARDOPERATIONNUM":taskDetailM.STANDARDOPERATIONNUM,
                                                                                       @"CONVERSIONCOEFFICIENT":taskDetailM.CONVERSIONCOEFFICIENT,
                                                                                       @"CONVERSIONUNITS":taskDetailM.CONVERSIONUNITS,
                                                                                       @"RATIONTYPE":taskDetailM.RATIONTYPE,
                                                                                       @"RATIONCODE":taskDetailM.RATIONCODE,
                                                                                       @"RATIONID":taskDetailM.SEQKEY,
                                                                                       @"ADDMODE":kCOMMONPOINTREG,
                                                                                       @"STATUS":@"",
                                    }];

    
    self.commmonRationTypeValueArr = [NSMutableArray array];
    self.personalRationTypeValueArr = [NSMutableArray array];
    
    for (NSDictionary * dic in choosedCacheDisType) {
        ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
        if ([model.ISRATION boolValue]) {
            [self.commmonRationTypeValueArr addObject:dic];
        }else{
            [self.personalRationTypeValueArr addObject:dic];
        }
    }
}
/**
 *  @author Stenson, 16-08-31 10:08:09
 *
 *  设置人员选项系数 默认数据
 */
-(void)setWorkerDefaultData
{
    for (NSDictionary * dic in self.commmonRationTypeValueArr) {
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
        if (![detailM.FIELDEDITOR boolValue]) {
            NSDictionary * valueDic = [[ZEPointRegCache instance] getRATIONTYPEVALUE];
            //          展示默认的选项值
            if ([[valueDic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSArray class]]) {
                for (NSDictionary * valueDetailDic in [valueDic objectForKey:detailM.FIELDNAME]) {
                    ZEEPM_TEAM_RATIONTYPEDETAIL * valueModel = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:valueDetailDic];
                    if ([valueModel.DEFAULTCODE isEqualToString:@"true"]) {
                        NSDictionary * dic = @{detailM.FIELDNAME:valueDetailDic};
                        [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
                    }
                }
            }
        }else{
            NSDictionary * dic = @{detailM.FIELDNAME:@"1"};
            [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
        }
    }
        
    NSMutableDictionary * defaultDic = [NSMutableDictionary dictionary];
    
    for (NSDictionary * dic in self.personalRationTypeValueArr) {
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
        if (![detailM.FIELDEDITOR boolValue]) {
            NSDictionary * valueDic = [[ZEPointRegCache instance] getRATIONTYPEVALUE];
            //          展示默认的选项值
            if ([[valueDic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSArray class]]) {
                for (NSDictionary * valueDetailDic in [valueDic objectForKey:detailM.FIELDNAME]) {
                    ZEEPM_TEAM_RATIONTYPEDETAIL * valueModel = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:valueDetailDic];
                    if ([valueModel.DEFAULTCODE isEqualToString:@"true"]) {
                        NSDictionary * dic = @{detailM.FIELDNAME:valueDetailDic};
                        [defaultDic setValuesForKeysWithDictionary:dic];
                    }
                }
            }
        }else{
            NSDictionary * dic = @{detailM.FIELDNAME:@"1"};
            [defaultDic setValuesForKeysWithDictionary:dic];
        }
    }
    [defaultDic setValue:[ZESettingLocalData getUSERNAME] forKey:@"PSNNAME"];
    [defaultDic setValue:[ZESettingLocalData getUSERCODE] forKey:@"PSNNUM"];
    [defaultDic setValue:@"" forKey:@"DESCR"];
    [defaultDic setValue:@"10" forKey:@"STATUS"];
    [defaultDic setValue:@"0" forKey:@"WORKPOINTS"];
    [defaultDic setValue:@"0" forKey:@"SUMPOINTS"];
    [defaultDic setValue:@"" forKey:@"TASKID"];
    
    [self.USERCHOOSEDWORKERVALUEARR addObject:defaultDic];
        
    [self reloadUpadteData];
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
    //  分摊类型以下的系数跟随 分摊类型产生变化 从缓存在本地的分摊类型中 分配不同的参数
    NSDictionary * choosedTaskDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    ZEEPM_TEAM_RATION_COMMON * taskM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
    NSArray * cacheDisType = [[[ZEPointRegCache instance] getDistributionTypeCoefficient] objectForKey:taskM.RATIONTYPE];
    
    return 4 + cacheDisType.count + 2;
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
    
    [self setListDetailText:indexPath.row cell:cell];
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = MAIN_COLOR;
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(10, 43.5f, SCREEN_WIDTH - 10, 0.5f);
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    [cell.contentView.layer addSublayer:lineLayer];
    
    return cell;
}
#pragma mark - Defallt - CELL - UI
-(void)setListDetailText:(NSInteger)row cell:(UITableViewCell *)cell
{
    NSDictionary * choosedOptionDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];
    NSDictionary * choosedTaskDic = [choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    
    cell.detailTextLabel.textColor = MAIN_COLOR;

    if (row < 4) {
        cell.textLabel.text = [ZEUtil getPointRegInformation:row];
        cell.detailTextLabel.text = @"请选择";
    }else if(row < 4 + self.commmonRationTypeValueArr.count){
        
        NSDictionary * rationTypeDic = self.commmonRationTypeValueArr[row - 4];
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
        cell.textLabel.text = detailM.FIELDDISPLAY;
        cell.detailTextLabel.text = @"";
        
        if ([[self.CHOOSEDRATIONTYPEVALUEDic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSDictionary class]]) {
            ZEEPM_TEAM_RATIONTYPEDETAIL * valueModel = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:[self.CHOOSEDRATIONTYPEVALUEDic objectForKey:detailM.FIELDNAME]];
            cell.detailTextLabel.text = valueModel.QUOTIETYNAME;
        }else{
            
            UITextField * field = [[UITextField alloc]initWithFrame:CGRectMake(90.0f, 0, SCREEN_WIDTH - 105.0f, 44.0f)];
            field.delegate = self;
            field.keyboardType = UIKeyboardTypeDecimalPad;
            field.font = [UIFont systemFontOfSize:14.0f];
            field.textAlignment = NSTextAlignmentRight;
            field.textColor = MAIN_COLOR;
            field.tag = row;
            [cell.contentView addSubview:field];
            [field addTarget:self  action:@selector(valueChanged:)  forControlEvents:UIControlEventEditingChanged];
            
            field.text = [NSString stringWithFormat:@"%@",[self.CHOOSEDRATIONTYPEVALUEDic objectForKey:detailM.FIELDNAME]];
        }
    }else if(row < 4 + self.commmonRationTypeValueArr.count + self.personalRationTypeValueArr.count){
        NSDictionary * rationTypeDic = self.personalRationTypeValueArr[row - 4 - self.commmonRationTypeValueArr.count];
        NSLog(@" self.USERCHOOSEDWORKERVALUEARR >>>  %@ ",self.USERCHOOSEDWORKERVALUEARR);
        NSDictionary * dic = self.USERCHOOSEDWORKERVALUEARR[0];

        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
        cell.textLabel.text = detailM.FIELDDISPLAY;
        
        if ([[dic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSDictionary class]]) {
            ZEEPM_TEAM_RATIONTYPEDETAIL * valueModel = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:[dic objectForKey:detailM.FIELDNAME]];
            cell.detailTextLabel.text = valueModel.QUOTIETYNAME;
        }else{
            UITextField * field = [[UITextField alloc]initWithFrame:CGRectMake(90.0f, 0, SCREEN_WIDTH - 105.0f, 44.0f)];
            field.delegate      = self;
            field.keyboardType  = UIKeyboardTypeDecimalPad;
            field.font          = [UIFont systemFontOfSize:14.0f];
            field.textAlignment = NSTextAlignmentRight;
            field.textColor     = MAIN_COLOR;
            field.tag           = row;
            [cell.contentView addSubview:field];
            [field addTarget:self  action:@selector(valueChanged:)  forControlEvents:UIControlEventEditingChanged];
            
            field.text = [NSString stringWithFormat:@"%@",[dic objectForKey:detailM.FIELDNAME]];
        }
    }else{
        if (row == 4 + self.commmonRationTypeValueArr.count + self.personalRationTypeValueArr.count) {
            cell.textLabel.text = @"个人说明";

            UITextField * field = [[UITextField alloc]initWithFrame:CGRectMake(90.0f, 0, SCREEN_WIDTH - 105.0f, 44.0f)];
            field.delegate = self;
            field.placeholder = @"工时登记情况";
            field.font = [UIFont systemFontOfSize:14.0f];
            field.textAlignment = NSTextAlignmentRight;
            field.textColor = MAIN_COLOR;
            [cell.contentView addSubview:field];
            field.tag = 10000;
            if(self.USERCHOOSEDWORKERVALUEARR.count > 0){
                NSDictionary * dic = _USERCHOOSEDWORKERVALUEARR[0];
                if ([ZEUtil isStrNotEmpty:[dic objectForKey:@"DESCR"]]) {
                    field.text = [dic objectForKey:@"DESCR"];
                }
            }
        }else if (row == 5 + self.commmonRationTypeValueArr.count + self.personalRationTypeValueArr.count){
            cell.textLabel.text = @"工时得分";
            cell.detailTextLabel.text = @"0分";
            if(self.USERCHOOSEDWORKERVALUEARR.count > 0){
                NSDictionary * dic = _USERCHOOSEDWORKERVALUEARR[0];
                if ([[dic objectForKey:@"WORKPOINTS"] doubleValue] >0) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@分",[dic objectForKey:@"WORKPOINTS"]];
                }
            }
        }
    }

    switch (row) {
        case POINT_REG_TASK:
        {
            if ([ZEUtil isNotNull:choosedTaskDic]) {
                ZEEPM_TEAM_RATION_COMMON * taskM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
                cell.detailTextLabel.text = taskM.RATIONNAME;
            }
        }
            break;
            
        case POINT_REG_DATE:
        {
            NSString * dateStr = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_DATE]];
            cell.detailTextLabel.text = dateStr;
        }
            break;
            
        case POINT_REG_WORKING_HOURS:
        {
            if ([ZEUtil isNotNull:choosedTaskDic]) {
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

-(void)valueChanged:(UITextField *)textField
{
    if (textField.tag > 4 + self.commmonRationTypeValueArr.count) {
        NSDictionary * rationTypeDic = self.personalRationTypeValueArr[textField.tag - 4 - self.commmonRationTypeValueArr.count];
        
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
        
        NSDictionary * dic = @{detailM.FIELDNAME:textField.text};
        
        NSMutableDictionary * changeDic = _USERCHOOSEDWORKERVALUEARR[0];
        [changeDic setValuesForKeysWithDictionary:dic];
        [_USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:0 withObject:changeDic];
    }else if (textField.tag >= 4 ){
        NSDictionary * rationTypeDic = self.commmonRationTypeValueArr[textField.tag - 4];
        
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
        NSDictionary * dic = @{detailM.FIELDNAME:textField.text};
        
        [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
    }
    [self reloadUpadteDataTotalPoint];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEditing:YES];
    _currentSelectRow = indexPath.row;
    //  分摊类型以下的系数跟随 分摊类型产生变化 从缓存在本地的分摊类型中 分配不同的参数
//    NSDictionary * choosedTaskDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
//    ZEEPM_TEAM_RATION_COMMON * taskM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
//    NSArray * cacheDisType = [[[ZEPointRegCache instance] getDistributionTypeCoefficient] objectForKey:taskM.RATIONTYPE];

    if (indexPath.row < 4) {
        if (indexPath.row == 3) {
            return;
        }
        if ([self.delegate respondsToSelector:@selector(view:didSelectRowAtIndexpath:)]) {
            [self.delegate view:self didSelectRowAtIndexpath:indexPath];
        }
    }else if(indexPath.row < 4 + self.commmonRationTypeValueArr.count){
        ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:self.commmonRationTypeValueArr[indexPath.row - 4]];
        if([self.delegate respondsToSelector:@selector(showRATIONTYPEVALUE:)]){
            [self.delegate showRATIONTYPEVALUE:model.FIELDNAME];
        }
    }else if (indexPath.row < 4 + self.commmonRationTypeValueArr.count + self.personalRationTypeValueArr.count){
        ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:self.personalRationTypeValueArr[indexPath.row - 4 - self.commmonRationTypeValueArr.count]];
        if([self.delegate respondsToSelector:@selector(showRATIONTYPEVALUE:)]){
            [self.delegate showRATIONTYPEVALUE:model.FIELDNAME];
        }
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
    
    [self reloadUpadteData];
    
    [self endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(goSubmit:)]) {
        [self.delegate goSubmit:self];
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
-(void)didSelectOption:(id)object withRow:(NSInteger)row
{
    UITableViewCell * cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectRow inSection:0]];

    if (_currentSelectRow < 4) {
        [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TASK]:object}];
        [self reloadContentView];
    }else if (_currentSelectRow < self.commmonRationTypeValueArr.count + 4){
        ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:object];
        cell.detailTextLabel.text = model.QUOTIETYNAME;
        
        ZEEPM_TEAM_RATIONTYPEDETAIL *cacheDisTypeM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:self.commmonRationTypeValueArr[_currentSelectRow - 4]];
        NSDictionary * dic = @{cacheDisTypeM.FIELDNAME:object};
        [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
        [self reloadUpadteData];
    }else if (_currentSelectRow < self.commmonRationTypeValueArr.count + self.personalRationTypeValueArr.count + 4){
        ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:object];
        cell.detailTextLabel.text = model.QUOTIETYNAME;
        
        ZEEPM_TEAM_RATIONTYPEDETAIL *cacheDisTypeM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:self.personalRationTypeValueArr[_currentSelectRow - self.commmonRationTypeValueArr.count - 4]];
        
        NSMutableDictionary * changeDic = _USERCHOOSEDWORKERVALUEARR[0];
        [changeDic setValuesForKeysWithDictionary:@{cacheDisTypeM.FIELDNAME:object}];
        [_USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:0 withObject:changeDic];
        
        [self reloadUpadteData];
    }
    
    [_alertView dismissWithCompletion:nil];
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



#pragma mark - UITextFieldDelegate

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentTextField = textField;
    _currentSelectRow = textField.tag;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString * futureString = [NSMutableString stringWithString:textField.text];
    [futureString  insertString:string atIndex:range.location];
    
    NSInteger flag=0;
    const NSInteger limited = 2;  //小数点  限制输入两位
    for (NSInteger i = futureString.length - 1 ; i >= 0; i--) {
        
        if ([futureString characterAtIndex:i] == '.') {
            
            if (flag > limited) {
                return NO;
            }
            
            break;
        }
        flag++;
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag % 10000 == 0) {
        NSDictionary * dic = @{@"DESCR":textField.text};
        if (_USERCHOOSEDWORKERVALUEARR.count == 0) {
            return;
        }
        NSMutableDictionary * changeDic = _USERCHOOSEDWORKERVALUEARR[textField.tag / 10000 - 1];
        [changeDic setValuesForKeysWithDictionary:dic];
        [_USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:textField.tag / 10000 - 1 withObject:changeDic];
        return;
    }
    if (textField.tag > 4 + self.commmonRationTypeValueArr.count) {
        NSDictionary * rationTypeDic = self.personalRationTypeValueArr[textField.tag - 4 - self.commmonRationTypeValueArr.count];
        
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
        
        NSDictionary * dic = @{detailM.FIELDNAME:textField.text};
        
        NSMutableDictionary * changeDic = _USERCHOOSEDWORKERVALUEARR[0];
        [changeDic setValuesForKeysWithDictionary:dic];
        [_USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:0 withObject:changeDic];
    }else if (textField.tag >= 4 ){
        NSDictionary * rationTypeDic = self.commmonRationTypeValueArr[textField.tag - 4];
        
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
        NSDictionary * dic = @{detailM.FIELDNAME:textField.text};
        
        [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
    }
    [self reloadUpadteDataTotalPoint];
}


-(void)reloadUpadteDataTotalPoint
{
    for (int i = 0 ; i < self.CHOOSEDRATIONTYPEVALUEDic.allKeys.count; i ++) {
        id object = [self.CHOOSEDRATIONTYPEVALUEDic objectForKey:self.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]];
        if ([object isKindOfClass:[NSDictionary class]]) {
            [self.CHOOSEDRATIONTYPEVALUEDic setObject:[object objectForKey:@"QUOTIETY"] forKey:[self.CHOOSEDRATIONTYPEVALUEDic.allKeys[i] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
        }else{
            [self.CHOOSEDRATIONTYPEVALUEDic setObject:object forKey:[self.CHOOSEDRATIONTYPEVALUEDic.allKeys[i] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
        }
    }
    
    NSMutableDictionary * defaultDic = [NSMutableDictionary dictionaryWithDictionary:self.USERCHOOSEDWORKERVALUEARR[0]];
    for (int j = 0 ; j < defaultDic.allKeys.count; j ++) {
        id object = [defaultDic objectForKey:defaultDic.allKeys[j]];
        if ([object isKindOfClass:[NSDictionary class]]) {
            [defaultDic setObject:[object objectForKey:@"QUOTIETY"] forKey:[defaultDic.allKeys[j] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
        }else{
            [defaultDic setObject:object forKey:[defaultDic.allKeys[j] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
        }
    }
    
    [self.USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:0 withObject:defaultDic];
    
    [[ZECalculateTotalPoint instance] getTotalPointTaskDic:_CHOOSEDRATIONTYPEVALUEDic withPersonalDetailArr:_USERCHOOSEDWORKERVALUEARR];
    
    NSDictionary * resultDic = [[ZECalculateTotalPoint instance] getResultDic];
    
    self.CHOOSEDRATIONTYPEVALUEDic = [resultDic objectForKey:kFieldDic];
    self.USERCHOOSEDWORKERVALUEARR = [NSMutableArray arrayWithArray:[resultDic objectForKey:kDefaultFieldDic]];
    
    NSIndexPath * allIndexPath = [NSIndexPath indexPathForRow:4 + self.commmonRationTypeValueArr.count + self.personalRationTypeValueArr.count + 1 inSection:0];
    
    [_contentTableView reloadRowsAtIndexPaths:@[allIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

/**
 *  @author Stenson, 16-09-05 15:09:48
 *
 *  刷新需要上传到服务器的数据
 */
-(void)reloadUpadteData
{
    for (int i = 0 ; i < self.CHOOSEDRATIONTYPEVALUEDic.allKeys.count; i ++) {
        id object = [self.CHOOSEDRATIONTYPEVALUEDic objectForKey:self.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]];
        if ([object isKindOfClass:[NSDictionary class]]) {
            [self.CHOOSEDRATIONTYPEVALUEDic setObject:[object objectForKey:@"QUOTIETY"] forKey:[self.CHOOSEDRATIONTYPEVALUEDic.allKeys[i] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
        }else{
            [self.CHOOSEDRATIONTYPEVALUEDic setObject:object forKey:[self.CHOOSEDRATIONTYPEVALUEDic.allKeys[i] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
        }
    }
    
    NSMutableDictionary * defaultDic = [NSMutableDictionary dictionaryWithDictionary:self.USERCHOOSEDWORKERVALUEARR[0]];
    for (int j = 0 ; j < defaultDic.allKeys.count; j ++) {
        id object = [defaultDic objectForKey:defaultDic.allKeys[j]];
        if ([object isKindOfClass:[NSDictionary class]]) {
            [defaultDic setObject:[object objectForKey:@"QUOTIETY"] forKey:[defaultDic.allKeys[j] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
        }else{
            [defaultDic setObject:object forKey:[defaultDic.allKeys[j] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
        }
    }
    
    [self.USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:0 withObject:defaultDic];
    [[ZECalculateTotalPoint instance] getTotalPointTaskDic:_CHOOSEDRATIONTYPEVALUEDic withPersonalDetailArr:_USERCHOOSEDWORKERVALUEARR];
    
    NSDictionary * resultDic = [[ZECalculateTotalPoint instance] getResultDic];
    
    self.CHOOSEDRATIONTYPEVALUEDic = [resultDic objectForKey:kFieldDic];
    NSLog(@"kDefaultFieldDic>>>>>   %@",[resultDic objectForKey:kDefaultFieldDic]);
    self.USERCHOOSEDWORKERVALUEARR = [NSMutableArray arrayWithArray:[resultDic objectForKey:kDefaultFieldDic]];
    
    [_contentTableView reloadData];
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
