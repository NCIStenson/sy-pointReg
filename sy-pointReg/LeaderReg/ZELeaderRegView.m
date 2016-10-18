//
//  ZELeaderRegView.m
//  sy-pointReg
//
//  Created by Stenson on 16/8/26.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#define kDefaultRows  4

#define kContentViewMarginTop   64.0f
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - NAV_HEIGHT - 45.0f)

#import "ZELeaderRegView.h"
#import "ZEPointRegOptionView.h"
#import "JCAlertView.h"
#import "ZEPointChooseTaskView.h"
#import "ZEPointRegChooseDateView.h"
#import "ZEChooseWorkerView.h"

#import "ZEPointRegCache.h"

#import "ZEEPM_TEAM_RATION_COMMON.h"
#import "ZEV_EPM_TEAM_RATION_APP.h"
#import "ZEEPM_TEAM_RATIONTYPE.h"
#import "ZEEPM_TEAM_RATIONTYPEDETAIL.h"
#import "ZEEPM_TEAM_RATION_REGModel.h"

#import "ZECalculateTotalPoint.h"

@interface ZELeaderRegView ()<UITextFieldDelegate,ZEPointRegOptionViewDelegate,ZEPointChooseTaskViewDelegate,UITableViewDelegate,UITableViewDataSource,ZEPointRegChooseDateViewDelegate,ZEChooseWorkerViewDelegate>
{
    UITableView * _contentTableView;
    JCAlertView * _alertView;
    
    ENTER_PERSON_POINTREG_TYPE _enterType;
    
    BOOL _showRecordLen;  // 是否展示实录工序时长
    UIButton * _showRecordLengthBtn;
    
    NSIndexPath * _currentSelectIndexPath;
}

@property (nonatomic,strong) NSMutableArray * commmonRationTypeValueArr;  // 跟随任务的选项系数
@property (nonatomic,strong) NSMutableArray * personalRationTypeValueArr; // 跟随人员的选项系数

@property (nonatomic,strong) NSArray * choosedWorkerArr;
@property (nonatomic,strong) NSArray * recordLengthArr; // 实录工序时长

@property (nonatomic,strong) NSArray * rationTypeValueArr; // 个性化下拉框值

@end

@implementation ZELeaderRegView

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
        
        [self initView];
    }
    return self;
}

-(void)initView
{
    _contentTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
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
    
    _showRecordLengthBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _showRecordLengthBtn.frame = CGRectMake(-1, SCREEN_HEIGHT - 44, SCREEN_WIDTH +2, 45);
    [_showRecordLengthBtn setTitle:@"实录工序时长" forState:UIControlStateNormal];
    [self addSubview:_showRecordLengthBtn];
    [_showRecordLengthBtn addTarget:self action:@selector(showRecordContent) forControlEvents:UIControlEventTouchUpInside];
    _showRecordLengthBtn.layer.borderWidth = 1;
    _showRecordLengthBtn.layer.borderColor = [MAIN_LINE_COLOR CGColor];
}
#pragma mark - PublicMethod

-(void)reloadContentView
{
    [self isFollowTask];
    self.USERCHOOSEDWORKERVALUEARR = [NSMutableArray array];
    [self setWorkerDefaultData];
}
-(void)reloadContentView:(NSArray *)recordLen withRationTypeValue:(NSArray *)peronalRationTypeValue
{
    self.CHOOSEDRATIONTYPEVALUEDic = [NSMutableDictionary dictionary];
    self.USERCHOOSEDWORKERVALUEARR = [NSMutableArray array];
    self.recordLengthArr = recordLen;
    self.rationTypeValueArr = peronalRationTypeValue;
    [self isFollowTask];
    [self setWorkerDefaultData];
}


