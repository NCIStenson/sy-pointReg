//
//  ZEQueryMemberQueryVC.m
//  sy-pointReg
//
//  Created by Stenson on 17/5/23.
//  Copyright © 2017年 Zenith Electronic. All rights reserved.
//

#define kContentViewMarginTop   64.0f
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - 64.0f)

#import "ZEQueryMemberQueryVC.h"
#import "ZEEPM_TEAM_RATION_REGModel.h"

#import "ZEPointRegChooseDateView.h"
#import "JCAlertView.h"
#import "ZESumDeatilVC.h"

@interface ZEQueryMemberQueryVC ()<UITableViewDelegate,UITableViewDataSource,ZEPointRegChooseDateViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    UITableView * _contentTableView;
    NSString * _currentMonth;
    JCAlertView * _alertView;
    
    UIView * _chooseMonthView;
    
    NSString * _currentSelectYear;
    NSString * _currentSelectMonth;
}
@property (nonatomic,strong) NSMutableArray * listArr;

@end

@implementation ZEQueryMemberQueryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"班组历史";
    [self.rightBtn setTitle:@"查找" forState:UIControlStateNormal];
    [self initView];
    _currentMonth = [ZEUtil getCurrentMonth];
    [self sendRequest];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

-(void)rightBtnClick
{
    _chooseMonthView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, 288)];
    _chooseMonthView.clipsToBounds = YES;
    _chooseMonthView.layer.cornerRadius = 5;
    
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _chooseMonthView.frame.size.width, 44.0f)];
    titleLab.text = @"请选择";
    titleLab.backgroundColor = MAIN_NAV_COLOR;
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [_chooseMonthView addSubview:titleLab];
    
    UIPickerView * _picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 44.0f, SCREEN_WIDTH - 40, 200)];
    _picker.backgroundColor = [UIColor whiteColor];
    _picker.dataSource = self;
    _picker.delegate = self;
    [_chooseMonthView addSubview:_picker];
    
    NSString * currentMonth = [ZEUtil getCurrentMonth];
    _currentSelectYear = [currentMonth substringToIndex:4];
    _currentSelectMonth = [currentMonth substringFromIndex:4];
    [_picker selectRow:([_currentSelectYear integerValue] - 2000) inComponent:0 animated:YES];
    [_picker selectRow:([_currentSelectMonth integerValue] - 1) inComponent:1 animated:YES];
    
    for (int i = 0; i < 2; i ++) {
        UIButton * optionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        optionBtn.frame = CGRectMake(0 + _chooseMonthView.frame.size.width / 2 * i , 244.0f, _chooseMonthView.frame.size.width / 2, 44.0f);
        [optionBtn setTitle:@"取消" forState:UIControlStateNormal];
        [optionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [optionBtn setBackgroundColor:MAIN_NAV_COLOR];
        optionBtn.tag = i + 100;
        [optionBtn addTarget:self action:@selector(chooseDateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_chooseMonthView addSubview:optionBtn];
        if (i == 1) {
            [optionBtn setTitle:@"确定" forState:UIControlStateNormal];
        }
    }
    
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(_chooseMonthView.frame.size.width / 2 - 0.25f, 244.0f, 0.5, 44.0f);
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    [_chooseMonthView.layer addSublayer:lineLayer];
    
    _alertView = [[JCAlertView alloc]initWithCustomView:_chooseMonthView dismissWhenTouchedBackground:YES];
    [_alertView show];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 30;
    }else{
        return 12;
    }
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [NSString stringWithFormat:@"%ld 年",(long)row + 2000];
    }else{
        return [NSString stringWithFormat:@"%ld 月",(long)row + 1];
    }
    
    return @"";
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        _currentSelectYear = [NSString stringWithFormat:@"%ld",(long)2000 + row];
    }else if (component ==1){
        if(row < 10){
            _currentSelectMonth = [NSString stringWithFormat:@"0%ld",(long)1 + row];
        }else{
            _currentSelectMonth = [NSString stringWithFormat:@"%ld",(long)1 + row];
        }
    }
}

-(void)chooseDateBtnClick:(UIButton *)btn
{
    if (btn.tag == 100) {
        [_alertView dismissWithCompletion:nil];
    }else{
        [_alertView dismissWithCompletion:nil];
        _currentMonth = [NSString stringWithFormat:@"%@%@",_currentSelectYear,_currentSelectMonth];
        [self sendRequest];
    }
}
/**
 *  取消
 */
-(void)cancelChooseDate
{
    [_alertView dismissWithCompletion:nil];
}

