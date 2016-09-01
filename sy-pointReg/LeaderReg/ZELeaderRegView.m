//
//  ZELeaderRegView.m
//  sy-pointReg
//
//  Created by Stenson on 16/8/26.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#define kContentViewMarginTop   64.0f
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - NAV_HEIGHT)

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

@interface ZELeaderRegView ()<UITextFieldDelegate,ZEPointRegOptionViewDelegate,ZEPointChooseTaskViewDelegate,UITableViewDelegate,UITableViewDataSource,ZEPointRegChooseDateViewDelegate,ZEChooseWorkerViewDelegate>
{
    UITableView * _contentTableView;
    JCAlertView * _alertView;
    
    NSIndexPath * _currentSelectIndexPath;
}

@property (nonatomic,strong) NSMutableDictionary * defaultRATIONVALUEDIC; // 保存默认系数选项数值

@property (nonatomic,strong) NSMutableArray * commmonRationTypeValueArr;  // 跟随任务的选项系数
@property (nonatomic,strong) NSMutableArray * personalRationTypeValueArr; // 跟随人员的选项系数

@property (nonatomic,strong) NSArray * choosedWorkerArr;

@end

@implementation ZELeaderRegView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.USERCHOOSEDWORKERVALUEARR = [NSMutableArray array];
        self.CHOOSEDRATIONTYPEVALUEDic = [NSMutableDictionary dictionary];
        
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
}
#pragma mark - PublicMethod

-(void)reloadContentView
{
    [self isFollowTask];
    self.USERCHOOSEDWORKERVALUEARR = [NSMutableArray array];
    [self setWorkerDefaultData];
    
    [_contentTableView reloadData];
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
    
    ZEEPM_TEAM_RATION_COMMON * taskM = [ZEEPM_TEAM_RATION_COMMON getDetailWithDic:choosedTaskDic];
    NSArray * choosedCacheDisType = [[[ZEPointRegCache instance] getDistributionTypeCoefficient] objectForKey:taskM.RATIONTYPE];
    
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
    
    for (NSDictionary * dic in _choosedWorkerArr) {
        self.defaultRATIONVALUEDIC = [NSMutableDictionary dictionaryWithDictionary:dic];
        
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
                            [self.defaultRATIONVALUEDIC setValuesForKeysWithDictionary:dic];
                        }
                    }
                }
            }else{
                NSDictionary * dic = @{detailM.FIELDNAME:@"1"};
                [self.defaultRATIONVALUEDIC setValuesForKeysWithDictionary:dic];
            }
        }
        [self.defaultRATIONVALUEDIC setValue:@"DESR" forKey:@"DESCR"];
        [self.defaultRATIONVALUEDIC setValue:@"0" forKey:@"WORKPOINTS"];
        [self.defaultRATIONVALUEDIC setValue:@"0" forKey:@"SUMPOINTS"];
        
        [self.USERCHOOSEDWORKERVALUEARR addObject:self.defaultRATIONVALUEDIC];
    }
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