-(void)submitSuccessReloadContentView
{
    self.commmonRationTypeValueArr = [NSMutableArray array];
    self.personalRationTypeValueArr = [NSMutableArray array];
    self.USERCHOOSEDWORKERVALUEARR = [NSMutableArray array];
    self.CHOOSEDRATIONTYPEVALUEDic = [NSMutableDictionary dictionary];
    _choosedWorkerArr = nil;
    [[ZEPointRegCache instance] clearUserOptions];
    [self setDate];
    [_contentTableView  reloadData];
}
-(void)setDate
{
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString * dateStr = [formatter stringFromDate:date];
    
    [[ZEPointRegCache instance]setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_DATE]:dateStr}];
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
        if ([ZEUtil isStrNotEmpty:model.DISRANGE]) {
            BOOL _canAdd = NO;
            for (NSString * str in [model.DISRANGE componentsSeparatedByString:@","]) {
                if ([str integerValue] == 4 && _enterType == ENTER_PERSON_POINTREG_TYPE_AUDIT) {
                    _canAdd =YES;
                }else if ([str integerValue] == 1 && _enterType == ENTER_PERSON_POINTREG_TYPE_DEFAULT){
                    _canAdd = YES;
                }else if ([str integerValue] == 1 && _enterType == ENTER_PERSON_POINTREG_TYPE_HISTORY){
                    _canAdd = YES;
                }
            }
            if (!_canAdd) {
                continue;
            }
        }
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
        
        for (int i = 0 ; i < self.USERCHOOSEDWORKERVALUEARR.count; i ++) {
            NSMutableDictionary * defaultDetailDic = [NSMutableDictionary dictionaryWithDictionary:_USERCHOOSEDWORKERVALUEARR[i]];
            
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
            
            [self.USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:i withObject:defaultDetailDic];
        }
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
    
    if (choosedTaskDic.allKeys.count > 0) {
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
                                                                                          @"ADDMODE":kLEADERPOINTREG,
                                                                                          @"DESCR":@"",
                                                                                          @"STATUS":@""}];
    }
    
    self.commmonRationTypeValueArr = [NSMutableArray array];
    self.personalRationTypeValueArr = [NSMutableArray array];
    
    for (NSDictionary * dic in choosedCacheDisType) {
        ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
        if ([ZEUtil isStrNotEmpty:model.DISRANGE]) {
            BOOL _canAdd = NO;
            for (NSString * str in [model.DISRANGE componentsSeparatedByString:@","]) {
                if ([str integerValue] == 4 && _enterType == ENTER_PERSON_POINTREG_TYPE_AUDIT) {
                    _canAdd =YES;
                }else if ([str integerValue] == 1 && _enterType == ENTER_PERSON_POINTREG_TYPE_DEFAULT){
                    _canAdd = YES;
                }else if ([str integerValue] == 1 && _enterType == ENTER_PERSON_POINTREG_TYPE_HISTORY){
                    _canAdd = YES;
                }
            }
            if (!_canAdd) {
                continue;
            }
        }
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
                NSArray * getDefaulArr = [valueDic objectForKey:detailM.FIELDNAME];
                
                if (self.rationTypeValueArr.count > 0) {
                    NSMutableArray * valueArr = [NSMutableArray array];
                    for (NSDictionary * dic in self.rationTypeValueArr) {
                        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM1 = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
                        if ([detailM1.FIELDNAME isEqualToString:detailM.FIELDNAME]) {
                            [valueArr addObject:dic];
                            getDefaulArr = valueArr;
                        }
                    }
                }
                
                for (NSDictionary * valueDetailDic in getDefaulArr) {
                    ZEEPM_TEAM_RATIONTYPEDETAIL * valueModel = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:valueDetailDic];
                    BOOL hasDefault;
                    if ([valueModel.DEFAULTCODE isEqualToString:@"true"]) {
                        hasDefault = YES;
                        NSDictionary * dic = @{detailM.FIELDNAME:valueDetailDic};
                        [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
                        break;
                    }
                    // 如果没有设置默认选项 就把返回数据第一组设置成默认对象
                    if ([valueDetailDic isEqualToDictionary:[getDefaulArr lastObject]] && !hasDefault) {
                        NSDictionary * dic = @{detailM.FIELDNAME:[getDefaulArr firstObject]};
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
    for (NSDictionary * dic in _choosedWorkerArr) {
        defaultDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        
        for (NSDictionary * dic in self.personalRationTypeValueArr) {
            ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
            if (![detailM.FIELDEDITOR boolValue]) {
                NSDictionary * valueDic = [[ZEPointRegCache instance] getRATIONTYPEVALUE];
                //          展示默认的选项值
                if ([[valueDic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSArray class]]) {
                    NSArray * getDefaulArr = [valueDic objectForKey:detailM.FIELDNAME];
                    
                    if (self.rationTypeValueArr.count > 0) {
                        NSMutableArray * valueArr = [NSMutableArray array];
                        for (NSDictionary * dic in self.rationTypeValueArr) {
                            ZEEPM_TEAM_RATIONTYPEDETAIL * detailM1 = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
                            if ([detailM1.FIELDNAME isEqualToString:detailM.FIELDNAME]) {
                                [valueArr addObject:dic];
                                getDefaulArr = valueArr;
                            }
                        }
                    }
                    
                    for (NSDictionary * valueDetailDic in getDefaulArr) {
                        ZEEPM_TEAM_RATIONTYPEDETAIL * valueModel = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:valueDetailDic];
                        BOOL hasDefault;
                        if ([valueModel.DEFAULTCODE isEqualToString:@"true"]) {
                            hasDefault = YES;
                            NSDictionary * dic = @{detailM.FIELDNAME:valueDetailDic};
                            [defaultDic setValuesForKeysWithDictionary:dic];
                            break;
                        }
                        // 如果没有设置默认选项 就把返回数据第一组设置成默认对象
                        if ([valueDetailDic isEqualToDictionary:[getDefaulArr lastObject]] && !hasDefault) {
                            NSDictionary * dic = @{detailM.FIELDNAME:[getDefaulArr firstObject]};
                            [defaultDic setValuesForKeysWithDictionary:dic];
                        }
                    }
                }
            }else{
                NSDictionary * dic = @{detailM.FIELDNAME:@"1"};
                [defaultDic setValuesForKeysWithDictionary:dic];
            }
        }
        [defaultDic setValue:@"0" forKey:@"WORKPOINTS"];
        [defaultDic setValue:@"0" forKey:@"SUMPOINTS"];
        [defaultDic setValue:[dic objectForKey:@"PSNNUM"] forKey:@"PSNNUM"];
        [defaultDic setValue:[dic objectForKey:@"PSNNAME"] forKey:@"PSNNAME"];
        [self.USERCHOOSEDWORKERVALUEARR addObject:defaultDic];
    }
    
    [self reloadUpadteData];
}

-(void)showListView:(NSArray *)listArr withLevel:(TASK_LIST_LEVEL)level withPointReg:(POINT_REG)pointReg
{
    ZEPointRegOptionView * customAlertView = [[ZEPointRegOptionView alloc]initWithOptionArr:listArr showButtons:NO withLevel:level withPointReg:pointReg];
    customAlertView.delegate = self;
    _alertView = [[JCAlertView alloc]initWithCustomView:customAlertView dismissWhenTouchedBackground:YES];
    [_alertView show];
}

-(void)showTaskView:(NSArray *)array withConditionType:(POINT_REG)type
{
    ZEPointChooseTaskView * chooseTaskView = [[ZEPointChooseTaskView alloc]initWithOptionArr:array withConditionType:type];
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

-(void)showWorkerListView:(NSArray *)arr
{
    ZEChooseWorkerView * chooseTaskView = [[ZEChooseWorkerView alloc]initWithOptionArr:arr withWorkerList:_choosedWorkerArr];
    chooseTaskView.delegate = self;
    _alertView = [[JCAlertView alloc]initWithCustomView:chooseTaskView dismissWhenTouchedBackground:YES];
    [_alertView show];
}
#pragma mark - 显示实录工序时长
-(void)showRecordContent
{
    _showRecordLen = !_showRecordLen;
    if (_showRecordLen) {
        _showRecordLengthBtn.hidden = YES;
        [_contentTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(kContentViewMarginLeft);
            make.top.offset(kContentViewMarginTop);
            make.size.mas_equalTo(CGSizeMake(kContentViewWidth, kContentViewHeight + 45));
        }];
    }else{
        _showRecordLengthBtn.hidden = NO;
        [_contentTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(kContentViewMarginLeft);
            make.top.offset(kContentViewMarginTop);
            make.size.mas_equalTo(CGSizeMake(kContentViewWidth, kContentViewHeight));
        }];
    }
    [_contentTableView reloadData];
}


