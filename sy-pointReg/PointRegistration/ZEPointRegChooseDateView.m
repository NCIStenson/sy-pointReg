//
//  ZEPointRegChooseDateView.m
//  NewCentury
//
//  Created by Stenson on 16/1/21.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

#import "ZEPointRegChooseDateView.h"

@interface ZEPointRegChooseDateView ()
{
    UIDatePicker * _picker;
    CGRect _viewFrame;
}
@end

@implementation ZEPointRegChooseDateView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, 288.0f)];
    if (self) {
        _viewFrame = CGRectMake(0, 0, SCREEN_WIDTH - 40, 288.0f);
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
    
    _picker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 44.0f, SCREEN_WIDTH - 40, 200)];
    _picker.backgroundColor = [UIColor whiteColor];
    _picker.datePickerMode = UIDatePickerModeDate;
    [self addSubview:_picker];
    
    for (int i = 0; i < 2; i ++) {
        UIButton * optionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        optionBtn.frame = CGRectMake(0 + _viewFrame.size.width / 2 * i , 244.0f, _viewFrame.size.width / 2, 44.0f);
        [optionBtn setTitle:@"取消" forState:UIControlStateNormal];
        [optionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [optionBtn setBackgroundColor:MAIN_NAV_COLOR];
        optionBtn.tag = i;
        [optionBtn addTarget:self action:@selector(chooseDateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:optionBtn];
        if (i == 1) {
            [optionBtn setTitle:@"确定" forState:UIControlStateNormal];
        }
    }
    
    CALayer * lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(_viewFrame.size.width / 2 - 0.25f, 244.0f, 0.5, 44.0f);
    lineLayer.backgroundColor = [MAIN_LINE_COLOR CGColor];
    [self.layer addSublayer:lineLayer];
    
}

-(void)chooseDateBtnClick:(UIButton *)button{
    
    if (button.tag == 0) {
        if ([self.delegate respondsToSelector:@selector(cancelChooseDate)]) {
            [self.delegate cancelChooseDate];
        }
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString * dateStr = [dateFormatter stringFromDate:_picker.date];
        if ([self.delegate respondsToSelector:@selector(confirmChooseDate:)]) {
            [self.delegate confirmChooseDate:dateStr];
        }
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
