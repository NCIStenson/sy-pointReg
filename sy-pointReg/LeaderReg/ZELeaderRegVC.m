//
//  ZELeaderRegVC.m
//  sy-pointReg
//
//  Created by Stenson on 16/8/26.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#define kLEADERPOINTREG @"20"  //  负责人录入

#import "ZELeaderRegVC.h"
#import "ZELeaderRegView.h"

#import "ZECacheParameters.h"

#import "ZEPointRegCache.h"
#import "ZEUserServer.h"

#import "ZEEPM_TEAM_RATIONTYPE.h"
#import "ZEEPM_TEAM_RATION_COMMON.h"
#import "ZEEPM_TEAM_RATIONTYPEDETAIL.h"

#import "ZECalculateTotalPoint.h"

@interface ZELeaderRegVC ()<ZELeaderRegViewDelegate>
{
    ZELeaderRegView * _leaderRegView;
}
@end

@implementation ZELeaderRegVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"班组长工时登记";
    if(_isLeaderOrCharge == ENTER_MANYPERSON_POINTREG_TYPE_CHARGE){
        self.title = @"负责人工时登记";
    }
    [self cacheShareType];
    [self initView];
    [self setDate];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAllTaskView) name:kShowAllTaskList object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[ZEPointRegCache instance] clearUserOptions];
}


-(void)initView
{
    [self.rightBtn setTitle:@"提交" forState:UIControlStateNormal];
    if (_regType == ENTER_PERSON_POINTREG_TYPE_AUDIT) {
        [self.rightBtn setTitle:@"审核" forState:UIControlStateNormal];
    }
    self.rightBtn.backgroundColor = [UIColor clearColor];
    [self.rightBtn setImage:[UIImage imageNamed:@"icon_tick.png" color:[UIColor whiteColor]] forState:UIControlStateNormal];
    self.rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    
    _leaderRegView = [[ZELeaderRegView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT) withDafaulDic:_defaultDic withDefaultDetailArr:_defaultDetailArr withEnterType:_regType];
    _leaderRegView.delegate = self;
    [self.view addSubview:_leaderRegView];
    [self.view sendSubviewToBack:_leaderRegView];
    
}

-(void)setDate
{
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString * dateStr = [formatter stringFromDate:date];
    
    if(_regType == ENTER_PERSON_POINTREG_TYPE_DEFAULT){
        [[ZEPointRegCache instance]setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_DATE]:dateStr}];
    }else{
        dateStr = [[_defaultDic objectForKey:@"ENDDATE"] stringByReplacingOccurrencesOfString:@" 00:00:00.0" withString:@""];
        [[ZEPointRegCache instance]setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_DATE]:dateStr}];
    }
}
#pragma mark - 缓存分摊类型

-(void)cacheShareType
{
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        for (int i = 1; i < 7; i ++) {
            [self cacheCoefficientDetail:i];
        }
    });
    
    if ([[[ZEPointRegCache instance] getDistributionTypeCaches] count] > 0) {
        return;
    }
    
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATIONTYPE,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":@"pagetype = '1' and isselect = 'true' and suitunit = (case (select count(*) from epm_team_rationtype c where c.suitunit = '#SUITUNIT#') when 0 then '-1' else '#SUITUNIT#' end)",
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     @"DETAILTABLE":@"",};
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATIONTYPE]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 NSArray * arr =[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPE];
                                 [[ZEPointRegCache instance] setDistributionTypeCaches:arr];
                                 for (NSDictionary * dic in arr) {
                                     ZEEPM_TEAM_RATIONTYPE * model = [ZEEPM_TEAM_RATIONTYPE getDetailWithDic:dic];
                                     [self cacheDistributionTypeCoefficientWithCode:model.RATIONTYPECODE];
                                 }
                                 
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
    
}