#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_showRecordLen){
        return self.choosedWorkerArr.count + 2;
    }else{
        return self.choosedWorkerArr.count + 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0f;
    }
    return 44.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton * showRecordLengthBtn;
    if (section == 1 + self.choosedWorkerArr.count) {
        
        showRecordLengthBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        showRecordLengthBtn.frame = CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44);
        [showRecordLengthBtn setTitle:@"实录工序时长" forState:UIControlStateNormal];
        [self addSubview:showRecordLengthBtn];
        [showRecordLengthBtn addTarget:self action:@selector(showRecordContent) forControlEvents:UIControlEventTouchUpInside];
        
        CALayer * horizontallyLine = [CALayer layer];
        horizontallyLine.frame = CGRectMake(0, 43, SCREEN_WIDTH, 1.0f);
        [showRecordLengthBtn.layer addSublayer:horizontallyLine];
        horizontallyLine.backgroundColor = [MAIN_LINE_COLOR CGColor];
        return showRecordLengthBtn;
    }else{
        UIView * BGView = [[UIView alloc]init];
        
        BGView.backgroundColor = RGBA(0, 84, 74, 0.5);
        
        UILabel * choosedWorkerLab = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, 0, SCREEN_WIDTH / 3, 44.0f)];
        choosedWorkerLab.text = @"工作人员";
        [BGView addSubview:choosedWorkerLab];
        
        NSDictionary * dic = self.USERCHOOSEDWORKERVALUEARR[section - 1];
        
        UILabel * workerNameLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 3 * 2 - 15.0f, 0, SCREEN_WIDTH / 3, 44.0f)];
        workerNameLab.text = [dic objectForKey:@"PSNNAME"];
        workerNameLab.textColor = [UIColor blackColor];
        workerNameLab.textAlignment = NSTextAlignmentRight;
        workerNameLab.font = [UIFont boldSystemFontOfSize:17];
        [BGView addSubview:workerNameLab];
        
        return BGView;
    }
    return showRecordLengthBtn;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if(_enterType == ENTER_PERSON_POINTREG_TYPE_DEFAULT){
            return kDefaultRows + 1 + self.commmonRationTypeValueArr.count;
        }else{
            return kDefaultRows + self.commmonRationTypeValueArr.count;
        }
    }else if (section == 1 + self.choosedWorkerArr.count){
        return self.recordLengthArr.count;
    }
    return self.personalRationTypeValueArr.count + 1;
}
-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if(indexPath.section == 0){
        [self setListDetailText:indexPath.row cell:cell];
    }else if (indexPath.section == 1 + self.choosedWorkerArr.count){
        [self setRecordLengthText:indexPath.row cell:cell];
    }else{
        [self setPersonalTypeValueWithIndexPath:indexPath withCell:cell];
    }
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = MAIN_COLOR;
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(10, 43.5f, SCREEN_WIDTH - 10, 0.5f);
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    [cell.contentView.layer addSublayer:lineLayer];
    
    return cell;
}

