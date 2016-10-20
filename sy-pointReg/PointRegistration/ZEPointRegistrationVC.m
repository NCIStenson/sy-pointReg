//
//  ZEPointRegistrationVC.m
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#define kCOMMONPOINTREG @"20"  //  负责人录入

#import "ZEPointRegistrationVC.h"
#import "ZEPointRegistrationView.h"
#import "ZEPointRegCache.h"
#import "MBProgressHUD.h"
#import "ZEUserServer.h"

#import "ZEEPM_TEAM_RATIONTYPE.h"

#import "ZEEPM_TEAM_RATION_COMMON.h"
#import "ZEEPM_TEAM_RATIONTYPEDETAIL.h"

#import "ZECalculateTotalPoint.h"

@interface ZEPointRegistrationVC ()<ZEPointRegistrationViewDelegate>
{
    ZEPointRegistrationView * _pointView;
}

@end

@implementation ZEPointRegistrationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
        
    _pointView = [[ZEPointRegistrationView alloc]initWithFrame:self.view.frame
                                                 withDafaulDic:_defaultDic
                                          withDefaultDetailArr:_defaultDetailArr
                                           withRecordLengthArr:_recordLengthArr
                                           withRationTypeValue:_rationTypeValueArr
                                                 withEnterType:_regType];
    _pointView.delegate = self;
    [self.view addSubview:_pointView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAllTaskView) name:kShowAllTaskList object:nil];
    
    [self setDate];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[ZEPointRegCache instance] clearUserOptions];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[ZEPointRegCache instance] cacheShareType:self.view];
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

#pragma mark - 缓存常用任务列表

-(void)cacheTaskData:(ZEPointRegistrationView *)pointRegView
{
    if ([[[ZEPointRegCache instance] getTaskCaches] count] > 0) {
        return;
    }

    NSDictionary * parametersDic = @{@"limit":@"100",
                                     @"MASTERTABLE":EPM_TEAM_RATION_COMMON,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":@"SYSCREATORID = '#PSNNUM#' and SUITUNIT='#SUITUNIT#'",
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
                                 [pointRegView showListView:arr withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_TASK];

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
                                     @"ORDERSQL":@"CATEGORYDISPLAYORDER,CATEGORYNAME,CATEGORYDISPLAYORDER2,RATIONNAME",
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
                                 [_pointView showTaskView:arr withConditionType:POINT_REG_TASK];
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

#pragma mark - 缓存工作条件系数

-(void)cacheWorkCondition
{
    if ([[[ZEPointRegCache instance] getWorkCondition] count] > 0) {
        return;
    }
    //第一条记录结束
    // 参数区域赋值
    
    NSDictionary * parametersDic = @{@"limit":@"2000",
                                     @"MASTERTABLE":V_EPM_TEAM_RATION_WORKPLACE,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"CATEGORYDISPLAYORDER,CATEGORYNAME,CATEGORYDISPLAYORDER2，WORKPLACE",
                                     @"WHERESQL":@"orgcode in (#TEAMORGCODES#) and suitunit='#SUITUNIT#'",
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[V_EPM_TEAM_RATION_WORKPLACE]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 NSArray * arr = [ZEUtil getServerData:data withTabelName:V_EPM_TEAM_RATION_WORKPLACE];
                                 [[ZEPointRegCache instance] setWorkCondition:arr];
                                 
                                 [_pointView showTaskView:arr withConditionType:POINT_REG_CONDITION];
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowAllTaskList object:nil];
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
                [self goBack];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiRefreshHistoryView object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiRefreshAuditView object:nil];
            }
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:str message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - ZEPointRegistrationViewDelegate

-(void)getTaskDetail:(NSString *)SEQKEY
{
    NSString * WHERESQL = [NSString stringWithFormat:@"SEQKEY=%@",SEQKEY];
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATION,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"WHERESQL":WHERESQL,
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":[NSString stringWithFormat:@"%@,%@",EPM_TEAM_RATION_DETAIL,EPM_TEAM_RATIONTYPEVALUE],
                                     @"MASTERFIELD":@"RATIONCODE,SUITUNIT",
                                     @"DETAILFIELD":@"RATIONCODE,SUITUNIT",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    NSDictionary * fieldsDic =@{};
    NSDictionary * fieldsDic1 =@{};
    NSDictionary * fieldsDic2 =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION,EPM_TEAM_RATION_DETAIL,EPM_TEAM_RATIONTYPEVALUE]
                                                                           withFields:@[fieldsDic,fieldsDic1,fieldsDic2]
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
                                 self.rationTypeValueArr = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPEVALUE];
                                 [_pointView reloadContentView:[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATION_DETAIL]
                                           withRationTypeValue:[ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPEVALUE]];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];

    [self dismissViewControllerAnimated:YES completion:^{
        [[ZEPointRegCache instance] clearUserOptions];
    }];
}

