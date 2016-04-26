//
//  ViewController.m
//  LoadGIF
//
//  Created by ZhengWei on 16/4/26.
//  Copyright © 2016年 Bourbon. All rights reserved.
//

#import "ViewController.h"
#import "CGImageGIFView.h"
#import "CAKeyframeAnimationGIFView.h"
@interface ViewController ()
{
    CGImageGIFView *gifView;
    CAKeyframeAnimationGIFView *otherGifView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self loadCAKeyframeAnimation];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    if (gifView.isAnimating) {
//        [gifView stopGIF];
//    }else{
//        [gifView startGIF];
//    }
    
    if (otherGifView.isAnimating) {
        [otherGifView stopGIF];
    }else{
        [otherGifView startGIF];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)loadGIFWithWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 350*2, 393)];
    [webView setCenter:self.view.center];
    NSData *gif = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"2" ofType:@"gif"]];
    webView.userInteractionEnabled = NO;
    [webView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    //设置webview背景透明，能看到gif的透明层
    webView.backgroundColor = [UIColor blackColor];
    webView.opaque = NO;
    [self.view addSubview:webView];
    
}
-(void)loadGIFWithCGImage
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"gif"];
    gifView = [[CGImageGIFView alloc] initWithGIFPath:path];
    [gifView setCenter:self.view.center];
    [self.view addSubview:gifView];
}
-(void)loadCAKeyframeAnimation
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"gif"];
    otherGifView = [[CAKeyframeAnimationGIFView alloc] initWithCAKeyframeAnimationWithPath:path];
    otherGifView.center = self.view.center;
    [self.view addSubview:otherGifView];
}
@end