#pragma mark - 多人登记员工选项

-(void)setPersonalTypeValueWithIndexPath:(NSIndexPath *)indexPath withCell:(UITableViewCell *)cell
{
    NSDictionary * dic = _USERCHOOSEDWORKERVALUEARR[indexPath.section - 1];
    
    if (indexPath.row >= self.personalRationTypeValueArr.count) {
        if (indexPath.row ==  self.personalRationTypeValueArr.count){
            cell.textLabel.text = @"工时得分";
            cell.detailTextLabel.text = @"0分";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f分",[[dic objectForKey:@"WORKPOINTS"] floatValue]];
        }
    }else{
        
        NSDictionary * rationTypeDic = self.personalRationTypeValueArr[indexPath.row];
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
        cell.textLabel.text = detailM.FIELDDISPLAY;
        cell.detailTextLabel.text = @"";
        //          展示默认的选项值
        if ([[dic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSDictionary class]]) {
            ZEEPM_TEAM_RATIONTYPEDETAIL * valueModel = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:[dic objectForKey:detailM.FIELDNAME]];
            cell.detailTextLabel.text = valueModel.QUOTIETYNAME;
        }else{
            cell.detailTextLabel.text = @"";

            UITextField * field = [[UITextField alloc]initWithFrame:CGRectMake(90.0f, 0, SCREEN_WIDTH - 105.0f, 44.0f)];
            field.delegate = self;
            field.keyboardType = UIKeyboardTypeDecimalPad;
            field.font = [UIFont systemFontOfSize:14.0f];
            field.textAlignment = NSTextAlignmentRight;
            field.textColor = MAIN_COLOR;
            field.tag = indexPath.section * 100 + indexPath.row;
            [cell.contentView addSubview:field];
            [field addTarget:self  action:@selector(valueChanged:)  forControlEvents:UIControlEventEditingChanged];
            field.text = [NSString stringWithFormat:@"%@",[dic objectForKey:detailM.FIELDNAME]];
        }
    }
}

#pragma mark - 多人登记共同项

