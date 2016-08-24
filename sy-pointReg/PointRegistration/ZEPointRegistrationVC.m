//
//  ZEPointRegistrationVC.m
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#import "ZEPointRegistrationVC.h"
#import "ZEPointRegistrationView.h"
#import "ZEPointRegCache.h"
#import "MBProgressHUD.h"
#import "ZEUserServer.h"

#import "ZEEPM_TEAM_RATIONTYPE.h"

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
    
    _pointView = [[ZEPointRegistrationView alloc]initWithFrame:self.view.frame];
    _pointView.delegate = self;
    _pointView.historyModel = _hisModel;
    [self.view addSubview:_pointView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAllTaskView) name:kShowAllTaskList object:nil];
    
    [self cacheShareType];
}
#pragma mark - 缓存分摊类型

-(void)cacheShareType
{
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
                                 NSLog(@"data>>>  %@",data);
                                 NSArray * arr = [ZEUtil getServerData:data withTabelName:EPM_TEAM_RATIONTYPEDETAIL];
                                 if (arr.count > 0) {
                                     [[ZEPointRegCache instance] setDistributionTypeCoefficient:@{rationCode:arr}];
                                 }
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

#pragma mark - 缓存常用任务列表

-(void)cacheTaskData:(ZEPointRegistrationView *)pointRegView
{
    if ([[[ZEPointRegCache instance] getTaskCaches] count] > 0) {
        return;
    }

    NSDictionary * parametersDic = @{@"limit":@"20",
                                     @"MASTERTABLE":EPM_TEAM_RATION_COMMON,
                                     @"MENUAPP":@"EMARK_APP",
                                     @"ORDERSQL":@"DISPLAYORDER",
                                     @"WHERESQL":@"SYSCREATORID = '#PSNNUM#' and suitunit='#SUITUNIT#'",
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
    
    NSDictionary * parametersDic = @{@"limit":@"20",
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
                                 [_pointView showTaskView:arr];
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowAllTaskList object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
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
//                                     @"ORDERSQL":@"DISPLAYORDER",
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
                                 [_pointView reloadContentView];
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

-(void)goSubmit:(ZEPointRegistrationView *)pointRegView withShowRoles:(BOOL)showRoles withShowCount:(BOOL)showCount
{
        NSDictionary * choosedDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];

//        if(![ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]]]){
//            [self showAlertView:[NSString stringWithFormat:@"请选择%@",[ZEUtil getPointRegInformation:POINT_REG_TASK]] goBack:NO];
//            return;
//        }
        
        NSString* date;
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        date = [formatter stringFromDate:[NSDate date]];
        
//        if([ZEUtil compareDate:date
//                      withDate:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME]]] == 1){
//            [self showAlertView:[NSString stringWithFormat:@"发生日期不能大于今天"] goBack:NO];
//            return;
//        }
//
//        if(showRoles && ![ZEUtil isNotNull:[choosedDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]]]){
//            [self showAlertView:[NSString stringWithFormat:@"请选择%@",[ZEUtil getPointRegInformation:POINT_REG_JOB_ROLES]] goBack:NO];
//            return;
//        }
        
        [self submitMessageToServer:choosedDic withView:pointRegView];
}
-(void)resubmitPointReg:(NSDictionary *)dic
{
    NSString* date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    date = [formatter stringFromDate:[NSDate date]];
    
//    if([ZEUtil compareDate:date
//                  withDate:[dic objectForKey:[ZEUtil getPointRegField:POINT_REG_TIME]]] == 1){
//        [self showAlertView:[NSString stringWithFormat:@"发生日期不能大于今天"] goBack:NO];
//        return;
//    }
    
//    if([[dic objectForKey:@"shareType"] integerValue] == 1 || [[dic objectForKey:@"shareType"] integerValue] == 4){
//        NSObject * roleDic = [dic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_ROLES]];
//        if ([roleDic isKindOfClass:[NSDictionary class]]) {
//            if (![ZEUtil isStrNotEmpty:[(NSDictionary *)roleDic objectForKey:@"TWR_NAME"]]){
//                [self showAlertView:@"请选择角色" goBack:NO];
//                return;
//            }
//        }else if (![ZEUtil isStrNotEmpty:(NSString *)roleDic]){
//            [self showAlertView:@"请选择角色" goBack:NO];
//            return;
//        }
//    }
    
    [_pointView showProgress];
//    [ZEUserServer updateTask:dic success:^(id data) {
//        [_pointView hiddenProgress];
//        if ([ZEUtil isNotNull:data]) {
//            if ([[data objectForKey:@"data"] integerValue] == 1) {
//                [[ZEPointRegCache instance] clearResubmitCaches];
//                [self showAlertView:@"提交成功" goBack:YES];
//            }
//        }
//    }
//                        fail:^(NSError *errorCode) {
//
//                            [_pointView hiddenProgress];
//                        }];
}

-(void)submitMessageToServer:(NSDictionary *)dic withView:(ZEPointRegistrationView *)pointRegView
{
//    NSMutableDictionary * dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
//
//    if(![ZEUtil isNotNull:[dataDic objectForKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]]]){
//        [dataDic setValue:@"1" forKey:[ZEUtil getPointRegField:POINT_REG_JOB_COUNT]];
//    }
    
//    [dataDic setValue:[ZESetLocalData getNumber] forKey:@"userid"];
//    [dataDic setValue:[ZESetLocalData getUsername] forKey:@"username"];
//    [dataDic setValue:[ZESetLocalData getOrgcode] forKey:@"userOrgcode"];
//    [dataDic setValue:[ZESetLocalData getUnitcode] forKey:@"userUnitcode"];
//    [dataDic setValue:[ZESetLocalData getOrgcode] forKey:@"userOrgCodeName"];
//    [dataDic setValue:[ZESetLocalData getUnitName] forKey:@"userUintName"];
//    [_pointView showProgress];
//    [ZEUserServer submitPointRegMessage:dataDic Success:^(id data) {
//        [_pointView hiddenProgress];
//        if ([ZEUtil isNotNull:data]) {
//            if ([[data objectForKey:@"data"] integerValue] == 1) {
//                if (_enterType == ENTER_POINTREG_TYPE_DEFAULT){
//                    [self showAlertView:@"提交成功" goBack:NO];
//                    [[ZEPointRegCache instance] clearUserOptions];
//                    [pointRegView reloadContentView:ENTER_POINTREG_TYPE_DEFAULT];
//                }else{
//                    [self showAlertView:@"提交成功" goBack:YES];
//                }
//            }else{
//                [self showAlertView:@"提交失败" goBack:NO];
//            }
//        }
//    }
//                                   fail:^(NSError *errorCode) {
//                                       [self showAlertView:@"提交失败" goBack:NO];
//                                       [_pointView hiddenProgress];
//                                   }];
    
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
        case 3:
            [self showTypeView:pointRegView];
            break;
        case 4:
            [self showDiffCoeView:pointRegView];
            break;
        case 5:
            [self showTimeCoeView:pointRegView];
            break;
        case POINT_REG_JOB_ROLES:
        {

        }
            break;
        default:
            break;
    }
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
        [_pointView showTaskView:allTaskCacheArr];
    }else{
        [self cacheAllTaskData];
    }
}

#pragma mark - 难度系数
-(void)showDiffCoeView:(ZEPointRegistrationView *)pointRegView
{
//    NSArray * diffCoeCacheArr = nil;
//    diffCoeCacheArr = [[ZEPointRegCache instance] getDiffCoeCaches];
//    
//    if (diffCoeCacheArr.count > 0) {
////        [pointRegView showListView:diffCoeCacheArr withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_DIFF_DEGREE];
//    }else{
//        [MBProgressHUD showHUDAddedTo:pointRegView animated:YES];
////        [ZEUserServer getDiffCoeSuccess:^(id data) {
////            [MBProgressHUD hideAllHUDsForView:pointRegView animated:YES];
////            if ([ZEUtil isNotNull:[data objectForKey:@"data"]]) {
////                [[ZEPointRegCache instance] setDiffCoeCaches:[data objectForKey:@"data"]];
////                [pointRegView showListView:[data objectForKey:@"data"] withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_DIFF_DEGREE];
////            }
////        } fail:^(NSError *errorCode) {
////            [MBProgressHUD hideAllHUDsForView:pointRegView animated:YES];
////            
////        }];
//    }
    
}

-(void)showTimeCoeView:(ZEPointRegistrationView *)pointRegView
{
    NSArray * timeCoeCacheArr = nil;
    timeCoeCacheArr = [[ZEPointRegCache instance] getTimesCoeCaches];
    
    if (timeCoeCacheArr.count > 0) {
//        [pointRegView showListView:timeCoeCacheArr withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_TIME_DEGREE];
    }else{
        [MBProgressHUD showHUDAddedTo:pointRegView animated:YES];
//        [ZEUserServer getTimeCoeSuccess:^(id data) {
//            [MBProgressHUD hideAllHUDsForView:pointRegView animated:YES];
//            if ([ZEUtil isNotNull:[data objectForKey:@"data"]]) {
//                [[ZEPointRegCache instance] setTimesCoeCaches:[data objectForKey:@"data"]];
//                [pointRegView showListView:[data objectForKey:@"data"] withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_DIFF_DEGREE];
//            }
//        } fail:^(NSError *errorCode) {
//            [MBProgressHUD hideAllHUDsForView:pointRegView animated:YES];
//            
//        }];
    }
    
}
-(void)showWorkRolesView:(ZEPointRegistrationView *)pointRegView
{
    NSArray * workRolesArr = nil;
    workRolesArr = [[ZEPointRegCache instance] getWorkRulesCaches];
    if (workRolesArr.count > 0) {
        [pointRegView showListView:workRolesArr withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_JOB_ROLES];
    }else{
        [MBProgressHUD showHUDAddedTo:pointRegView animated:YES];
//        [ZEUserServer getWorkRolesSuccess:^(id data) {
//            [MBProgressHUD hideAllHUDsForView:pointRegView animated:YES];
//            if ([ZEUtil isNotNull:[data objectForKey:@"data"]]) {
//                [[ZEPointRegCache instance] setWorkRulesCaches:[data objectForKey:@"data"]];
//                [pointRegView showListView:[data objectForKey:@"data"] withLevel:TASK_LIST_LEVEL_JSON withPointReg:POINT_REG_JOB_ROLES];
//            }
//        } fail:^(NSError *errorCode) {
//            [MBProgressHUD hideAllHUDsForView:pointRegView animated:YES];
//            
//        }];
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

#pragma mark - 分摊类型

-(void)showTypeView:(ZEPointRegistrationView *)pointRegView
{
    [pointRegView showListView:@[@"按系数分配",@"按人头均摊",@"按次分配",@"按工分*系数分配"] withLevel:TASK_LIST_LEVEL_NOJSON withPointReg:POINT_REG_TYPE];
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