-(void)goSubmit:(ZEPointRegistrationView *)pointRegView
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
    
    if (_regType == ENTER_PERSON_POINTREG_TYPE_HISTORY) {
        [self updateMessageToServer];
    }else if (_regType == ENTER_PERSON_POINTREG_TYPE_AUDIT){
        [self updateAuditMessageToServer];
    }else{
        [self searchIsSummary];
    }
}

#pragma mark - 新增数据

-(void)searchIsSummary
{
    NSDictionary * choosedDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];
    NSString * dateStr = [choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DATE]];
    NSString * searchSQLDate = [[dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:6];
    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RESULT,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"",
                                     @"WHERESQL":[NSString stringWithFormat:@"periodcode='%@' and status not in ('2','3') and orgcode in (#TEAMORGCODES#) and suitunit='#SUITUNIT#' and rownum<=1",searchSQLDate],
                                     @"start":@"0",
                                     @"METHOD":@"search",
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     @"DETAILTABLE":@"",};
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RESULT]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ZEUserServer getDataWithJsonDic:packageDic
                       showAlertView:YES
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 NSDictionary * dic  = [ZEUtil getServerDic:data withTabelName:EPM_TEAM_RESULT];
                                 if ([[dic objectForKey:@"totalCount"] integerValue] > 0) {
                                     [self showAlertView:@"数据已汇总，不能保存" goBack:NO];
                                 }else{
                                     [self submitMessageToServer];
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}