-(void)setListDetailText:(NSInteger)row cell:(UITableViewCell *)cell
{
    NSDictionary * choosedOptionDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];
    NSDictionary * choosedTaskDic = [choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    
    if (row == self.commmonRationTypeValueArr.count + kDefaultRows) {
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = @"";
        
        UILabel * addWorkerLab     = [UILabel new];
        addWorkerLab.font          = [UIFont systemFontOfSize:14];
        addWorkerLab.frame         = CGRectMake(0, 0, SCREEN_WIDTH, 44.0f);
        addWorkerLab.text          = @"添加工作人员";
        addWorkerLab.textAlignment = NSTextAlignmentCenter;
        addWorkerLab.textColor     = MAIN_COLOR;
        [cell.contentView addSubview:addWorkerLab];
    }else if (row < kDefaultRows){
        cell.detailTextLabel.textColor = MAIN_COLOR;
        cell.textLabel.text = [ZEUtil getPointRegInformation:row];
        cell.detailTextLabel.text = @"请选择";
        
        if (row ==  3) {
            cell.textLabel.text = @"个人说明";
            cell.detailTextLabel.text = @"";
            UITextField * field = [[UITextField alloc]initWithFrame:CGRectMake(90.0f, 0, SCREEN_WIDTH - 105.0f, 44.0f)];
            field.delegate = self;
            field.placeholder = @"工时登记情况";
            field.font = [UIFont systemFontOfSize:14.0f];
            field.textAlignment = NSTextAlignmentRight;
            field.textColor = MAIN_COLOR;
            [cell.contentView addSubview:field];
            field.tag = 1000;
            [field addTarget:self  action:@selector(valueChanged:)  forControlEvents:UIControlEventEditingChanged];
            
            if ([ZEUtil isStrNotEmpty:[self.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"DESCR"]]) {
                field.text = [self.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"DESCR"];
            }
        }

    }else if (row < self.commmonRationTypeValueArr.count + kDefaultRows){
        
        NSDictionary * rationTypeDic = self.commmonRationTypeValueArr[row - kDefaultRows];
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
        cell.textLabel.text = detailM.FIELDDISPLAY;
        cell.detailTextLabel.text = @"";
        
        if ([[self.CHOOSEDRATIONTYPEVALUEDic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSDictionary class]]) {
            ZEEPM_TEAM_RATIONTYPEDETAIL * valueModel = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:[self.CHOOSEDRATIONTYPEVALUEDic objectForKey:detailM.FIELDNAME]];
            cell.detailTextLabel.text = valueModel.QUOTIETYNAME;
        }else{
            cell.detailTextLabel.text = @"";

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
            
        case POINT_REG_CONDITION:
        {
            if ([ZEUtil isNotNull:choosedOptionDic]) {
                NSDictionary * dic = [choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_CONDITION]];
                if([ZEUtil isNotNull:dic]){
                    ZEV_EPM_TEAM_RATION_APP * model = [ZEV_EPM_TEAM_RATION_APP getDetailWithDic:dic];
                    cell.detailTextLabel.text = model.WORKPLACE;
                }else{
                    cell.detailTextLabel.text = @"请选择";
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
-(void)setRecordLengthText:(NSInteger)row cell:(UITableViewCell *)cell
{
    ZEEPM_TEAM_RATION_REGModel * recordLengthM = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:self.recordLengthArr[row]];
    
    cell.textLabel.text = recordLengthM.WORKINGPROCEDURE;
    cell.detailTextLabel.text = @"";
    
    UITextField * field = [[UITextField alloc]initWithFrame:CGRectMake(90.0f, 0, SCREEN_WIDTH - 105.0f, 44.0f)];
    field.delegate = self;
    field.text = recordLengthM.STANDARDOPERATIONTIME;
    field.font = [UIFont systemFontOfSize:14.0f];
    field.textAlignment = NSTextAlignmentRight;
    field.textColor = MAIN_COLOR;
    [cell.contentView addSubview:field];
    field.tag = 10000;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEditing:YES];
    _currentSelectIndexPath = indexPath;
    
    if(indexPath.section == 0){
        
        if (indexPath.row < kDefaultRows) {
            if (_enterType == ENTER_PERSON_POINTREG_TYPE_HISTORY || _enterType == ENTER_PERSON_POINTREG_TYPE_AUDIT) {
                return;
            }
            if (indexPath.row == 3) {
                return;
            }
            if ([self.delegate respondsToSelector:@selector(didSelectRowAtIndexpath:)]) {
                [self.delegate didSelectRowAtIndexpath:indexPath];
            }
        }else if (indexPath.row == self.commmonRationTypeValueArr.count + kDefaultRows){
            if ([self.delegate respondsToSelector:@selector(showWorkerListView)]) {
                [self.delegate showWorkerListView];
            }
        }else if(indexPath.row < kDefaultRows + self.commmonRationTypeValueArr.count){
            
            NSDictionary * rationTypeDic = self.commmonRationTypeValueArr[indexPath.row - kDefaultRows];
            ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
            
            //    避免点击输入框周围 弹出提示框
            if (![[self.CHOOSEDRATIONTYPEVALUEDic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSDictionary class]]) {
                return;
            }
            
            ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:self.commmonRationTypeValueArr[indexPath.row - kDefaultRows]];
            if([self.delegate respondsToSelector:@selector(showRATIONTYPEVALUE:)]){
                [self.delegate showRATIONTYPEVALUE:model.FIELDNAME];
            }
        }else{
            
        }
    }else{
        if(indexPath.row < self.personalRationTypeValueArr.count){
            
            NSDictionary * dic = _USERCHOOSEDWORKERVALUEARR[indexPath.section - 1];
            NSDictionary * rationTypeDic = self.personalRationTypeValueArr[indexPath.row];
            ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
            
            //    避免点击输入框周围 弹出提示框
            if (![[dic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSDictionary class]]) {
                return;
            }
            
            ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:self.personalRationTypeValueArr[indexPath.row]];
            if([self.delegate respondsToSelector:@selector(showRATIONTYPEVALUE:)]){
                [self.delegate showRATIONTYPEVALUE:model.FIELDNAME];
            }
        }
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
    if (_currentSelectIndexPath.section == 0) {
        UITableViewCell * cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectIndexPath.row inSection:0]];
        
        NSDictionary * choosedTaskDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
        ZEEPM_TEAM_RATION_COMMON * taskM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
        NSArray * cacheDisType = [[[ZEPointRegCache instance] getDistributionTypeCoefficient] objectForKey:taskM.RATIONTYPE];
        
        if (_currentSelectIndexPath.row < kDefaultRows) {
            ZEV_EPM_TEAM_RATION_APP * model = [ZEV_EPM_TEAM_RATION_APP getDetailWithDic:object];
            if ([self.delegate respondsToSelector:@selector(getTaskDetail:)]) {
                [self.delegate getTaskDetail:model.SEQKEY];
            }
        }else if (_currentSelectIndexPath.row < cacheDisType.count + kDefaultRows){
            ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:object];
            cell.detailTextLabel.text = model.QUOTIETYNAME;
            
            ZEEPM_TEAM_RATIONTYPEDETAIL *cacheDisTypeM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:_commmonRationTypeValueArr[_currentSelectIndexPath.row - kDefaultRows]];
            NSDictionary * dic = @{cacheDisTypeM.FIELDNAME:object};
            [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
            [self reloadUpadteData];
        }
        [_alertView dismissWithCompletion:nil];
    }else{
        UITableViewCell * cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectIndexPath.row inSection:0]];

        ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:object];
        cell.detailTextLabel.text = model.QUOTIETYNAME;
        
        ZEEPM_TEAM_RATIONTYPEDETAIL *cacheDisTypeM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:_personalRationTypeValueArr[_currentSelectIndexPath.row]];
        
        NSDictionary * dic = @{cacheDisTypeM.FIELDNAME:object};
        NSMutableDictionary * changeDic = _USERCHOOSEDWORKERVALUEARR[_currentSelectIndexPath.section - 1];

        [changeDic setValuesForKeysWithDictionary:dic];
        
        [_USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:_currentSelectIndexPath.section - 1 withObject:changeDic];

        [_contentTableView reloadRowsAtIndexPaths:@[_currentSelectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self reloadUpadteData];

        [_alertView dismissWithCompletion:nil];
    }
}