-(void)cacheDistributionTypeCoefficientWithCode:(NSString *)rationCode
{
    NSString * WHERESQL = [NSString stringWithFormat:@"rationtypecode = '%@' and isselect = 'true' and suitunit = (case (select count(*) from epm_team_rationtype c where c.suitunit = 'XYSDLJ') when 0 then '-1' else 'XYSDLJ' end)",rationCode];
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATIONTYPEDETAIL,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":WHERESQL,
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     @"DETAILTABLE":@"",};
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATIONTYPEDETAIL]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 NSArray * arr = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPEDETAIL];
                                 if (arr.count > 0) {
                                     [[ZEPointRegCache instance] setDistributionTypeCoefficient:@{rationCode:arr}];
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}
-(void)cacheCoefficientDetail:(NSInteger)number
{
    if ([[[[ZEPointRegCache instance]getRATIONTYPEVALUE] allKeys] count] > 0) {
        return;
    }
    NSString * valueStr = [NSString stringWithFormat:@"QUOTIETY%ldCODE",(long)number];
    NSString * WHERESQL = [NSString stringWithFormat:@"suitunit = '#SUITUNIT#' and FIELDNAME = 'QUOTIETY%ldCODE' and secorgcode in (select case (select count(1) from EPM_TEAM_RATIONTYPEVALUE t where t.suitunit = '#SUITUNIT#' and FIELDNAME = 'QUOTIETY%ldCODE' and secorgcode = '#SECORGCODE#') when 0 then '-1' else '#SECORGCODE#' end from dual)",(long)number,(long)number];
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATIONTYPEVALUE,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":WHERESQL,
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     @"DETAILTABLE":@"",};
    
    NSDictionary * fieldsDic =@{@"QUOTIETYCODE":@"",
                                @"QUOTIETYNAME":@"",
                                @"QUOTIETY":@"",
                                @"DEFAULTCODE":@""};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATIONTYPEVALUE]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [[ZEPointRegCache instance] setRATIONTYPEVALUE:@{valueStr:[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPEVALUE]}];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
    
}


#pragma mark - 缓存常用任务列表

-(void)cacheTaskData
{
    if ([[[ZEPointRegCache instance] getTaskCaches] count] > 0) {
        return;
    }
    
    NSDictionary * parametersDic = @{@"limit":@"100",
                                     @"MASTERTABLE":EPM_TEAM_RATION_COMMON,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":@"SYSCREATORID   = '#PSNNUM#' and suitunit='#SUITUNIT#'",
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     @"DETAILTABLE":@"",};
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION_COMMON]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 NSArray * arr = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RATION_COMMON];
                                 [[ZEPointRegCache instance] setTaskCaches:arr];
                                 [_leaderRegView showListView:arr withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_TASK];
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

#pragma mark - 缓存全部任务列表

-(void)cacheAllTaskData
{
    if ([[[ZEPointRegCache instance] getAllTaskCaches] count] > 0) {
        return;
    }
    //第一条记录结束
    // 参数区域赋值
    
    NSDictionary * parametersDic = @{@"limit":@"2000",
                                     @"MASTERTABLE":V_EPM_TEAM_RATION_APP,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":@"orgcode in (#TEAMORGCODES#) and suitunit='#SUITUNIT#'",
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[V_EPM_TEAM_RATION_APP]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 NSArray * arr = [ZEUtil getServerData:data withTabelName:V_EPM_TEAM_RATION_APP];
                                 [[ZEPointRegCache instance] setAllTaskCaches:arr];
                                 [_leaderRegView showTaskView:arr];
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}
-(void)getTaskDetail:(NSString *)SEQKEY
{
    NSString * WHERESQL = [NSString stringWithFormat:@"SEQKEY=%@",SEQKEY];
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATION,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"WHERESQL":WHERESQL,
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 NSArray * taskDatas = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RATION];
                                 if ([ZEUtil isNotNull:taskDatas]) {
                                     [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TASK]:taskDatas[0]}];
                                 }
                                 [_leaderRegView reloadContentView];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

#pragma mark - ZELeaderRegViewDelegate
-(void)didSelectRowAtIndexpath:(NSIndexPath *)indexpath
{
    switch (indexpath.row) {
        case 0:
            [self showTaskView];
            break;
        case 1:
            [self showChooseDateView];
            break;
            
        case 3:
            [self showTypeView];
            break;
        default:
            break;
    }
}

