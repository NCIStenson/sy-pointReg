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
    self.rightBtn.backgroundColor = [UIColor clearColor];
    [self.rightBtn setImage:[UIImage imageNamed:@"icon_tick.png" color:[UIColor whiteColor]] forState:UIControlStateNormal];
    self.rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    
    _leaderRegView = [[ZELeaderRegView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT)];
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
    
    [[ZEPointRegCache instance]setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_DATE]:dateStr}];
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
    NSString * valueStr = [NSString stringWithFormat:@"QUOTIETY%ldCODE",number];
    NSString * WHERESQL = [NSString stringWithFormat:@"suitunit = '#SUITUNIT#' and FIELDNAME = 'QUOTIETY%ldCODE' and secorgcode in (select case (select count(1) from EPM_TEAM_RATIONTYPEVALUE t where t.suitunit = '#SUITUNIT#' and FIELDNAME = 'QUOTIETY%ldCODE' and secorgcode = '#SECORGCODE#') when 0 then '-1' else '#SECORGCODE#' end from dual)",number,number];
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
    [_leaderRegView endEditing:YES];
//    NSLog(@" 班组长登记工分内容 >>>  %@",_leaderRegView.CHOOSEDRATIONTYPEVALUEDic);
//    NSLog(@" 班组长登记工分员工内容 >>>  %@",_leaderRegView.USERCHOOSEDWORKERVALUEARR);
    
    NSDictionary * userChoosedDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];
    NSString * dateStr = [userChoosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_DATE]];
    
    NSDictionary * taskDic = [userChoosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    
    ZEEPM_TEAM_RATION_COMMON * taskDetailM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:taskDic];
    
    NSArray * cacheDisType = [[[ZEPointRegCache instance] getDistributionTypeCoefficient] objectForKey:taskDetailM.RATIONTYPE];
    
    NSDictionary * parametersDic =@{@"limit":@"20",
                                    @"MASTERTABLE":EPM_TEAM_RATION_REG,
                                    @"MENUAPP":@"EMARK_APP",
                                    @"ORDERSQL":@"",
                                    @"WHERESQL":@"",
                                    @"start":@"0",
                                    @"METHOD":@"addSave",
                                    @"DETAILTABLE":@"EPM_TEAM_RATION_REG_DETAIL",
                                    @"MASTERFIELD":@"SEQKEY",
                                    @"DETAILFIELD":@"TASKID",
                                    @"self":@"self",
                                    @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                    };
    
    
    
    NSMutableDictionary * fieldsDic = [NSMutableDictionary dictionaryWithDictionary: @{@"ENDDATE":dateStr,
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
                                                                                       @"STATUS":@""}];

    
    for (int i = 0 ; i < _leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys.count; i ++) {
        id object = [_leaderRegView.CHOOSEDRATIONTYPEVALUEDic objectForKey:_leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i]];
        if ([object isKindOfClass:[NSDictionary class]]) {
            [fieldsDic setObject:[object objectForKey:@"QUOTIETY"] forKey:[_leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
        }else{
            [fieldsDic setObject:object forKey:[_leaderRegView.CHOOSEDRATIONTYPEVALUEDic.allKeys[i] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
        }
    }
    
    NSLog(@"fieldsDic >>  %@",fieldsDic);
    
    for (int i = 0 ; i < _leaderRegView.USERCHOOSEDWORKERVALUEARR.count; i ++) {
        NSMutableDictionary * defaultDic = [NSMutableDictionary dictionaryWithDictionary:_leaderRegView.USERCHOOSEDWORKERVALUEARR[i]];
        for (int j = 0 ; j < defaultDic.allKeys.count; j ++) {
            id object = [defaultDic objectForKey:defaultDic.allKeys[j]];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [defaultDic setObject:[object objectForKey:@"QUOTIETY"] forKey:[defaultDic.allKeys[j] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
            }else{
                [defaultDic setObject:object forKey:[defaultDic.allKeys[j] stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
            }
        }
        [_leaderRegView.USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:i withObject:defaultDic];
    }
    
    
    [[ZECalculateTotalPoint instance] getTotalPointTaskDic:fieldsDic withPersonalDetailArr:_leaderRegView.USERCHOOSEDWORKERVALUEARR];

    NSLog(@">>>>>>>>>   %@",[[ZECalculateTotalPoint instance] getResultDic]);
//    for (NSDictionary * typeDic in cacheDisType) {
//        ZEEPM_TEAM_RATIONTYPEDETAIL * rationTypeDetailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:typeDic];
//        if ([rationTypeDetailM.ISRATION boolValue]) {
//            id object = [_leaderRegView.CHOOSEDRATIONTYPEVALUEDic objectForKey:rationTypeDetailM.FIELDNAME];
//            if ([object isKindOfClass:[NSDictionary class]]) {
//                [fieldsDic setObject:[object objectForKey:@"QUOTIETY"] forKey:[rationTypeDetailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
//            }else{
//                [fieldsDic setObject:object forKey:[rationTypeDetailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
//            }
//        }else{
//            id object = [dic objectForKey:rationTypeDetailM.FIELDNAME];
//            if ([object isKindOfClass:[NSDictionary class]]) {
//                [detailFieldsDic setObject:[object objectForKey:@"QUOTIETY"] forKey:[rationTypeDetailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
//            }else{
//                [detailFieldsDic setObject:object forKey:[rationTypeDetailM.FIELDNAME stringByReplacingOccurrencesOfString:@"CODE" withString:@""]];
//            }
//        }
//    }
//    
//    
//    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RATION_REG,EPM_TEAM_RATION_REG_DETAIL]
//                                                                           withFields:@[fieldsDic,detailFieldsDic]
//                                                                       withPARAMETERS:parametersDic
//                                                                       withActionFlag:nil];
//    
//    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [ZEUserServer getDataWithJsonDic:packageDic
//                             success:^(id data) {
//                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
//                                 NSLog(@"============================================================================================================================================== %@",data);
//                                 
//                             } fail:^(NSError *errorCode) {
//                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
//                             }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowAllTaskList object:nil];
}

@end