-(void)hiddeAlertView{
    [_alertView dismissWithCompletion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowAllTaskList object:nil];
    }];
}


#pragma mark - ZEPointRegChooseDateViewDelegate

-(void)cancelChooseDate
{
    [_alertView dismissWithCompletion:nil];
}
-(void)confirmChooseDate:(NSString *)dateStr
{
    if(_currentSelectIndexPath.section == 0){
        UITableViewCell * cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectIndexPath.row inSection:0]];
        cell.detailTextLabel.text = dateStr;
        [[ZEPointRegCache instance] setUserChoosedOptionDic:@{@"date":dateStr}];
        
        [_alertView dismissWithCompletion:nil];
    }
}
#pragma mark - ZEPointRegChooseTaskViewDelegate

-(void)didSeclectTask:(ZEPointChooseTaskView *)taskView withData:(NSDictionary *)dic withShowViewType:(POINT_REG)type
{
    ZEV_EPM_TEAM_RATION_APP * model = [ZEV_EPM_TEAM_RATION_APP getDetailWithDic:dic];
    if ([self.delegate respondsToSelector:@selector(getTaskDetail:)]) {
        [_alertView dismissWithCompletion:nil];
        [self.delegate getTaskDetail:model.SEQKEY];
    }
    
    [self reloadUpadteData];
}