-(void)showRATIONTYPEVALUE:(NSString *)QUOTIETYCODE
{
    NSDictionary * valueDic = [[ZEPointRegCache instance] getRATIONTYPEVALUE];
    NSArray * valueArr = [valueDic objectForKey:QUOTIETYCODE];
    
    [_leaderRegView showListView:valueArr withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_TYPE];
}
-(void)showWorkerListView
{
    NSArray * listArr = [[ZEPointRegCache instance] getWorkerList];
    if ([listArr count] > 0) {
        [_leaderRegView showWorkerListView:listArr];
        return;
    }
    
    NSDictionary * parametersDic = @{@"limit":@"2000",
                                     @"MASTERTABLE":EPM_BASE_REL,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"PSNNAME",
                                     @"WHERESQL":@"ORGCODE IN (#TEAMORGCODES#) and persontype like 'B%' AND ISASSESS='true'",
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{@"PSNNUM":@"",
                                @"PSNNAME":@""};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_BASE_REL]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 NSArray * arr = [ZEUtil getServerData:data withTabelName:EPM_BASE_REL];
                                 [[ZEPointRegCache instance] setWorkerList:arr];
                                 [_leaderRegView showWorkerListView:arr];
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

#pragma mark - 工作任务

-(void)showTaskView
{
    NSArray * taskCacheArr = nil;
    taskCacheArr = [[ZEPointRegCache instance] getTaskCaches];
    
    if (taskCacheArr.count > 0) {
        [_leaderRegView showListView:taskCacheArr withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_TASK];
    }else{
        [self cacheTaskData];
    }
}

-(void)showAllTaskView
{
    NSArray * allTaskCacheArr = nil;
    allTaskCacheArr = [[ZEPointRegCache instance] getAllTaskCaches];
    
    if (allTaskCacheArr.count > 0) {
        [_leaderRegView showTaskView:allTaskCacheArr];
    }else{
        [self cacheAllTaskData];
    }
}

#pragma mark - 发生日期
-(void)showChooseDateView
{
    [_leaderRegView showDateView];
}

#pragma mark - 分摊类型

-(void)showTypeView
{
//    [pointRegView showListView:@[@"按系数分配",@"按人头均摊",@"按次分配",@"按工分*系数分配"] withLevel:TASK_LIST_LEVEL_NOJSON withPointReg:POINT_REG_TYPE];
}

#pragma mark - 提交数据
-(void)rightBtnClick
{
    NSDictionary * choosedDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];
    
    if(![ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]){
        [self showAlertView:[NSString stringWithFormat:@"请选择%@",[ZEUtil getPointRegInformation:POINT_REG_TASK]] goBack:NO];
        return;
    }
    
    NSString* date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    date = [formatter stringFromDate:[NSDate date]];
    
    if([ZEUtil compareDate:date
                  withDate:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DATE]]] == 1){
        [self showAlertView:[NSString stringWithFormat:@"发生日期不能大于今天"] goBack:NO];
        return;
    }
    
    if (_leaderRegView.USERCHOOSEDWORKERVALUEARR.count == 0) {
        [self showAlertView:@"请至少添加一位工作人员" goBack:NO];
        return;
    }
    
    if (_regType == ENTER_PERSON_POINTREG_TYPE_HISTORY) {
        [self updateMessageToServer];
    }else if (_regType == ENTER_PERSON_POINTREG_TYPE_AUDIT){
        [self updateAuditMessageToServer];
    }else{
        [self submitMessageToServer];
    }
}


