//
//  ZbarOverlayView.m
//  MeiNianTJ
//
//  Created by limi on 15/8/12.
//  Copyright (c) 2015年 limi. All rights reserved.
//

// 导航栏
#define kNavBarWidth SCREEN_WIDTH
#define kNavBarHeight 64.0f
#define kNavBarMarginLeft 0.0f
#define kNavBarMarginTop 0.0f

// 返回按钮位置
#define kCloseBtnWidth  60.0f
#define kCloseBtnHeight 60.0f
#define kCloseBtnMarginLeft 10.0f
#define kCloseBtnMarginTop 12.0f

// 导航栏内右侧按钮
#define kRightButtonWidth 76.0f
#define kRightButtonHeight 40.0f
#define kRightButtonMarginRight -10.0f
#define kRightButtonMarginTop 20.0f + 2.0f
// 导航栏标题
#define kNavTitleLabelWidth SCREEN_WIDTH
#define kNavTitleLabelHeight 44.0f
#define kNavTitleLabelMarginLeft 0.0f
#define kNavTitleLabelMarginTop 20.0f

#define kContentViewMarginTop   64.0f
#define kContentViewMarginLeft  0.0f
#define kContentViewWidth       SCREEN_WIDTH
#define kContentViewHeight      (SCREEN_HEIGHT - kNavBarHeight - 44.0f)


#import "ZbarOverlayView.h"

static NSTimeInterval kLineAnimateDuration = 0.02;
@implementation ZbarOverlayView{
    UIImageView *_imgLine;//闪动的线
    UILabel *_LabDesc;
    CGFloat _lineH;//line起始高度
    CGFloat _rectY;//扫描框起始点
    
    NSTimer *_timer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initNavBar];

    }
    return self;
}

- (void)initNavBar
{
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(kNavBarMarginLeft, kNavBarMarginTop, kNavBarWidth, kNavBarHeight)];
    [self addSubview:navBar];
    
    [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kNavBarMarginLeft);
        make.top.offset(kNavBarMarginTop);
        make.size.mas_equalTo(CGSizeMake(kNavBarWidth, kNavBarHeight));
    }];
    navBar.backgroundColor = MAIN_NAV_COLOR;
    navBar.clipsToBounds = YES;
    
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBtn setTitle:@"切换账号" forState:UIControlStateNormal];
//    rightBtn.backgroundColor = [UIColor clearColor];
//    rightBtn.contentMode = UIViewContentModeScaleAspectFit;
//    [rightBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
//    [navBar addSubview:rightBtn];
//    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.offset(kRightButtonMarginRight);
//        make.top.offset(kRightButtonMarginTop);
//        make.size.mas_equalTo(CGSizeMake(kRightButtonWidth, kRightButtonHeight));
//    }];
    
    UILabel *navTitleLabel = [UILabel new];
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.textColor = [UIColor whiteColor];
    navTitleLabel.font = [UIFont systemFontOfSize:24.0f];
    navTitleLabel.text = @"二维码登记";
    [navBar addSubview:navTitleLabel];
    [navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.rightMargin.offset(kNavTitleLabelMarginLeft);
        make.top.offset(kNavTitleLabelMarginTop);
        make.size.mas_equalTo(CGSizeMake(kNavTitleLabelWidth, kNavTitleLabelHeight));
    }];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(kCloseBtnMarginLeft, kCloseBtnMarginTop, kCloseBtnWidth, kCloseBtnHeight);
    closeBtn.backgroundColor = [UIColor clearColor];
    closeBtn.contentMode = UIViewContentModeScaleAspectFit;
    [closeBtn setImage:[UIImage imageNamed:@"icon_back" color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [navBar addSubview:closeBtn];

}

-(void)goBack
{
    if ([self.delegate respondsToSelector:@selector(goBack)]) {
        [self.delegate goBack];
    }
}

-(void)logout
{
    if ([self.delegate respondsToSelector:@selector(logout)]) {
        [self.delegate logout];
    }
}

- (void)layoutSubviews {//call when frame change and addSubview
    
    [super layoutSubviews];
    if (!_imgLine) {
        _rectY = self.transparentArea.origin.y;
        
        [self addLine];//can't add in init
        
        _timer = [NSTimer timerWithTimeInterval:kLineAnimateDuration target:self selector:@selector(lineDrop) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    
    if (!_LabDesc) {
        [self addDescView];
    }
}

- (void)addLine
{
    _imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.transparentArea.size.width, 2)];
    _imgLine.image = [UIImage imageNamed:@"zbar-line.png"];
    _imgLine.center = CGPointMake(self.frame.size.width/2, _rectY + 2);
    _lineH = _imgLine.frame.origin.y;
    [self addSubview:_imgLine];
}

- (void)addDescView
{
    UILabel *LabDesc = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 16)];
    LabDesc.center = CGPointMake(self.frame.size.width/2, _rectY + self.transparentArea.size.height + 20);
    [LabDesc setTextColor:[UIColor whiteColor]];
    [LabDesc setTextAlignment:NSTextAlignmentCenter];
    [LabDesc setFont:[UIFont systemFontOfSize:13]];
    [LabDesc setText:@"将二维码/条形码放入框内，即可自动扫描"];
    [LabDesc setBackgroundColor:[UIColor clearColor]];
    [LabDesc setNumberOfLines:1];
    [self addSubview:LabDesc];
}