#pragma mark - ZEPointRegChooseWorkerDelegate

-(void)didSeclectWorkerWithData:(NSArray *)choosedWorker
{
    _choosedWorkerArr = choosedWorker;
    [_alertView dismissWithCompletion:nil];
    
    [self setChangeChoosedWorker];
}

-(void)setChangeChoosedWorker
{
    for (int j = 0; j < _choosedWorkerArr.count; j ++) {
        NSDictionary * listDic = _choosedWorkerArr[j];
        BOOL isMask = NO;

        for (int i = 0; i < self.USERCHOOSEDWORKERVALUEARR.count ; i ++) {
            NSDictionary * dic = self.USERCHOOSEDWORKERVALUEARR[i];
            if ([[listDic objectForKey:@"PSNNUM"] isEqualToString:[dic objectForKey:@"PSNNUM"]]) {
                isMask = YES;
            }
        }
        
        if (!isMask) {
            NSMutableDictionary * defaultDic = [NSMutableDictionary dictionary];
            defaultDic = [NSMutableDictionary dictionaryWithDictionary:listDic];
            
            for (NSDictionary * dic in self.personalRationTypeValueArr) {
                ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
                if (![detailM.FIELDEDITOR boolValue]) {
                    NSDictionary * valueDic = [[ZEPointRegCache instance] getRATIONTYPEVALUE];
                    //          展示默认的选项值
                    if ([[valueDic objectForKey:detailM.FIELDNAME] isKindOfClass:[NSArray class]]) {
                        NSArray * getDefaulArr = [valueDic objectForKey:detailM.FIELDNAME];
                        
                        if (self.rationTypeValueArr.count > 0) {
                            NSMutableArray * valueArr = [NSMutableArray array];
                            for (NSDictionary * dic in self.rationTypeValueArr) {
                                ZEEPM_TEAM_RATIONTYPEDETAIL * detailM1 = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
                                if ([detailM1.FIELDNAME isEqualToString:detailM.FIELDNAME]) {
                                    [valueArr addObject:dic];
                                    getDefaulArr = valueArr;
                                }
                            }
                        }
                        
                        for (NSDictionary * valueDetailDic in getDefaulArr) {
                            ZEEPM_TEAM_RATIONTYPEDETAIL * valueModel = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:valueDetailDic];
                            BOOL hasDefault;
                            if ([valueModel.DEFAULTCODE isEqualToString:@"true"]) {
                                hasDefault = YES;
                                NSDictionary * dic = @{detailM.FIELDNAME:valueDetailDic};
                                [defaultDic setValuesForKeysWithDictionary:dic];
                                break;
                            }
                            // 如果没有设置默认选项 就把返回数据第一组设置成默认对象
                            if ([valueDetailDic isEqualToDictionary:[getDefaulArr lastObject]] && !hasDefault) {
                                NSDictionary * dic = @{detailM.FIELDNAME:[getDefaulArr firstObject]};
                                [defaultDic setValuesForKeysWithDictionary:dic];
                            }
                        }
                    }
                }else{
                    NSDictionary * dic = @{detailM.FIELDNAME:@"1"};
                    [defaultDic setValuesForKeysWithDictionary:dic];
                }
            }
            [defaultDic setValue:@"" forKey:@"DESCR"];
            [defaultDic setValue:@"0" forKey:@"WORKPOINTS"];
            [defaultDic setValue:@"0" forKey:@"SUMPOINTS"];
            [defaultDic setValue:[listDic objectForKey:@"PSNNUM"] forKey:@"PSNNUM"];
            [defaultDic setValue:[listDic objectForKey:@"PSNNAME"] forKey:@"PSNNAME"];
            [self.USERCHOOSEDWORKERVALUEARR addObject:defaultDic];
        }
    }

    
    for (int i = 0; i < self.USERCHOOSEDWORKERVALUEARR.count ; i ++) {
        NSDictionary * dic = self.USERCHOOSEDWORKERVALUEARR[i];
        BOOL isMask = false;
        for (int j = 0; j < _choosedWorkerArr.count; j ++) {
            NSDictionary * listDic = _choosedWorkerArr[j];
            if ([[listDic objectForKey:@"PSNNUM"] isEqualToString:[dic objectForKey:@"PSNNUM"]]) {
                isMask = YES;
            }
        }
        if (!isMask) {
            [self.USERCHOOSEDWORKERVALUEARR removeObject:self.USERCHOOSEDWORKERVALUEARR[i]];
        }
    }
    
    
    
    [self reloadUpadteData];
}