-(void)sendRequest
{
    NSString * whereSQL = [NSString stringWithFormat:@"orgcode='#ORGCODE#' and suitunit='#SUITUNIT#' AND  substr(PERIODCODE,0,6)='%@'",_currentMonth];
    if (_ORGCODE.length > 0) {
        whereSQL = [NSString stringWithFormat:@"orgcode='%@' and suitunit='#SUITUNIT#' AND  substr(PERIODCODE,0,6)='%@'",_ORGCODE,_currentMonth];
    }
    
    NSDictionary * parametersDic = @{@"start":@"0",
                                     @"limit":@"-1",
                                     @"MASTERTABLE":EPM_TEAM_RESULT,
                                     @"MASTERFIELD":@"SEQKEY",
                                     @"MENUAPP":@"EMARK_APP",
                                     @"WHERESQL":whereSQL,
                                     @"ORDERSQL":@"FINALSCORE desc",
                                     @"METHOD":@"search",
                                     @"DETAILTABLE":@"",
                                     @"DETAILFIELD":@"",
                                     @"CLASSNAME":@"com.nci.app.operation.business.AppBizOperation",
                                     };
    
    NSDictionary * fieldsDic =@{};
    
    NSDictionary * packageDic = [ZEPackageServerData getCommonServerDataWithTableName:@[EPM_TEAM_RESULT]
                                                                           withFields:@[fieldsDic]
                                                                       withPARAMETERS:parametersDic
                                                                       withActionFlag:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __block ZEQueryMemberQueryVC * safeSelf = self;
    [ZEUserServer getDataWithJsonDic:packageDic
                             success:^(id data) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 if ([[ZEUtil getServerData:data withTabelName:EPM_TEAM_RESULT] count] > 0) {
                                     safeSelf.listArr = [NSMutableArray arrayWithArray:[ZEUtil getServerData:data withTabelName:EPM_TEAM_RESULT]];
                                     [_contentTableView reloadData];
                                 }else{
                                     [self showTips:@"您选择的月份没有数据"];
                                 }
                                 
                             } fail:^(NSError *errorCode) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                             }];
}

-(void)initView
{
    _contentTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentTableView];
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kContentViewMarginLeft);
        make.top.offset(kContentViewMarginTop);
        make.size.mas_equalTo(CGSizeMake(kContentViewWidth, kContentViewHeight));
    }];
}

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView * contentTitleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40.0f)];
    contentTitleView.backgroundColor = [UIColor colorWithRed:0/255.0 green:84/255.0 blue:74/255.0 alpha:0.5];
    
    for (int i = 0; i < 3; i ++ ) {
        UILabel * taskNameLable = [[UILabel alloc]initWithFrame:CGRectMake(10 + (SCREEN_WIDTH - 20) / 3 * i , 0.0f, (SCREEN_WIDTH - 20) / 3, 40.0f)];
        taskNameLable.text = @"工作项";
        taskNameLable.textAlignment = NSTextAlignmentCenter;
        taskNameLable.font = [UIFont systemFontOfSize:14];
        taskNameLable.textColor = kFontColor;
        [contentTitleView addSubview:taskNameLable];
        switch (i) {
            case 0:
                taskNameLable.text = @"月度";
                break;
            case 1:
                taskNameLable.text = @"姓名";
                break;
            case 2:
                taskNameLable.text = @"工分合计";
                break;

            default:
                break;
        }

    }
    return contentTitleView;
}

-(NSMutableAttributedString *)getAttrText:(NSString *)str
                              withTimeStr:(NSString *)timeStr
                             withPointStr:(NSString *)pointStr
{
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithString:str];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:kFontColor
     
                    range:NSMakeRange(0, str.length)];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:[UIColor blueColor]
     
                    range:NSMakeRange(0, str.length - 2)];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:kFontColor
     
                    range:NSMakeRange(0, str.length - 2 - timeStr.length)];
    
    
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:[UIColor blueColor]
     
                    range:NSMakeRange(0, str.length - 7 - timeStr.length)];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
     
                    value:kFontColor
     
                    range:NSMakeRange(0, str.length - 7 - timeStr.length - pointStr.length)];
    
    return attrStr;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArr.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    ZEEPM_TEAM_RATION_REGModel * model = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:self.listArr[indexPath.row]];
    
    for (int i = 0; i < 3; i ++ ) {
        UILabel * taskNameLable = [[UILabel alloc]initWithFrame:CGRectMake(10 + (SCREEN_WIDTH - 20) / 3 * i , 0.0f, (SCREEN_WIDTH - 20) / 3, 40.0f)];
        taskNameLable.textAlignment = NSTextAlignmentCenter;
        taskNameLable.font = [UIFont systemFontOfSize:14];
        taskNameLable.textColor = kFontColor;
        [cell.contentView addSubview:taskNameLable];
        
        CALayer * lineLayer = [CALayer layer];
        [taskNameLable.layer addSublayer:lineLayer];
        lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];

        switch (i) {
            case 0:
            {
                taskNameLable.text = _currentMonth;
            }
                break;
            case 1:
            {
                lineLayer.frame = CGRectMake(0,0,1, 40.0f);
                taskNameLable.text = model.PSNNAME;
            }
                break;
            case 2:
                lineLayer.frame = CGRectMake(0,0,1, 40.0f);
                taskNameLable.text = [NSString stringWithFormat:@"%.2f",[model.FINALSCORE floatValue]];
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZEEPM_TEAM_RATION_REGModel * model = [ZEEPM_TEAM_RATION_REGModel getDetailWithDic:self.listArr[indexPath.row]];

    ZESumDeatilVC * sumDetailVC = [[ZESumDeatilVC alloc]init];
    sumDetailVC.PSNNUM = model.PSNNUM;
    sumDetailVC.PERIODCODE = model.PERIODCODE;
    [self.navigationController pushViewController:sumDetailVC animated:YES];

}

@end
