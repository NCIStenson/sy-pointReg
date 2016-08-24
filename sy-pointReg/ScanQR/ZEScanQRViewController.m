//
//  ZEScanQRViewController.m
//  NewCentury
//
//  Created by Stenson on 16/1/20.
//  Copyright © 2016年 Stenson. All rights reserved.
//

#import "ZEScanQRViewController.h"
#import "ZbarOverlayView.h"
#import "ZBarSDK.h"
#import "CreateView.h"
#import "ZEPointRegistrationVC.h"
#import "ZEPointRegCache.h"
#import "ZELoginViewController.h"

@interface ZEScanQRViewController ()<ZBarReaderDelegate,ZbarOverlayViewDelegate>

@end

@implementation ZEScanQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
//    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    //设置代理
    reader.readerDelegate = self;
    //基本适配
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    //二维码/条形码识别设置
    ZBarImageScanner *scanner = reader.scanner;
    [reader setShowsZBarControls:NO];

    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    //弹出系统照相机，全屏拍摄
    [self.navigationController pushViewController:reader animated:NO];
    
    const float h = [UIScreen mainScreen].bounds.size.height;
    const float w = [UIScreen mainScreen].bounds.size.width;
    const float h_padding = w * 0.2;
    const float v_padding = h / 3.0;
    CGRect reader_rect = CGRectMake(h_padding, v_padding,
                                    w * 0.6, h / 3.0);//视图中的一小块,实际使用中最好传居中的区域
    if (IPHONE4S_LESS) {
        reader_rect = CGRectMake(h_padding, h / 4.0f,
                                 w * 0.6, w * 0.6);
    }
    CGRect reader_rect1 = CGRectMake(0, 0, w, h);//全屏模式
    reader.view.frame = reader_rect1;
//    reader.backgroundColor = [UIColor redColor];
    
    ZbarOverlayView * _overLayView = [[ZbarOverlayView alloc]initWithFrame:reader.view.frame];//添加覆盖视图
    _overLayView.transparentArea = reader_rect;//设置中间可选框大小
    _overLayView.delegate = self;
    [reader.view addSubview:_overLayView];
    reader.scanCrop = [self getScanCrop:reader_rect readerViewBounds:reader_rect1];
}
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat fullWidth = readerViewBounds.size.width;
    CGFloat fullHeight = readerViewBounds.size.height;
    CGFloat x,y,width,height;
    x = rect.origin.x;
    y = rect.origin.y;
    width = rect.size.width;
    height = rect.size.height;
    if (x + width > fullWidth) {
        if (width > fullWidth) {
            width = fullWidth;
        }else{
            x = 0;
        }
    }
    if (y + height > fullHeight) {
        if (height > fullHeight) {
//            height = fullHeight;
        }else{
            y = 0;
        }
    }
    CGFloat x1,y1,width1,height1;
    x1 = (fullWidth - width - x) / fullWidth;
    y1 = y / fullHeight;
    width1 = width / fullWidth;
    height1 = rect.size.height / readerViewBounds.size.height;
    return CGRectMake(y1, x1,height1, width1);
}
#pragma mark - didFinishScan QR Code Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    id results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol * symbol = nil;
    for (symbol in results)
        break;
    NSString * str = symbol.data;
    if ([ZEUtil isStrNotEmpty:str]) {
        ZEPointRegistrationVC * pointRegVC = [[ZEPointRegistrationVC alloc]init];
        pointRegVC.codeStr = str;
        [self presentViewController:pointRegVC animated:YES completion:nil];
    }
}
#pragma mark - ZbarOverlayViewDelegate

-(void)logout{
    
//    [ZESetLocalData deleteLoaclUserData];
//    [[ZEPointRegCache instance] clear];
//    
//    UIWindow * window = [UIApplication sharedApplication].keyWindow;
//    ZELoginViewController * loginVC = [[ZELoginViewController alloc]init];
//    window.rootViewController = loginVC;
}

-(void)goBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)dealloc
{
    NSLog(@"ZEScanQRViewController  dead");
}

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