- (void)drawRect:(CGRect)rect {//viewDidLoad之后调用
    
    //整个二维码扫描界面的颜色
    CGRect screenDrawRect = self.frame;
    
    //中间清空的矩形框
    CGRect clearDrawRect = self.transparentArea;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self addScreenFillRect:ctx rect:screenDrawRect];
    
    [self addCenterClearRect:ctx rect:clearDrawRect];
    
    [self addWhiteRect:ctx rect:clearDrawRect];
    
    [self addCornerLineWithContext:ctx rect:clearDrawRect];
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextSetRGBFillColor(ctx, 40 / 255.0,40 / 255.0,40 / 255.0,0.5);
    CGContextFillRect(ctx, rect);   //draw the transparent layer
}

- (void)addCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextClearRect(ctx, rect);  //clear the center rect  of the layer
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);//白色
    CGContextSetLineWidth(ctx, 0.8);//线条宽度
    CGContextAddRect(ctx, rect);//创建一个矩形path
    CGContextStrokePath(ctx);//填充矩形条
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    
    //画四个边角
    CGContextSetLineWidth(ctx, 2);
    CGContextSetRGBStrokeColor(ctx, 83 /255.0, 239/255.0, 111/255.0, 1);//绿色
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x+0.7, rect.origin.y),
        CGPointMake(rect.origin.x+0.7 , rect.origin.y + 15)
    };
    
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y +0.7),CGPointMake(rect.origin.x + 15, rect.origin.y+0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x+ 0.7, rect.origin.y + rect.size.height - 15),CGPointMake(rect.origin.x +0.7,rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - 0.7) ,CGPointMake(rect.origin.x+0.7 +15, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - 15, rect.origin.y+0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y +0.7 )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width-0.7,rect.origin.y + 15 +0.7 )};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7 , rect.origin.y+rect.size.height+ -15),CGPointMake(rect.origin.x-0.7 + rect.size.width,rect.origin.y +rect.size.height )};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - 15 , rect.origin.y + rect.size.height-0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height - 0.7 )};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

- (void)lineDrop
{
    [UIView animateWithDuration:kLineAnimateDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect rect = _imgLine.frame;
        rect.origin.y = _lineH;
        _imgLine.frame = rect;
    }completion:^(BOOL complite){
        CGFloat maxBorder = _rectY + self.transparentArea.size.height - 4;
        if (_lineH > maxBorder) {
            
            _lineH = _rectY + 4;
        }
        _lineH ++;
    }];
}


-(void)startAnimation
{
    //开启定时器
    [_timer setFireDate:[NSDate distantPast]];
}
-(void)stopAnimation{
    //取消定时器
    [_timer invalidate];
    _timer = nil;
}
@end