-(void)showWorkerListView:(NSArray *)arr
{
    ZEChooseWorkerView * chooseTaskView = [[ZEChooseWorkerView alloc]initWithOptionArr:arr];
    chooseTaskView.delegate = self;
    _alertView = [[JCAlertView alloc]initWithCustomView:chooseTaskView dismissWhenTouchedBackground:YES];
    [_alertView show];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _choosedWorkerArr.count + 1;
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
    UIView * BGView = [[UIView alloc]init];

    BGView.backgroundColor = RGBA(0, 84, 74, 0.5);
    
    UILabel * choosedWorkerLab = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, 0, SCREEN_WIDTH / 3, 44.0f)];
    choosedWorkerLab.text = @"工作人员";
    [BGView addSubview:choosedWorkerLab];
    
    NSDictionary * dic = _choosedWorkerArr[section - 1];
    
    UILabel * workerNameLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 3 * 2 - 15.0f, 0, SCREEN_WIDTH / 3, 44.0f)];
    workerNameLab.text = [dic objectForKey:@"PSNNAME"];
    workerNameLab.textColor = [UIColor blackColor];
    workerNameLab.textAlignment = NSTextAlignmentRight;
    workerNameLab.font = [UIFont boldSystemFontOfSize:17];
    [BGView addSubview:workerNameLab];
    
    return BGView;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5 + self.commmonRationTypeValueArr.count;
    }
    return self.personalRationTypeValueArr.count + 2;
}
-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = [NSString stringWithFormat:@"%ld%ld",indexPath.section,(long)indexPath.row];
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
        if (indexPath.row ==  self.personalRationTypeValueArr.count) {
            cell.textLabel.text = @"个人说明";
            
            UITextField * field = [[UITextField alloc]initWithFrame:CGRectMake(90.0f, 0, SCREEN_WIDTH - 105.0f, 44.0f)];
            field.delegate = self;
            field.placeholder = @"工时登记情况";
            field.font = [UIFont systemFontOfSize:14.0f];
            field.textAlignment = NSTextAlignmentRight;
            field.textColor = MAIN_COLOR;
            [cell.contentView addSubview:field];
            field.tag = indexPath.section * 1000;

            if ([ZEUtil isStrNotEmpty:[dic objectForKey:@"DESCR"]]) {
                field.text = [dic objectForKey:@"DESCR"];
            }
            
            
        }else if (indexPath.row ==  self.personalRationTypeValueArr.count + 1){
            cell.textLabel.text = @"工时得分";
            cell.detailTextLabel.text = @"0分";
            if ([[dic objectForKey:@"WORKPOINTS"] integerValue] >0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@分",[dic objectForKey:@"WORKPOINTS"]];
            }

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
            UITextField * field = [[UITextField alloc]initWithFrame:CGRectMake(90.0f, 0, SCREEN_WIDTH - 105.0f, 44.0f)];
            field.delegate = self;
            field.keyboardType = UIKeyboardTypeDecimalPad;
            field.font = [UIFont systemFontOfSize:14.0f];
            field.textAlignment = NSTextAlignmentRight;
            field.textColor = MAIN_COLOR;
            field.tag = indexPath.section * 100 + indexPath.row;
            [cell.contentView addSubview:field];
            
            field.text = [dic objectForKey:detailM.FIELDNAME];
        }
    }
}

#pragma mark - 多人登记共同项

