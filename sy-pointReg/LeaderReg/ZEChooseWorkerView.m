//
//  ZEChooseWorkerView.m
//  sy-pointReg
//
//  Created by Stenson on 16/8/29.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#define kOptionViewMarginLeft   0.0f
#define kOptionViewMarginTop    44.0f
#define kOptionViewWidth        _viewFrame.size.width

#define kMaxHeight SCREEN_HEIGHT * 0.7

#import "ZEChooseWorkerView.h"

@interface ZEChooseWorkerView ()<UITableViewDataSource,UITableViewDelegate>
{
    CGRect _viewFrame;
    UITableView * _optionTableView;
    NSMutableArray * _maskArr;
    
}
@property (nonatomic,retain) NSArray * optionsArray;

@property (nonatomic,strong) NSMutableArray * choosedWorkerArr;

@end

@implementation ZEChooseWorkerView

-(id)initWithOptionArr:(NSArray *)options withWorkerList:(NSArray *)choosedWorker
{
    float viewH = 0;
    if ((options.count + 2 ) * 44.0f > kMaxHeight) {
        viewH = kMaxHeight;
    }else{
        viewH = (options.count + 2 ) * 44.0f;
    }
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, viewH)];
    if (self) {
        _optionsArray = options;
        self.choosedWorkerArr = [NSMutableArray arrayWithArray:choosedWorker];
        
        _viewFrame = CGRectMake(0, 0, SCREEN_WIDTH - 40, viewH);
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5;
        [self initData];
        [self initView];
    }
    return self;
}

-(void)initData
{
    _maskArr = [NSMutableArray arrayWithCapacity:_optionsArray.count];
    for (int i = 0; i < _optionsArray.count; i ++) {
        NSDictionary * allWorkerList = _optionsArray[i];
        NSString * isMask = @"0";
        for (int j = 0; j < self.choosedWorkerArr.count;j++ ) {
            NSDictionary * choosedWorkerList = self.choosedWorkerArr[j];
            if ([[allWorkerList objectForKey:@"PSNNUM"] isEqualToString:[choosedWorkerList objectForKey:@"PSNNUM"]]) {
                isMask = @"1";
                break;
            }
        }
        [_maskArr addObject:isMask];
    }
}

-(void)initView
{
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44.0f)];
    titleLab.text = @"请选择";
    titleLab.backgroundColor = MAIN_NAV_COLOR;
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLab];
    
    _optionTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _optionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _optionTableView.delegate = self;
    _optionTableView.dataSource = self;
    [self addSubview:_optionTableView];
    
    for (int i = 0; i < 2; i ++) {
        UIButton * optionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        optionBtn.frame = CGRectMake(0 + _viewFrame.size.width / 2 * i , _viewFrame.size.height - 44.0f, _viewFrame.size.width / 2, 44.0f);
        [optionBtn setTitle:@"取消" forState:UIControlStateNormal];
        [optionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [optionBtn setBackgroundColor:MAIN_NAV_COLOR];
        optionBtn.tag = i;
        [optionBtn addTarget:self action:@selector(chooseWorkerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:optionBtn];
        if (i == 1) {
            [optionBtn setTitle:@"确定" forState:UIControlStateNormal];
        }
    }
    
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(_viewFrame.size.width / 2 - 0.25f,  _viewFrame.size.height - 44.0f, 0.5, 44.0f);
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    [self.layer addSublayer:lineLayer];
    
    [_optionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kOptionViewMarginLeft);
        make.top.offset(kOptionViewMarginTop);
        make.size.mas_equalTo(CGSizeMake(kOptionViewWidth,kMaxHeight - 88.0f));
    }];
}
#pragma mark - UITableViewDataSource

-(void)showDetailTaskList:(UIButton *)button
{
    BOOL boolean = [_maskArr[button.tag] boolValue];
    boolean = !boolean;
    [_maskArr removeObjectAtIndex:button.tag];
    [_maskArr insertObject:[NSString stringWithFormat:@"%d",boolean] atIndex:button.tag];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:button.tag];
    [_optionTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_optionsArray count];
}
-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_optionsArray[indexPath.row] objectForKey:@"PSNNAME"];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.textColor = MAIN_COLOR;
    
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(10, 43.5f, SCREEN_WIDTH - 10, 0.5f);
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    [cell.contentView.layer addSublayer:lineLayer];
    
    BOOL isMask = [_maskArr[indexPath.row] boolValue];
    if (isMask) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITabelViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isMask = [_maskArr[indexPath.row] boolValue];
    if (isMask) {
        [_maskArr removeObjectAtIndex:indexPath.row];
        [_maskArr insertObject:[NSString stringWithFormat:@"0"] atIndex:indexPath.row];
    }else{
        [_maskArr removeObjectAtIndex:indexPath.row];
        [_maskArr insertObject:[NSString stringWithFormat:@"1"] atIndex:indexPath.row];
    }
    
    [_optionTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)chooseWorkerBtnClick:(UIButton *)btn
{
    NSMutableArray * choosedArr = [NSMutableArray array];
    for (int i = 0 ; i < _maskArr.count ; i++) {
        BOOL isMask = [_maskArr[i] boolValue];
        if (isMask) {
            [choosedArr addObject:_optionsArray[i]];
        }
    }
    if ([self.delegate respondsToSelector:@selector(didSeclectWorkerWithData:)]) {
        [self.delegate didSeclectWorkerWithData:choosedArr];
    }
    
}

@end