#pragma mark - 新增数据
-(void)submitMessageToServer
{
    NSString * status = @"";
    NSString * isSelf = @"";
    if (_isLeaderOrCharge == ENTER_MANYPERSON_POINTREG_TYPE_LEADER) {
        status = @"1";
        isSelf = @"";
    }else{
        status = @"10";
        isSelf = @"leader";
    }

    
    NSDictionary * parametersDic =@{
                                    @"MENUAPP":@"EMARK_APP",
                                    @"ORDERSQL":@"",
                                    @"WHERESQL":@"",
                                    @"METHOD":@"addSave",
                                    @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                    @"DETAILTABLE":EPM_TEAM_RATION_REG_DETAIL,
                                    @"MASTERFIELD":@"SEQKEY",
                                    @"DETAILFIELD":@"TASKID",
                                    @"self":isSelf,
                                    @"CLASSNAME":@"com.nci.app.biz.team.AppTeamRationReg",
                                    };
    
    NSDictionary * choosedTaskDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    
    ZEEPM_TEAM_RATION_COMMON * taskDetailM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
    
    NSString * dateStr = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_DATE]];
    
    
    NSMutableDictionary * defaultDic = [NSMutableDictionary dictionaryWithDictionary: @{@"ENDDATE":dateStr,
                                                                                        @"RATIONNAME":taskDetailM.RATIONNAME,
                                                                                        @"STDSCORE":taskDetailM.STDSCORE,
                                                                                        @"RATIONTYPE":taskDetailM.RATIONTYPE,
                                                                                        @"RATIONCODE":taskDetailM.RATIONCODE,
                                                                                        @"RATIONID":taskDetailM.SEQKEY,
                                                                                        @"ADDMODE":kLEADERPOINTREG,
                                                                                        @"STATUS":status}];
    
    for (NSInteger i = 0 ; i < _leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys.count ; i++) {
        NSString * keyStr = _leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i];
        
        if ([keyStr rangeOfString:@"QUOTIETY"].location != NSNotFound && [keyStr rangeOfString:@"CODE"].location == NSNotFound) {
            [defaultDic setObject:[_leaderRegView.CHOOSEDRATIONTYPEVALUEDic objectForKey:_leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]] forKey:_leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]];
        }
    }
    
    NSMutableArray * personalArr = [NSMutableArray array];
    NSMutableArray * tableNameArr = [NSMutableArray arrayWithObject:EPM_TEAM_RATION_REG];
    for (NSInteger i = 0; i < _leaderRegView.USERCHOOSEDWORKERVALUEARR.count; i ++) {
        NSMutableDictionary * personalDic =  [NSMutableDictionary dictionaryWithDictionary: _leaderRegView.USERCHOOSEDWORKERVALUEARR[i]];
        [personalDic removeObjectForKey:@"QSPOINTS"];
        [personalDic setObject:status forKey:@"STATUS"];
        if (![ZEUtil strIsEmpty:[NSString stringWithFormat:@"%@",[ZESettingLocalData getKValue]]]) {
            [personalDic setObject:[ZESettingLocalData getKValue] forKey:@"K"];
        }
        [personalDic setObject:@"" forKey:@"TASKID"];
        for (NSInteger j = 0 ; j < personalDic.allKeys.count ; j++) {
            NSString * keyStr = personalDic.allKeys[j];
            if ([keyStr rangeOfString:@"QUOTIETY"].location != NSNotFound && [keyStr rangeOfString:@"CODE"].location != NSNotFound) {
                [personalDic removeObjectForKey:personalDic.allKeys[j]];
            }
        }
        
        [personalArr addObject:personalDic];
        [tableNameArr addObject:EPM_TEAM_RATION_REG_DETAIL];
    }
    
    NSMutableArray * fieldsArr = [NSMutableArray arrayWithArray:personalArr];
    
//    把任务信息插入到第一条数据
    [fieldsArr insertObject:defaultDic atIndex:0];
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:tableNameArr
                                                                           withFields:fieldsArr
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [ZEUtil showAlertView:@"提交成功" viewController:self];
                                 [_leaderRegView submitSuccessReloadContentView];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