-(void)setListDetailText:(NSInteger)row cell:(UITableViewCell *)cell
{
    NSDictionary * choosedOptionDic = [[ZEPointRegCache instance] getUserChoosedOptionDic];
    NSDictionary * choosedTaskDic = [choosedOptionDic objectForKey:[ZEUtil getPointRegField:POINT_REG_TASK]];
    
//    NSDictionary * dic = _USERCHOOSEDWORKERVALUEARR[];

    if (row == self.commmonRationTypeValueArr.count + 4) {
        UILabel * addWorkerLab     = [UILabel new];
        addWorkerLab.font          = [UIFont systemFontOfSize:14];
        addWorkerLab.frame         = CGRectMake(0, 0, SCREEN_WIDTH, 44.0f);
        addWorkerLab.text          = @"添加作人员";
        addWorkerLab.textAlignment = NSTextAlignmentCenter;
        addWorkerLab.textColor     = MAIN_COLOR;
        [cell.contentView addSubview:addWorkerLab];
    }else if (row < 4){
        cell.detailTextLabel.textColor = MAIN_COLOR;
        cell.textLabel.text = [ZEUtil getPointRegInformation:row];
        cell.detailTextLabel.text = @"请选择";
    }else if (row < self.commmonRationTypeValueArr.count + 4){
        
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
            
            field.text = [self.CHOOSEDRATIONTYPEVALUEDic objectForKey:detailM.FIELDNAME];
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

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEditing:YES];
    _currentSelectIndexPath = indexPath;
    
    if(indexPath.section == 0){
        if (indexPath.row < 4) {
            if (indexPath.row == 3) {
                return;
            }
            if ([self.delegate respondsToSelector:@selector(didSelectRowAtIndexpath:)]) {
                [self.delegate didSelectRowAtIndexpath:indexPath];
            }
        }else if (indexPath.row == self.commmonRationTypeValueArr.count + 4){
            if ([self.delegate respondsToSelector:@selector(showWorkerListView)]) {
                [self.delegate showWorkerListView];
            }
        }else if(indexPath.row < 4 + self.commmonRationTypeValueArr.count){
            ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:self.commmonRationTypeValueArr[indexPath.row - 4]];
            if([self.delegate respondsToSelector:@selector(showRATIONTYPEVALUE:)]){
                [self.delegate showRATIONTYPEVALUE:model.FIELDNAME];
            }
        }else{
            
        }
    }else{
        if(indexPath.row < self.personalRationTypeValueArr.count){
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
        
        if (_currentSelectIndexPath.row < 4) {
            
            [[ZEPointRegCache instance] setUserChoosedOptionDic:@{[ZEUtil getPointRegField:POINT_REG_TASK]:object}];
            
            [self reloadContentView];
        }else if (_currentSelectIndexPath.row < cacheDisType.count + 4){
            ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:object];
            cell.detailTextLabel.text = model.QUOTIETYNAME;
            
            ZEEPM_TEAM_RATIONTYPEDETAIL *cacheDisTypeM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:_commmonRationTypeValueArr[_currentSelectIndexPath.row - 4]];
            NSDictionary * dic = @{cacheDisTypeM.FIELDNAME:object};
            [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
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

-(void)didSeclectTask:(ZEPointChooseTaskView *)taskView withData:(NSDictionary *)dic
{
    ZEV_EPM_TEAM_RATION_APP * model = [ZEV_EPM_TEAM_RATION_APP getDetailWithDic:dic];
    if ([self.delegate respondsToSelector:@selector(getTaskDetail:)]) {
        [_alertView dismissWithCompletion:nil];
        [self.delegate getTaskDetail:model.SEQKEY];
    }
}

#pragma mark - ZEPointRegChooseWorkerDelegate

-(void)didSeclectWorkerWithData:(NSArray *)choosedWorker
{
    
    _choosedWorkerArr = choosedWorker;
    [_alertView dismissWithCompletion:nil];
    
    [self reloadContentView];
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
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag % 1000 == 0) {
        NSDictionary * dic = @{@"DESCR":textField.text};
        NSMutableDictionary * changeDic = _USERCHOOSEDWORKERVALUEARR[textField.tag / 1000 - 1];
        [changeDic setValuesForKeysWithDictionary:dic];
        [_USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:textField.tag / 1000 - 1 withObject:changeDic];
        return;
    }
    if (textField.tag > 99) {
        NSDictionary * rationTypeDic = self.personalRationTypeValueArr[textField.tag % 100];
        
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
        
        NSDictionary * dic = @{detailM.FIELDNAME:textField.text};
        
        NSMutableDictionary * changeDic = _USERCHOOSEDWORKERVALUEARR[textField.tag / 100 - 1];
        [changeDic setValuesForKeysWithDictionary:dic];
        [_USERCHOOSEDWORKERVALUEARR replaceObjectAtIndex:textField.tag / 100 - 1 withObject:changeDic];
    }else{
        NSDictionary * rationTypeDic = self.commmonRationTypeValueArr[textField.tag - 4];
        
        ZEEPM_TEAM_RATIONTYPEDETAIL * detailM = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:rationTypeDic];
        NSDictionary * dic = @{detailM.FIELDNAME:textField.text};
        
        [self.CHOOSEDRATIONTYPEVALUEDic setValuesForKeysWithDictionary:dic];
    }
    
    
}

@end
