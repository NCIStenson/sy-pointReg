//
//  ZELoginView.m
//  NewCentury
//
//  Created by Stenson on 16/1/22.
//  Copyright © 2016年 Zenith Electronic. All rights reserved.
//

// 导航栏
#define kNavBarWidth SCREEN_WIDTH
#define kNavBarHeight 64.0f
#define kNavBarMarginLeft 0.0f
#define kNavBarMarginTop 0.0f

#define kInputMessageWidth          (SCREEN_WIDTH - kInputMessageMarginLeft * 2 )
#define kInputMessageHeight         100.0f
#define kInputMessageMarginLeft     30.0f
#define kInputMessageMarginTop      kNavBarHeight + 50.0f

#define kUsernameLabMarginLeft  10.0f
#define kUsernameLabMarginTop   0.0f
#define kUsernameLabWidth       40.0f
#define kUsernameLabHeight      30.0f

#define kPasswordLabMarginLeft  10.0f
#define kPasswordLabMarginTop   65.0f
#define kPasswordLabWidth       kUsernameLabWidth
#define kPasswordLabHeight      kUsernameLabHeight

#define kUsernameFieldMarginLeft  50.0f
#define kUsernameFieldMarginTop   50.0f
#define kUsernameFieldWidth       (SCREEN_WIDTH - 80.0f - kUsernameLabWidth - 15.0f)
#define kUsernameFieldHeight      40.0f

#define kPasswordFieldMarginLeft  kUsernameFieldMarginLeft
#define kPasswordFieldMarginTop   kUsernameFieldMarginTop + 55.0f
#define kPasswordFieldWidth       kUsernameFieldWidth
#define kPasswordFieldHeight      kUsernameFieldHeight

// 登陆按钮位置
#define kLoginBtnWidth (_viewFrame.size.width - 60.0f)
#define kLoginBtnHeight 40.0f
#define kLoginBtnToLeft (SCREEN_WIDTH - kLoginBtnWidth) / 2
#define kLoginBtnToTop 200.0f + kNavBarHeight

// 导航栏标题
#define kNavTitleLabelWidth (SCREEN_WIDTH - 110.0f)
#define kNavTitleLabelHeight 44.0f
#define kNavTitleLabelMarginLeft (kNavBarWidth - kNavTitleLabelWidth) / 2.0f
#define kNavTitleLabelMarginTop 20.0f

#define LINECOLOR [MAIN_NAV_COLOR CGColor];


#import "ZELoginView.h"
@interface ZELoginView ()<UITextFieldDelegate>
{
    CGRect _viewFrame;
    UIButton * loginBtn;
    
    UITextField * _usernameField;
    UITextField * _passwordField;
    
    
}
@end

@implementation ZELoginView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewFrame = frame;
        self.backgroundColor = MAIN_LINE_COLOR;
        [self initNavView];
        [self initInputView];
        [self initLoginBtn];
    }
    return self;
}

#pragma mark - custom view init

-(void)initNavView
{
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(kNavBarMarginLeft, kNavBarMarginTop, kNavBarWidth, kNavBarHeight)];
    navBar.backgroundColor = MAIN_NAV_COLOR;
    navBar.clipsToBounds = YES;
    
    UILabel *  _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kNavTitleLabelMarginLeft, kNavTitleLabelMarginTop, kNavTitleLabelWidth, kNavTitleLabelHeight)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:22.0f];
    _titleLabel.text = @"用户登录";
    
    [navBar addSubview:_titleLabel];
    
    [self addSubview:navBar];

}