-(void)submitMessageToServer
{
    NSDictionary * parametersDic =@{
                                    @"MENUAPP":@"EMARK_APP",
                                    @"ORDERSQL":@"",
                                    @"WHERESQL":@"",
                                    @"METHOD":@"addSave",
                                    @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                    @"DETAILTABLE":[NSString stringWithFormat:@"%@,%@",EPM_TEAM_RATION_REG_DETAIL,EPM_TEAM_RATION_REG_SX],
                                    @"MASTERFIELD":@"SEQKEY",
                                    @"DETAILFIELD":@"TASKID",
                                    @"self":@"self",
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
                                                                                        @"ADDMODE":kCOMMONPOINTREG,
                                                                                        @"WORKEXPLREG":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKEXPLREG"],
                                                                                        @"WORKPLACE":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKPLACE"],
                                                                                        @"WORKPLACECODE":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKPLACECODE"],
                                                                                        @"WORKPLACEQUOTIETY":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKPLACEQUOTIETY"],
                                                                                        @"STATUS": @"10"}];
    
    NSDictionary * conditionDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_CONDITION]];
    if ([ZEUtil isNotNull:conditionDic]) {
        [defaultDic setObject:[conditionDic objectForKey:@"WORKPLACE"] forKey:@"WORKPLACE"];
    }else{
        [defaultDic setObject:@""forKey:@"WORKPLACE"];
    }

    
    for (NSInteger i = 0 ; i < _pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys.count ; i++) {
        NSString * keyStr = _pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i];
    
        if ([keyStr rangeOfString:@"QUOTIETY"].location != NSNotFound && [keyStr rangeOfString:@"CODE"].location == NSNotFound) {
            [defaultDic setObject:[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:_pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]] forKey:_pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]];
        }
    }
    
    
    NSMutableArray * personalArr = [NSMutableArray array];
    NSMutableArray * tableNameArr = [NSMutableArray arrayWithObject:EPM_TEAM_RATION_REG];

    for (NSInteger i = 0; i < _pointView.USERCHOOSEDWORKERVALUEARR.count; i ++) {
        [tableNameArr addObject:EPM_TEAM_RATION_REG_DETAIL];
        
        NSMutableDictionary * personalDic =  [NSMutableDictionary dictionaryWithDictionary: _pointView.USERCHOOSEDWORKERVALUEARR[i]];
        [personalDic removeObjectForKey:@"QSPOINTS"];
        [personalArr setValue:@"10" forKey:@"STATUS"];
        for (NSInteger j = 0 ; j < personalDic.allKeys.count ; j++) {
            NSString * keyStr = personalDic.allKeys[j];
            if ([keyStr rangeOfString:@"QUOTIETY"].location != NSNotFound && [keyStr rangeOfString:@"CODE"].location != NSNotFound) {
                [personalDic removeObjectForKey:personalDic.allKeys[j]];
            }
        }

        [personalArr addObject:personalDic];
    }
    
    for (int i = 0; i < _pointView.recordLengthArr.count; i ++) {
        [tableNameArr addObject:EPM_TEAM_RATION_REG_SX];
        
        ZEEPM_TEAM_RATION_REGModel * recordLengthM = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:_pointView.recordLengthArr[i]];
        
        NSMutableDictionary * personalDic =  [NSMutableDictionary dictionary];
        [personalDic setObject:recordLengthM.WORKINGPROCEDURE forKey:@"WORKINGPROCEDURE"];
        [personalDic setObject:recordLengthM.STANDARDOPERATIONTIME forKey:@"STANDARDOPERATIONTIME"];
        [personalArr addObject:personalDic];
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
                                 [self showAlertView:@"提交成功" goBack:NO];
                                 [_pointView submitSuccessReloadContentView];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

