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

#define kScrollViewWidth            SCREEN_WIDTH
#define kScrollViewlHeight          SCREEN_HEIGHT - NAV_HEIGHT
#define kScrollViewMarginLeft       0.0f
#define kScrollViewMarginTop        NAV_HEIGHT


#import "ZEMainView.h"

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
    _titleLabel.text              = @"工分登记";
    [navBar addSubview:_titleLabel];

    [self addSubview:navBar];

    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(kScrollViewMarginLeft, kScrollViewMarginTop, kScrollViewWidth, kScrollViewlHeight)];
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];
    
    float scroolContentH = 0.0f;
    
    UIImage * bannerImg           = [UIImage imageNamed:@"banner.jpg"];
    UIImageView * bannerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * (bannerImg.size.height / bannerImg.size.width))];
    bannerImageView.image         = bannerImg;
    [scrollView addSubview:bannerImageView];
    scroolContentH = bannerImageView.frame.size.height;
    
    for(int i = 0 ; i < 4 ; i ++){
        UIButton * enterBtn     = [UIButton buttonWithType:UIButtonTypeCustom];
        enterBtn.frame          = CGRectMake(0 + SCREEN_WIDTH / 3 * (i % 3), (bannerImageView.frame.origin.y + bannerImageView.frame.size.height) + ( i / 3 ) * (IPHONE4S_LESS ? 120 : 150) , SCREEN_WIDTH / 3, (IPHONE4S_LESS ? 100 : 120));
        [enterBtn setImage:[UIImage imageNamed:@"home_toolkit"] forState:UIControlStateNormal];
        [scrollView addSubview:enterBtn];
        [enterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        UILabel * tipsLabel     = [[UILabel alloc]init];
        tipsLabel.font          = [UIFont systemFontOfSize:14];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.frame         = CGRectMake(enterBtn.frame.origin.x, (enterBtn.frame.origin.y +( IPHONE4S_LESS ? 85 : 120)), SCREEN_WIDTH/3,30);
        [scrollView addSubview:tipsLabel];
        
        if (i == 6) {
            NSLog(@">>  %f %d",scroolContentH + ( i / 3 + 1 ) * (IPHONE4S_LESS ? 120 : 150),i / 3);
            scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, scroolContentH + ( i / 3 + 1) * (IPHONE4S_LESS ? 120 : 150));
        }
        [enterBtn setImage:[UIImage imageNamed:@"icon_scan"] forState:UIControlStateNormal];
        tipsLabel.text  = @"二维码扫描";

        switch (i) {
            case 0:
                [enterBtn setImage:[UIImage imageNamed:@"icon_scan"] forState:UIControlStateNormal];
                tipsLabel.text  = @"二维码扫描";
                [enterBtn addTarget:self action:@selector(goScan) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                [enterBtn setImage:[UIImage imageNamed:@"icon_point"] forState:UIControlStateNormal];
                tipsLabel.text  = @"工分登记";
                [enterBtn addTarget:self action:@selector(goPointReg) forControlEvents:UIControlEventTouchUpInside];

                break;
            case 2:
                [enterBtn setImage:[UIImage imageNamed:@"icon_history_big"] forState:UIControlStateNormal];
                tipsLabel.text  = @"历史查询";
                [enterBtn addTarget:self action:@selector(goHistory) forControlEvents:UIControlEventTouchUpInside];

                break;
            case 3:
            {
//                if(![ZESetLocalData getRoleFlag]){
//                    break;
//                }
                tipsLabel.text  = @"工分审核";
                [enterBtn addTarget:self action:@selector(goPointAudit) forControlEvents:UIControlEventTouchUpInside];
                [enterBtn setImage:[UIImage imageNamed:@"icon_audit"] forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
        
    }
    
    
}

#pragma mark - HomeView

-(void)reloadHomeView:(NSArray *)data
{
    
}

#pragma mark - SelfDelegate

-(void)goScan
{
    if ([self.delegate respondsToSelector:@selector(goScanView) ]) {
        [self.delegate goScanView];
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
-(void)goUserCenter
{
    if ([self.delegate respondsToSelector:@selector(goUserCenter)]) {
        [self.delegate goUserCenter];
    }
}


@end