#pragma mark - UITextFieldDelegate

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
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
    
    for (int i = 0; i < self.USERCHOOSEDWORKERVALUEARR.count; i ++) {
        NSMutableDictionary * defaultDic = [NSMutableDictionary dictionaryWithDictionary:self.USERCHOOSEDWORKERVALUEARR[i]];
        for (int j = 0 ; j < defaultDic.allKeys.count; j ++) {
            id object = [defaultDic objectForKey:defaultDic.allKeys[j]];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [defaultDic setObject:[object objectForKey:@"QUOTIETY"] forKey:[defaultDic.allKeys[j] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
            }else{
                [defaultDic setObject:object forKey:[defaultDic.allKeys[j] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
            }
        }
        [self.USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:i withObject:defaultDic];
    }
    
    [[ZECalculateTotalPoint instance] getTotalPointTaskDic:_CHOOSEDRATIONTYPEVALUEDic withPersonalDetailArr:_USERCHOOSEDWORKERVALUEARR];
    
    NSDictionary * resultDic = [[ZECalculateTotalPoint instance] getResultDic];
    
    self.CHOOSEDRATIONTYPEVALUEDic = [resultDic objectForKey:kFieldDic];
    self.USERCHOOSEDWORKERVALUEARR = [resultDic objectForKey:kDefaultFieldDic];
    
    [_contentTableView reloadData];
}

#pragma mark - 实时监听用户输入事件
-(void)valueChanged:(UITextField *)textField
{
    if (textField.tag % 1000 == 0) {
        NSDictionary * dic = @{@"DESCR":textField.text};
        [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
    }else if (textField.tag > 99) {

        NSDictionary * rationTypeDic = self.personalRationTypeValueArr[textField.tag % 100];
        
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
        
        NSDictionary * dic = @{detailM.FIELDNAME:textField.text};
        
        NSMutableDictionary * changeDic = _USERCHOOSEDWORKERVALUEARR[textField.tag / 100 - 1];
        [changeDic setValuesForKeysWithDictionary:dic];
        [_USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:textField.tag / 100 - 1 withObject:changeDic];
    }else{
        NSDictionary * rationTypeDic = self.commmonRationTypeValueArr[textField.tag - kDefaultRows];
        
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
    
    for (int i = 0; i < self.USERCHOOSEDWORKERVALUEARR.count; i ++) {
        NSMutableDictionary * defaultDic = [NSMutableDictionary dictionaryWithDictionary:self.USERCHOOSEDWORKERVALUEARR[i]];
        for (int j = 0 ; j < defaultDic.allKeys.count; j ++) {
            id object = [defaultDic objectForKey:defaultDic.allKeys[j]];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [defaultDic setObject:[object objectForKey:@"QUOTIETY"] forKey:[defaultDic.allKeys[j] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
            }else{
                [defaultDic setObject:object forKey:[defaultDic.allKeys[j] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
            }
        }
        
        [self.USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:i withObject:defaultDic];
    }
    
    [[ZECalculateTotalPoint instance] getTotalPointTaskDic:_CHOOSEDRATIONTYPEVALUEDic withPersonalDetailArr:_USERCHOOSEDWORKERVALUEARR];
    
    NSDictionary * resultDic = [[ZECalculateTotalPoint instance] getResultDic];
    
    self.CHOOSEDRATIONTYPEVALUEDic = [resultDic objectForKey:kFieldDic];
    self.USERCHOOSEDWORKERVALUEARR = [NSMutableArray arrayWithArray:[resultDic objectForKey:kDefaultFieldDic]];
    
    NSMutableArray * indexpathArr = [NSMutableArray array];
    for (int i = 0; i < self.USERCHOOSEDWORKERVALUEARR.count; i ++ ) {
        NSIndexPath * allIndexPath = [NSIndexPath indexPathForRow:self.personalRationTypeValueArr.count inSection:i + 1];
        [indexpathArr addObject:allIndexPath];
    }
    
    [_contentTableView beginUpdates];
    [_contentTableView reloadRowsAtIndexPaths:indexpathArr withRowAnimation:UITableViewRowAnimationAutomatic];
    [_contentTableView endUpdates];
}
@end