- (void)initInputView
{    
    UIView * inputMessageBackView = [[UIView alloc]init];
    [self addSubview:inputMessageBackView];
    inputMessageBackView.backgroundColor = [UIColor whiteColor];
    [inputMessageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kInputMessageMarginTop);
        make.left.mas_equalTo(kInputMessageMarginLeft);
        make.size.mas_equalTo(CGSizeMake(kInputMessageWidth,kInputMessageHeight));
    }];

    for (int i = 0 ; i < 2; i ++) {
        CALayer * vLineLayer = [CALayer layer];
        vLineLayer.frame = CGRectMake(i * kInputMessageWidth, 0.0f, 1, 100);
        vLineLayer.backgroundColor = LINECOLOR;
        [inputMessageBackView.layer addSublayer:vLineLayer];
        
        UIImageView * usernameImage = [[UIImageView alloc]initWithFrame:CGRectZero];
        [inputMessageBackView addSubview:usernameImage];
        
        UITextField * field = [[UITextField alloc]init];
        field.delegate      = self;
        field.textColor     = [UIColor blackColor];
        [inputMessageBackView addSubview:field];
        field.leftViewMode  = UITextFieldViewModeAlways;
        field.leftView      = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
        [field setValue:MAIN_LINE_COLOR forKeyPath:@"_placeholderLabel.textColor"];

        if (i == 1) {
            CALayer * firstLineLayer = [CALayer layer];
            firstLineLayer.frame = CGRectMake(0.0f, 0.0f, kInputMessageWidth, 1);
            firstLineLayer.backgroundColor = LINECOLOR;
            [inputMessageBackView.layer addSublayer:firstLineLayer];

            CALayer * lineLayer = [CALayer layer];
            lineLayer.frame = CGRectMake(0.0f,50.0f, kLoginBtnWidth, 1);
            lineLayer.backgroundColor = LINECOLOR;
            [inputMessageBackView.layer addSublayer:lineLayer];
            
            usernameImage.image = [UIImage imageNamed:@"login_password.png" color:MAIN_LINE_COLOR];
            field.placeholder = @"请输入密码";
            field.secureTextEntry = YES;
            [field mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(kPasswordFieldMarginLeft);
                make.top.offset(55.0f);
                make.size.mas_equalTo(CGSizeMake(kPasswordFieldWidth, kPasswordFieldHeight));
            }];
            _passwordField = field;
            [usernameImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(kPasswordLabMarginLeft);
                make.top.offset(kPasswordLabMarginTop );
                make.size.mas_equalTo(CGSizeMake(kPasswordLabWidth, kPasswordLabHeight));
            }];
        }else {
            
            CALayer * lineLayer = [CALayer layer];
            lineLayer.frame = CGRectMake(0.0f, 99.0f, kLoginBtnWidth, 1);
            lineLayer.backgroundColor = LINECOLOR;
            [inputMessageBackView.layer addSublayer:lineLayer];

            field.placeholder = @"请输入用户名";

            [field mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(kUsernameFieldMarginLeft);
                make.top.offset(5.0f);
                make.size.mas_equalTo(CGSizeMake(kUsernameFieldWidth, kUsernameFieldHeight));
            }];
            _usernameField = field;
            usernameImage.image = [UIImage imageNamed:@"login_username.png" color:MAIN_LINE_COLOR];

            [usernameImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(kPasswordLabMarginLeft);
                make.top.mas_equalTo(15.0f);
                make.size.mas_equalTo(CGSizeMake(kUsernameLabWidth, kUsernameLabHeight));
            }];
        }
    }
}

- (void)initLoginBtn
{
    loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(kLoginBtnToLeft, kLoginBtnToTop, kLoginBtnWidth, kLoginBtnHeight);
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitle:@"登   录" forState:UIControlStateNormal];
    [loginBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
    [loginBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [loginBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [loginBtn addTarget:self action:@selector(goLogin) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:loginBtn];
    loginBtn.backgroundColor = RGBA(1, 112, 99, 1);
    loginBtn.clipsToBounds = YES;
    loginBtn.layer.cornerRadius = 5;
}

-(void)goLogin
{
    if (![_usernameField isExclusiveTouch]) {
        [_usernameField resignFirstResponder];
    }
    
    if (![_passwordField isExclusiveTouch]) {
        [_passwordField resignFirstResponder];
    }
    [UIView animateWithDuration:0.29 animations:^{
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:nil];
    if ([self.delegate respondsToSelector:@selector(goLogin:password:)]) {
        [self.delegate goLogin:_usernameField.text password:_passwordField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
        [UIView animateWithDuration:0.29 animations:^{
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        } completion:nil];
    
    if (![_usernameField isExclusiveTouch]) {
        [_usernameField resignFirstResponder];
    }
    
    if (![_passwordField isExclusiveTouch]) {
        [_passwordField resignFirstResponder];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (IPHONE5) {
        [UIView animateWithDuration:0.29 animations:^{
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        } completion:nil];
    }else if (IPHONE4S_LESS) {
        [UIView animateWithDuration:0.29 animations:^{
            self.frame = CGRectMake(0, 50, SCREEN_WIDTH, SCREEN_HEIGHT);
        } completion:nil];
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
