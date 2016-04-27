//
//  CAKeyframeAnimationGIFView.m
//  LoadGIF
//
//  Created by ZhengWei on 16/4/26.
//  Copyright © 2016年 Bourbon. All rights reserved.
//

#import "CAKeyframeAnimationGIFView.h"
#import <ImageIO/ImageIO.h>
@interface CAKeyframeAnimationGIFView ()
{
    //解析gif后每一张图片的显示时间
    NSMutableArray *timeArray;
    //解析gif后的每一张图片数组
    NSMutableArray *imageArray;
    //gif动画总时间
    CGFloat totalTime;
    //gif宽度
    CGFloat width;
    //gif高度
    CGFloat height;
}
@property (nonatomic,assign,readwrite) BOOL isAnimating;
@end
@implementation CAKeyframeAnimationGIFView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
void configImage(CFURLRef url,NSMutableArray *timeArray,NSMutableArray *imageArray,CGFloat *width,CGFloat *height,CGFloat *totalTime)
{

    NSDictionary *gifProperty = [NSDictionary dictionaryWithObject:@{@0:(NSString *)kCGImagePropertyGIFLoopCount} forKey:(NSString *)kCGImagePropertyGIFDictionary];
    //拿到ImageSourceRef后获取gif内部图片个数
    CGImageSourceRef ref = CGImageSourceCreateWithURL(url, (CFDictionaryRef)gifProperty);
    size_t count = CGImageSourceGetCount(ref);
    
    for (int i = 0; i < count; i++) {
     
        //添加图片
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(ref, i, (CFDictionaryRef)gifProperty);
        [imageArray addObject:CFBridgingRelease(imageRef)];
        
        //取每张图片的图片属性,是一个字典
        NSDictionary *dict = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(ref, i, (CFDictionaryRef)gifProperty));
        
        //取宽高
        if (width != NULL && height != NULL) {
            *width = [[dict valueForKey:(NSString *)kCGImagePropertyPixelWidth] floatValue];
            *height = [[dict valueForKey:(NSString *)kCGImagePropertyPixelHeight] floatValue];
        }
        
        //添加每一帧时间
        NSDictionary *tmp = [dict valueForKey:(NSString *)kCGImagePropertyGIFDictionary];
        [timeArray addObject:[tmp valueForKey:(NSString *)kCGImagePropertyGIFDelayTime]];
        
        //总时间
        *totalTime = *totalTime + [[tmp valueForKey:(NSString *)kCGImagePropertyGIFDelayTime] floatValue];
    }
}
-(instancetype)initWithCAKeyframeAnimationWithPath:(NSString *)path
{
    if (self = [super init]) {
        imageArray = [NSMutableArray array];
        timeArray = [NSMutableArray array];
        configImage((__bridge CFURLRef)[NSURL fileURLWithPath:path], timeArray, imageArray, &width,&height,&totalTime);
        
        self.isAnimating = NO;
        self.frame = CGRectMake(0, 0, width, height);
    }
    return self;
}
-(void)startGIF
{
    self.isAnimating = YES;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    //获取每帧动画起始时间在总时间的百分比
    NSMutableArray *percentageArray = [NSMutableArray array];
    CGFloat currentTime = 0.0;
    for (int i = 0; i < timeArray.count; i++) {
        NSNumber *percentage = [NSNumber numberWithFloat:currentTime/totalTime];
        [percentageArray addObject:percentage];
        currentTime = currentTime + [[timeArray objectAtIndex:i] floatValue];
    }
    [animation setKeyTimes:percentageArray];
    
    //添加每帧动画
    [animation setValues:imageArray];
    //动画信息基本设置
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [animation setDuration:totalTime];
    [animation setDelegate:self];
    [animation setRepeatCount:1000];
    
    //添加动画
    [self.layer addAnimation:animation forKey:@"gif"];
    
}
-(void)stopGIF
{
    self.isAnimating = NO;
    [self.layer removeAllAnimations];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.layer.contents = nil;
    self.isAnimating = NO;
}




@end
