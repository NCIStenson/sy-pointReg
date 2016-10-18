//
//  PointRegOptionView.m
//  NewCentury
//
//  Created by Stenson on 16/1/21.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#define kOptionViewMarginLeft   0.0f
#define kOptionViewMarginTop    44.0f
#define kOptionViewWidth        _viewFrame.size.width

#define kMaxHeight SCREEN_HEIGHT * 0.7

#import "ZEPointRegOptionView.h"
#import "ZEV_EPM_TEAM_RATION_APP.h"
#import "ZEEPM_TEAM_RATIONTYPEDETAIL.h"

@interface ZEPointRegOptionView ()<UITableViewDataSource,UITableViewDelegate>

{
    CGRect _viewFrame;
    
    NSArray * _optionsArray;
    TASK_LIST_LEVEL _listLevel;
    POINT_REG _pointReg;
}

@end

@implementation ZEPointRegOptionView

-(id)initWithOptionArr:(NSArray *)options showButtons:(BOOL)showBut withLevel:(TASK_LIST_LEVEL)level withPointReg:(POINT_REG)pointReg
{
    int viewHeight = 0;
    
    viewHeight = showBut ? (44.0f * (options.count + 2)) : (44.0f * (options.count + 1));
    if (pointReg == POINT_REG_TASK) {
        viewHeight = 44.0f * (options.count + 2);
    }
    if (viewHeight > kMaxHeight) {
        viewHeight = kMaxHeight;
    }
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, viewHeight)];
    if (self) {
        _optionsArray = options;
        _listLevel = level;
        _pointReg = pointReg;
        _viewFrame = CGRectMake(0, 0, SCREEN_WIDTH - 40, viewHeight);
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5;
        [self initView];
    }
    return self;
}

-(void)initView
{
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44.0f)];
    titleLab.text = @"请选择";
    titleLab.backgroundColor = MAIN_NAV_COLOR;
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLab];
    
    UITableView * optionTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    optionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    optionTableView.delegate = self;
    optionTableView.dataSource = self;
    [self addSubview:optionTableView];
    int maxHeight = kMaxHeight;
    if (_viewFrame.size.height != maxHeight) optionTableView.scrollEnabled = NO;
    [optionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kOptionViewMarginLeft);
        make.top.offset(kOptionViewMarginTop);
        if (_viewFrame.size.height == maxHeight) {
            make.size.mas_equalTo(CGSizeMake(kOptionViewWidth,_viewFrame.size.height - 44.0f));
        }else{
            if (_pointReg == POINT_REG_TASK) {
                make.size.mas_equalTo(CGSizeMake(kOptionViewWidth, (_optionsArray.count + 1) * 44.0f));
            }else{
                make.size.mas_equalTo(CGSizeMake(kOptionViewWidth, _optionsArray.count * 44.0f));
            }
        }
    }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_pointReg == POINT_REG_TASK){
        return _optionsArray.count + 1;
    }
    return _optionsArray.count;
}
-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(10, 43.5f, SCREEN_WIDTH - 10, 0.5f);
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    [cell.contentView.layer addSublayer:lineLayer];
    
    if (_listLevel == TASK_LIST_LEVEL_JSON) {
        if (_pointReg == POINT_REG_TASK) {
            if(indexPath.row == _optionsArray.count){
                cell.textLabel.text = @"点击查看更多任务列表...";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.font = [UIFont systemFontOfSize:13];
                return cell;
            }
            ZEV_EPM_TEAM_RATION_APP * model = [ZEV_EPM_TEAM_RATION_APP getDetailWithDic:_optionsArray[indexPath.row]];
            cell.textLabel.text = [NSString stringWithFormat:@"%@",model.RATIONNAME];
        }else{
            ZEEPM_TEAM_RATIONTYPEDETAIL * model = [ZEEPM_TEAM_RATIONTYPEDETAIL getDetailWithDic:_optionsArray[indexPath.row]];
            cell.textLabel.text = [NSString stringWithFormat:@"%@",model.QUOTIETYNAME];
        }

    }else{
        cell.textLabel.text = _optionsArray[indexPath.row];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_pointReg == POINT_REG_TASK  && indexPath.row == _optionsArray.count) {
        if([self.delegate respondsToSelector:@selector(hiddeAlertView)]){
            [self.delegate hiddeAlertView];
        }
        return;
    }
    
    
    if([self.delegate respondsToSelector:@selector(didSelectOption:withRow:)]){
        [self.delegate didSelectOption:_optionsArray[indexPath.row] withRow:indexPath.row];
    }
}

@end