#pragma mark - 更新数据
-(void)updateMessageToServer
{
    NSString * status = @"";
    NSString * isSelf = @"";
    if (_isLeaderOrCharge == ENTER_MANYPERSON_POINTREG_TYPE_LEADER) {
        status = @"1";
        isSelf = @"";
    }else{
        status = @"10";
        isSelf = @"leader";
    }

    NSDictionary * parametersDic =@{
                                    @"MENUAPP":@"EMARK_APP",
                                    @"ORDERSQL":@"",
                                    @"WHERESQL":@"",
                                    @"METHOD":@"updateSave",
                                    @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                    @"DETAILTABLE":EPM_TEAM_RATION_REG_DETAIL,
                                    @"MASTERFIELD":@"SEQKEY",
                                    @"DETAILFIELD":@"TASKID",
                                    @"self":isSelf,
                                    @"CLASSNAME":@"com.nci.app.biz.team.AppTeamRationReg",
                                    };
    
    NSDictionary * choosedTaskDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    
    ZEEPM_TEAM_RATION_COMMON * taskDetailM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
    
    NSString * dateStr = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_DATE]];
    
    NSMutableDictionary * defaultDic = [NSMutableDictionary dictionaryWithDictionary: @{@"ENDDATE":dateStr,
                                                                                        @"RATIONNAME":taskDetailM.RATIONNAME,
                                                                                        @"STDSCORE":taskDetailM.STDSCORE,
                                                                                        @"RATIONTYPE":taskDetailM.RATIONTYPE,
                                                                                        @"RATIONCODE":taskDetailM.RATIONCODE,
                                                                                        @"RATIONID":taskDetailM.SEQKEY,
                                                                                        @"ADDMODE":kLEADERPOINTREG,
                                                                                        @"STATUS": [choosedTaskDic objectForKey:@"STATUS"],
                                                                                        @"SEQKEY":[_leaderRegView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"SEQKEY"]}];
    
    for (NSInteger i = 0 ; i < _leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys.count ; i++) {
        NSString * keyStr = _leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i];
        
        if ([keyStr rangeOfString:@"QUOTIETY"].location != NSNotFound && [keyStr rangeOfString:@"CODE"].location == NSNotFound) {
            [defaultDic setObject:[_leaderRegView.CHOOSEDRATIONTYPEVALUEDic objectForKey:_leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]] forKey:_leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]];
        }
    }
    
    NSMutableArray * personalArr = [NSMutableArray array];
    NSMutableArray * tableNameArr = [NSMutableArray arrayWithObject:EPM_TEAM_RATION_REG];

    for (NSInteger i = 0; i < _leaderRegView.USERCHOOSEDWORKERVALUEARR.count; i ++) {
        NSDictionary * dic = _leaderRegView.USERCHOOSEDWORKERVALUEARR[i];
        NSMutableDictionary * personalDic =  [NSMutableDictionary dictionaryWithDictionary: @{@"STATUS":[dic objectForKey:@"STATUS"],
                                                                                              @"SEQKEY":[dic objectForKey:@"SEQKEY"],
                                                                                              @"WORKPOINTS":[dic objectForKey:@"WORKPOINTS"],
                                                                                              @"TASKID":@"",
                                                                                              @"SUMPOINTS":[dic objectForKey:@"SUMPOINTS"],
                                                                                              @"DESCR":[dic objectForKey:@"DESCR"],
                                                                                              @"PSNNUM":[dic objectForKey:@"PSNNUM"],
                                                                                              @"PSNNAME":[dic objectForKey:@"PSNNAME"],
                                                                                              @"SUMPOINTS":[dic objectForKey:@"SUMPOINTS"],
                                                                                              }];
        if (![ZEUtil strIsEmpty:[NSString stringWithFormat:@"%@",[ZESettingLocalData getKValue]]]) {
            [personalDic setObject:[ZESettingLocalData getKValue] forKey:@"K"];
        }

        for (NSInteger j = 0 ; j < dic.allKeys.count ; j++) {
            NSString * keyStr = dic.allKeys[j];
            if ([keyStr rangeOfString:@"QUOTIETY"].location != NSNotFound && [keyStr rangeOfString:@"CODE"].location == NSNotFound) {
                [personalDic setObject:[dic objectForKey:dic.allKeys[j]] forKey:keyStr];
            }
        }
        [personalArr addObject:personalDic];
        [tableNameArr addObject:EPM_TEAM_RATION_REG_DETAIL];
    }
    [personalArr insertObject:defaultDic atIndex:0];
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:tableNameArr
                                                                           withFields:personalArr
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [self showAlertView:@"修改成功" goBack:YES];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

