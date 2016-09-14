//
//  ZEMainView.m
//  WeiXueTang
//
//  Created by Stenson on 16/3/3.
//  Copyright © 2016年  Zenith Electronic Technology Co., Ltd. All rights reserved.
//

#define kToolKitBtnMarginLeft   0.0f
#define kToolKitBtnMarginTop    40.0f
#define kToolKitBtnWidth        SCREEN_WIDTH
#define kToolKitBtnHeight       80.0f

// 导航栏
#define kNavBarWidth            SCREEN_WIDTH
#define kNavBarHeight           64.0f
#define kNavBarMarginLeft       0.0f
#define kNavBarMarginTop        0.0f

// 导航栏标题
#define kNavTitleLabelWidth         (SCREEN_WIDTH - 110.0f)
#define kNavTitleLabelHeight                                            44.0f
#define kNavTitleLabelMarginLeft    (kNavBarWidth - kNavTitleLabelWidth) / 2.0f
#define kNavTitleLabelMarginTop                                         20.0f
// 导航栏内左侧按钮
#define kLeftButtonWidth 40.0f + 16.0f
#define kLeftButtonHeight 40.0f
#define kLeftButtonMarginLeft 10.0f
#define kLeftButtonMarginTop 20.0f + 2.0f

// 导航栏右侧按钮
#define kRightButtonWidth 60.0f
#define kRightButtonHeight 44.0f
#define kRightButtonMarginLeft kNavBarWidth - kRightButtonWidth - 10.0f
#define kRightButtonMarginTop  22.0f


#define kScrollViewWidth            SCREEN_WIDTH
#define kScrollViewlHeight          SCREEN_HEIGHT - NAV_HEIGHT
#define kScrollViewMarginLeft       0.0f
#define kScrollViewMarginTop        NAV_HEIGHT


#import "ZEMainView.h"

#import "ZEUUM_FUNCTION_MODEL.h"

@interface ZEMainView ()
{
    UIScrollView * scrollView;
}
@end

@implementation ZEMainView

-(id)initWithFrame:(CGRect)rect
{
    self = [super initWithFrame:rect];
    if (self) {        
        [self initNavBar];
    }
    return self;
}

-(void)initNavBar
{
    UIView *navBar                = [[UIView alloc] initWithFrame:CGRectMake(kNavBarMarginLeft, kNavBarMarginTop, kNavBarWidth, kNavBarHeight)];
    navBar.backgroundColor        = MAIN_NAV_COLOR;

    UILabel * _titleLabel         = [[UILabel alloc] initWithFrame:CGRectMake(kNavTitleLabelMarginLeft, kNavTitleLabelMarginTop, kNavTitleLabelWidth, kNavTitleLabelHeight)];
    _titleLabel.backgroundColor   = [UIColor clearColor];
    _titleLabel.textAlignment     = NSTextAlignmentCenter;
    _titleLabel.textColor         = [UIColor whiteColor];
    _titleLabel.font              = [UIFont systemFontOfSize:22.0f];
    _titleLabel.text              = @"工时登记";
    [navBar addSubview:_titleLabel];

    [self addSubview:navBar];
    
    UIButton * _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(kLeftButtonMarginLeft, kLeftButtonMarginTop, kLeftButtonWidth, kLeftButtonHeight);
    _leftBtn.backgroundColor = [UIColor clearColor];
    _leftBtn.contentMode = UIViewContentModeScaleAspectFit;
    _leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    [_leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_leftBtn setTitle:[ZESettingLocalData getNICKNAME] forState:UIControlStateNormal];

    [navBar addSubview:_leftBtn];

    
    UIButton * _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(kRightButtonMarginLeft, kRightButtonMarginTop, kRightButtonWidth, kRightButtonHeight);
    [_rightBtn setTitle:@"切换账号" forState:UIControlStateNormal];
    _rightBtn.backgroundColor = [UIColor clearColor];
    [_rightBtn.titleLabel setFont:[UIFont systemFontOfSize:19.0f]];
    [_rightBtn.titleLabel setTextColor:[UIColor blackColor]];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [_rightBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_rightBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:_rightBtn];


    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(kScrollViewMarginLeft, kScrollViewMarginTop, kScrollViewWidth, kScrollViewlHeight)];
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];
}

#pragma mark - HomeView