#pragma mark - 更新数据
-(void)updateMessageToServer
{
    NSDictionary * parametersDic =@{@"MENUAPP":@"EMARK_APP",
                                    @"ORDERSQL":@"",
                                    @"WHERESQL":@"",
                                    @"METHOD":@"updateSave",
                                    @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                    @"DETAILTABLE":[NSString stringWithFormat:@"%@,%@",EPM_TEAM_RATION_REG_DETAIL,EPM_TEAM_RATION_REG_SX],
                                    @"MASTERFIELD":@"SEQKEY",
                                    @"DETAILFIELD":@"TASKID",
                                    @"self":@"self",
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
                                                                                        @"ADDMODE":kCOMMONPOINTREG,
                                                                                        @"WORKEXPLREG":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKEXPLREG"],
                                                                                        @"WORKPLACE":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKPLACE"],
                                                                                        @"WORKPLACECODE":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKPLACECODE"],
                                                                                        @"WORKPLACEQUOTIETY":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKPLACEQUOTIETY"],
                                                                                        @"STATUS": [choosedTaskDic objectForKey:@"STATUS"],
                                                                                        @"SEQKEY":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"SEQKEY"]}];
    NSDictionary * conditionDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_CONDITION]];
    if ([ZEUtil isNotNull:conditionDic]) {
        [defaultDic setObject:[conditionDic objectForKey:@"WORKPLACE"] forKey:@"WORKPLACE"];
    }else{
        [defaultDic setObject:@""forKey:@"WORKPLACE"];
    }

    for (NSInteger i = 0 ; i < _pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys.count ; i++) {
        NSString * keyStr = _pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i];
        
        if ([keyStr rangeOfString:@"QUOTIETY"].location != NSNotFound && [keyStr rangeOfString:@"CODE"].location == NSNotFound) {
            [defaultDic setObject:[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:_pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]] forKey:_pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]];
        }
    }
    
    NSMutableArray * personalArr = [NSMutableArray array];
    NSMutableArray * tableNameArr = [NSMutableArray arrayWithObject:EPM_TEAM_RATION_REG];
    
    for (NSInteger i = 0; i < _pointView.USERCHOOSEDWORKERVALUEARR.count; i ++) {
        [tableNameArr addObject:EPM_TEAM_RATION_REG_DETAIL];
        
        NSDictionary * dic = _pointView.USERCHOOSEDWORKERVALUEARR[i];
        NSMutableDictionary * personalDic =  [NSMutableDictionary dictionaryWithDictionary: @{@"STATUS":[dic objectForKey:@"STATUS"],
                                                                                              @"SEQKEY":[dic objectForKey:@"SEQKEY"],
                                                                                              @"WORKPOINTS":[dic objectForKey:@"WORKPOINTS"],
                                                                                              @"TASKID":@"",
                                                                                              @"SUMPOINTS":[dic objectForKey:@"SUMPOINTS"],
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
    
    for (int i = 0; i < _pointView.recordLengthArr.count; i ++) {
        [tableNameArr addObject:EPM_TEAM_RATION_REG_SX];
        
        ZEEPM_TEAM_RATION_REGModel * recordLengthM = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:_pointView.recordLengthArr[i]];
        
        NSMutableDictionary * personalDic =  [NSMutableDictionary dictionary];
        [personalDic setObject:recordLengthM.WORKINGPROCEDURE forKey:@"WORKINGPROCEDURE"];
        [personalDic setObject:recordLengthM.STANDARDOPERATIONTIME forKey:@"STANDARDOPERATIONTIME"];
        [personalArr addObject:personalDic];
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
                                 [self showAlertView:@"提交成功" goBack:YES];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

#pragma mark - 新增数据
-(void)updateAuditMessageToServer
{
    NSDictionary * parametersDic =@{
                                    @"MENUAPP":@"EMARK_APP",
                                    @"ORDERSQL":@"",
                                    @"WHERESQL":@"",
                                    @"METHOD":@"updateSave",
                                    @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                    @"DETAILTABLE":EPM_TEAM_RATION_REG_DETAIL,
                                    @"MASTERFIELD":@"SEQKEY",
                                    @"DETAILFIELD":@"TASKID",
                                    @"self":@"self",
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
                                                                                        @"ADDMODE":kCOMMONPOINTREG,
                                                                                        @"WORKEXPLREG":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKEXPLREG"],
                                                                                        @"WORKPLACE":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKPLACE"],
                                                                                        @"WORKPLACECODE":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKPLACECODE"],
                                                                                        @"WORKPLACEQUOTIETY":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"WORKPLACEQUOTIETY"],
                                                                                        @"STATUS": @"8",
                                                                                        @"SEQKEY":[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:@"SEQKEY"]}];
    NSDictionary * conditionDic = [[[ZEPointRegCache instance] getUserChoosedOptionDic] objectForKey:[ZEUtil getPointRegField:POINT_REG_CONDITION]];
    if ([ZEUtil isNotNull:conditionDic]) {
        [defaultDic setObject:[conditionDic objectForKey:@"WORKPLACE"] forKey:@"WORKPLACE"];
    }else{
        [defaultDic setObject:@""forKey:@"WORKPLACE"];
    }
    
    for (NSInteger i = 0 ; i < _pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys.count ; i++) {
        NSString * keyStr = _pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i];
        
        if ([keyStr rangeOfString:@"QUOTIETY"].location != NSNotFound && [keyStr rangeOfString:@"CODE"].location == NSNotFound) {
            [defaultDic setObject:[_pointView.CHOOSEDRATIONTYPEVALUEDic objectForKey:_pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]] forKey:_pointView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]];
        }
    }
    
    NSMutableArray * personalArr = [NSMutableArray array];
    NSMutableArray * tableNameArr = [NSMutableArray arrayWithObject:EPM_TEAM_RATION_REG];
    
    for (NSInteger i = 0; i < _pointView.USERCHOOSEDWORKERVALUEARR.count; i ++) {
        [tableNameArr addObject:EPM_TEAM_RATION_REG_DETAIL];
        
        NSDictionary * dic = _pointView.USERCHOOSEDWORKERVALUEARR[i];
        NSMutableDictionary * personalDic =  [NSMutableDictionary dictionaryWithDictionary: @{@"STATUS":@"8",
                                                                                              @"SEQKEY":[dic objectForKey:@"SEQKEY"],
                                                                                              @"WORKPOINTS":[dic objectForKey:@"WORKPOINTS"],
                                                                                              @"TASKID":@"",
                                                                                              @"SUMPOINTS":[dic objectForKey:@"SUMPOINTS"],
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
    
    for (int i = 0; i < _pointView.recordLengthArr.count; i ++) {
        [tableNameArr addObject:EPM_TEAM_RATION_REG_SX];
        
        ZEEPM_TEAM_RATION_REGModel * recordLengthM = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:_pointView.recordLengthArr[i]];
        
        NSMutableDictionary * personalDic =  [NSMutableDictionary dictionary];
        [personalDic setObject:recordLengthM.WORKINGPROCEDURE forKey:@"WORKINGPROCEDURE"];
        [personalDic setObject:recordLengthM.STANDARDOPERATIONTIME forKey:@"STANDARDOPERATIONTIME"];
        [personalArr addObject:personalDic];
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
                                 [self showAlertView:@"提交成功" goBack:YES];
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

-(void)resubmitPointReg:(NSDictionary *)dic
{
    NSString* date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    date = [formatter stringFromDate:[NSDate date]];
}


-(void)view:(ZEPointRegistrationView *)pointRegView didSelectRowAtIndexpath:(NSIndexPath *)indexpath
{
    switch (indexpath.row) {
        case 0:
            [self showTaskView:pointRegView];
            break;
        case 1:
            [self showChooseDateView:pointRegView];
            break;
        case 2:
            [self showWorkConditionView];
            break;
        default:
            break;
    }
}

-(void)showRATIONTYPEVALUE:(NSString *)QUOTIETYCODE
{    
    NSDictionary * valueDic = [[ZEPointRegCache instance] getRATIONTYPEVALUE];
    NSMutableArray * valueArr = [NSMutableArray arrayWithArray:[valueDic objectForKey:QUOTIETYCODE]];

    if (self.rationTypeValueArr.count > 0) {
        valueArr = [NSMutableArray array];
        for (NSDictionary * dic in self.rationTypeValueArr) {
            ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:dic];
            if ([detailM.FIELDNAME isEqualToString:QUOTIETYCODE]) {
                [valueArr addObject:dic];
            }
        }
        if (valueArr.count == 0) {
            valueArr = [NSMutableArray arrayWithArray:[valueDic objectForKey:QUOTIETYCODE]];
        }
    }
    [_pointView showListView:valueArr withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_CONDITION];
}
#pragma mark - 工作任务

-(void)showTaskView:(ZEPointRegistrationView *)pointRegView
{
    NSArray * taskCacheArr = nil;
    taskCacheArr = [[ZEPointRegCache instance] getTaskCaches];
    
    if (taskCacheArr.count > 0) {
        [pointRegView showListView:taskCacheArr withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_TASK];
    }else{
        [self cacheTaskData:pointRegView];
    }
}

-(void)showAllTaskView
{
    NSArray * allTaskCacheArr = nil;
    allTaskCacheArr = [[ZEPointRegCache instance] getAllTaskCaches];
    
    if (allTaskCacheArr.count > 0) {
        [_pointView showTaskView:allTaskCacheArr withConditionType:POINT_REG_TASK];
    }else{
        [self cacheAllTaskData];
    }
}

#pragma mark - 工作对象
-(void)showWorkConditionView
{
    NSArray * workConditionArr = nil;
    workConditionArr = [[ZEPointRegCache instance] getWorkCondition];
    
    if (workConditionArr.count > 0) {
        [_pointView showTaskView:workConditionArr withConditionType:POINT_REG_CONDITION];
    }else{
        [self cacheWorkCondition];
    }

}

#pragma mark - 发生日期
-(void)showChooseDateView:(ZEPointRegistrationView *)pointRegView
{
    [pointRegView showDateView];
}
#pragma mark - 发生日期
-(void)showChooseCountView:(ZEPointRegistrationView *)pointRegView
{
    [pointRegView showCountView];
}


#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