#pragma mark - 新增数据
-(void)updateAuditMessageToServer
{
    NSString * status = @"";
    NSString * isSelf = @"";
    if (_isLeaderOrCharge == ENTER_MANYPERSON_POINTREG_TYPE_LEADER) {
        status = @"1";
        isSelf = @"";
    }else{
        status = @"10";
        isSelf = @"leader";
    }
    NSDictionary * parametersDic =@{
                                    @"MENUAPP":@"EMARK_APP",
                                    @"ORDERSQL":@"",
                                    @"WHERESQL":@"",
                                    @"METHOD":@"updateSave",
                                    @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                    @"DETAILTABLE":EPM_TEAM_RATION_REG_DETAIL,
                                    @"MASTERFIELD":@"SEQKEY",
                                    @"DETAILFIELD":@"TASKID",
                                    @"self":isSelf,
                                    @"CLASSNAME":@"com.nci.app.biz.team.AppTeamRationReg",
                                    };
    
    NSDictionary * choosedTaskDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    
    ZEEPM_TEAM_RATION_COMMON * taskDetailM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
    
    NSString * dateStr = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_DATE]];
    
    NSMutableDictionary * defaultDic = [NSMutableDictionary dictionaryWithDictionary: @{@"ENDDATE":dateStr,
                                                                                        @"RATIONNAME":taskDetailM.RATIONNAME,
                                                                                        @"STDSCORE":taskDetailM.STDSCORE,
                                                                                        @"RATIONTYPE":taskDetailM.RATIONTYPE,
                                                                                        @"RATIONCODE":taskDetailM.RATIONCODE,
                                                                                        @"RATIONID":taskDetailM.SEQKEY,
                                                                                        @"ADDMODE":kLEADERPOINTREG,
                                                                                        @"STATUS":@"8",
                                                                                        @"SEQKEY":[_leaderRegView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"SEQKEY"]}];
    
    for (NSInteger i = 0 ; i < _leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys.count ; i++) {
        NSString * keyStr = _leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i];
        
        if ([keyStr rangeOfString:@"QUOTIETY"].location != NSNotFound && [keyStr rangeOfString:@"CODE"].location == NSNotFound) {
            [defaultDic setObject:[_leaderRegView.CHOOSEDRATIONTYPEVALUEDic objectForKey:_leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]] forKey:_leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]];
        }
    }
    
    NSMutableArray * personalArr = [NSMutableArray array];
    for (NSInteger i = 0; i < _leaderRegView.USERCHOOSEDWORKERVALUEARR.count; i ++) {
        NSDictionary * dic = _leaderRegView.USERCHOOSEDWORKERVALUEARR[i];
        NSMutableDictionary * personalDic =  [NSMutableDictionary dictionaryWithDictionary:@{@"TASKID":@"",
                                                                                             @"STATUS":[ZESettingLocalData getISLEADER] ?@"1" : @"8",
                                                                                              @"SEQKEY":[dic objectForKey:@"SEQKEY"],
                                                                                              @"WORKPOINTS":[dic objectForKey:@"WORKPOINTS"],
                                                                                              @"SUMPOINTS":[dic objectForKey:@"SUMPOINTS"],
                                                                                              @"DESCR":[dic objectForKey:@"DESCR"],
                                                                                              @"PSNNUM":[dic objectForKey:@"PSNNUM"],
                                                                                              @"PSNNAME":[dic objectForKey:@"PSNNAME"],
                                                                                              @"SUMPOINTS":[dic objectForKey:@"SUMPOINTS"],
                                                                                              }];
        for (NSInteger j = 0 ; j < dic.allKeys.count ; j++) {
            NSString * keyStr = dic.allKeys[j];
            if ([keyStr rangeOfString:@"QUOTIETY"].location != NSNotFound && [keyStr rangeOfString:@"CODE"].location == NSNotFound) {
                [personalDic setObject:[dic objectForKey:dic.allKeys[j]] forKey:keyStr];
            }
        }
        [personalArr addObject:personalDic];
    }
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION_REG,EPM_TEAM_RATION_REG_DETAIL]
                                                                           withFields:@[defaultDic,personalArr[0]]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [self showAlertView:@"提交成功"];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

-(void)showAlertView:(NSString *)str
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - Private Method
/**
 *  @author Zenith Electronic, 16-02-23 10:02:45
 *
 *  弹出提示框，如果是登记扫描完成就返回上层界面，
 *
 *
 *  @param str      弹出框文本信息
 *  @param isGoBack 是否返回上级界面
 */
-(void)showAlertView:(NSString *)str goBack:(BOOL)isGoBack
{
    if (IS_IOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (isGoBack) {
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiRefreshHistoryView object:nil];
            }
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:str message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowAllTaskList object:nil];
}

@end