-(void)reloadHomeView:(NSArray *)data
{
    
    float scroolContentH = 0.0f;
    
    UIImage * bannerImg           = [UIImage imageNamed:@"banner.jpg"];
    UIImageView * bannerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * (bannerImg.size.height / bannerImg.size.width))];
    bannerImageView.image         = bannerImg;
    [scrollView addSubview:bannerImageView];
    scroolContentH = bannerImageView.frame.size.height;

    NSMutableArray * deleteVaildData = [NSMutableArray arrayWithArray:data];
    
    for(int i = 0 ; i < data.count - 1 ; i ++){
        
        ZEUUM_FUNCTION_MODEL * UUMFUNCTIONMODEL = [ZEUUM_FUNCTION_MODEL getDetailWithDic:data[i]];
        if ([UUMFUNCTIONMODEL.FUNCTIONCODE isEqualToString:@"APPSPECIALNUM"]) {
            [deleteVaildData removeObjectAtIndex:i];
        }
        
        ZEUUM_FUNCTION_MODEL * UUMFUNCTIONM = [ZEUUM_FUNCTION_MODEL getDetailWithDic:deleteVaildData[i]];        
        UIButton * enterBtn     = [UIButton buttonWithType:UIButtonTypeCustom];
        enterBtn.frame          = CGRectMake(0 + SCREEN_WIDTH / 3 * (i % 3), (bannerImageView.frame.origin.y + bannerImageView.frame.size.height) + ( i / 3 ) * (IPHONE4S_LESS ? 120 : 150) , SCREEN_WIDTH / 3, (IPHONE4S_LESS ? 100 : 120));
        [enterBtn setImage:[UIImage imageNamed:@"home_toolkit"] forState:UIControlStateNormal];
        [scrollView addSubview:enterBtn];
        [enterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      //  enterBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel * tipsLabel     = [[UILabel alloc]init];
        tipsLabel.font          = [UIFont systemFontOfSize:14];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.frame         = CGRectMake(enterBtn.frame.origin.x, (enterBtn.frame.origin.y +( IPHONE4S_LESS ? 85 : 120)), SCREEN_WIDTH/3,30);
        [scrollView addSubview:tipsLabel];
        
        if (i == 6) {
            scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, scroolContentH + ( i / 3 + 1) * (IPHONE4S_LESS ? 120 : 150));
        }
        [enterBtn setImage:[UIImage imageNamed:@"icon_scan"] forState:UIControlStateNormal];
        tipsLabel.text  = UUMFUNCTIONM.FUNCTIONNAME;
        
        if ([UUMFUNCTIONM.FUNCTIONCODE isEqualToString:@"APP_01"]) {
            [enterBtn setImage:[UIImage imageNamed:@"home_personalskills"] forState:UIControlStateNormal];
            [enterBtn addTarget:self action:@selector(goPointReg) forControlEvents:UIControlEventTouchUpInside];
        }else if ([UUMFUNCTIONM.FUNCTIONCODE isEqualToString:@"APP_02"]){
            [enterBtn setImage:[UIImage imageNamed:@"home_expertsassess"] forState:UIControlStateNormal];
            [enterBtn addTarget:self action:@selector(goChargeView) forControlEvents:UIControlEventTouchUpInside];
        }else if ([UUMFUNCTIONM.FUNCTIONCODE isEqualToString:@"APP_03"]){
            [enterBtn setImage:[UIImage imageNamed:@"home_expertsassess"] forState:UIControlStateNormal];
            [enterBtn addTarget:self action:@selector(goLeaderView) forControlEvents:UIControlEventTouchUpInside];
        }else if ([UUMFUNCTIONM.FUNCTIONCODE isEqualToString:@"APP_04"]){
            [enterBtn setImage:[UIImage imageNamed:@"home_foreman"] forState:UIControlStateNormal];
            [enterBtn addTarget:self action:@selector(goHistory) forControlEvents:UIControlEventTouchUpInside];
        }else if ([UUMFUNCTIONM.FUNCTIONCODE isEqualToString:@"APP_05"]){
            [enterBtn setImage:[UIImage imageNamed:@"home_good"] forState:UIControlStateNormal];
            [enterBtn addTarget:self action:@selector(goPointAudit) forControlEvents:UIControlEventTouchUpInside];
        }else if ([UUMFUNCTIONM.FUNCTIONCODE isEqualToString:@"APP_06"]){
            [enterBtn setImage:[UIImage imageNamed:@"home_toolkit"] forState:UIControlStateNormal];
            [enterBtn addTarget:self action:@selector(goPointQuery) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

#pragma mark - SelfDelegate
-(void)goChargeView
{
    if ([self.delegate respondsToSelector:@selector(goLeaderView:) ]) {
        [self.delegate goLeaderView:ENTER_MANYPERSON_POINTREG_TYPE_CHARGE];
    }
}

-(void)goLeaderView
{
    if ([self.delegate respondsToSelector:@selector(goLeaderView:) ]) {
        [self.delegate goLeaderView:ENTER_MANYPERSON_POINTREG_TYPE_LEADER];
    }
}

-(void)goPointReg
{
    if ([self.delegate respondsToSelector:@selector(goPointReg) ]) {
        [self.delegate goPointReg];
    }
}

-(void)goHistory
{
    if ([self.delegate respondsToSelector:@selector(goHistory) ]) {
        [self.delegate goHistory];
    }
}
-(void)goPointAudit
{
    if ([self.delegate respondsToSelector:@selector(goPointAudit)]) {
        [self.delegate goPointAudit];
    }
}
-(void)logout{
    if ([self.delegate respondsToSelector:@selector(logout)]) {
        [self.delegate logout];
    }
}
-(void)goPointQuery
{
    if ([self.delegate respondsToSelector:@selector(goPointQuery)]) {
        [self.delegate goPointQuery];
    }
}


@end
