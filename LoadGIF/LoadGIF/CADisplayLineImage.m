//
//  CADisplayLineImage.m
//  LoadGIF
//
//  Created by ZhengWei on 16/4/26.
//  Copyright © 2016年 Bourbon. All rights reserved.
//

#import "CADisplayLineImage.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
//获取当前ref的时间
inline static NSTimeInterval CGImageSourceGetGifFrameDelay(CGImageSourceRef imageSource, NSUInteger index)
{
    NSTimeInterval frameDuration = 0;
    
    CFDictionaryRef theImageProperties;
    
    if ((theImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL))) {
        
        CFDictionaryRef gifProgreties;
        
        if (CFDictionaryGetValueIfPresent(theImageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProgreties)) {
            
            const void *frameDurationValue;
            
            if (CFDictionaryGetValueIfPresent(gifProgreties, kCGImagePropertyGIFUnclampedDelayTime, &frameDurationValue)) {
                
                frameDuration = [(__bridge NSNumber *)frameDurationValue doubleValue];
                
                if (frameDuration <= 0) {
                    if (CFDictionaryGetValueIfPresent(gifProgreties, kCGImagePropertyGIFDelayTime, &frameDurationValue)) {
                        
                        frameDuration = [(__bridge NSNumber *)frameDurationValue doubleValue];
                    }
                }
            }
        }
        CFRelease(theImageProperties);
    }
#ifndef OLExactGIFRepresentation
    //Implement as Browsers do.
    //See:  http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility
    //Also: http://blogs.msdn.com/b/ieinternals/archive/2010/06/08/animated-gifs-slow-down-to-under-20-frames-per-second.aspx
    
    if (frameDuration < 0.02 - FLT_EPSILON) {
        frameDuration = 0.1;
    }
#endif
    return frameDuration;
}
//判断是否是gif
inline static BOOL CGImageSourceContainsAnimatedGif(CGImageSourceRef imageSource)
{
    return imageSource && UTTypeConformsTo(CGImageSourceGetType(imageSource), kUTTypeGIF) && CGImageSourceGetCount(imageSource) > 1;
}
//判断是否是双倍图
inline static BOOL isRetinaFilePath(NSString *path)
{
    NSRange retinaSuffixRange = [[path lastPathComponent] rangeOfString:@"@2x" options:NSCaseInsensitiveSearch];
    return retinaSuffixRange.length && retinaSuffixRange.location != NSNotFound;
}

@interface CADisplayLineImage ()
@property (nonatomic) NSTimeInterval *frameDurations;
@property (nonatomic) NSUInteger loopCount;
@property (nonatomic) NSMutableArray *images;
@property (nonatomic) NSTimeInterval totalDuratoin;
@end

static int _prefetchedNum = 10;

@implementation CADisplayLineImage
@synthesize images;

-(instancetype)initWithContentsOfFile:(NSString *)path
{
    return [self initWithData:[NSData dataWithContentsOfFile:path] scale:isRetinaFilePath(path)?2.0f:1.0f];
}
-(instancetype)initWithData:(NSData *)data
{
    return [self initWithData:data scale:1.0f];
}
-(instancetype)initWithData:(NSData *)data scale:(CGFloat)scale
{
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    
    if (CGImageSourceContainsAnimatedGif(imageSource)) {
        self = [self initWithCGImageSource:imageSource scale:scale];
    }else{
        if (scale == 1.0f) {
            self = [super initWithData:data];
        }else{
            self = [super initWithData:data scale:scale];
        }
    }
    if (imageSource) {
        CFRelease(imageSource);
    }
    return self;
}
-(instancetype)initWithCGImageSource:(CGImageSourceRef)imageSource scale:(CGFloat)scale
{
    self = [super init];
    if (!imageSource || !self) {
        return nil;
    }
    CFRetain(imageSource);
    size_t numberOfFrames = CGImageSourceGetCount(imageSource);
    
    NSDictionary *imageProperties = CFBridgingRelease(CGImageSourceCopyProperties(imageSource, NULL));
    NSDictionary *gifProerties = [imageProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    self.frameDurations = malloc(numberOfFrames);
    self.loopCount = [[gifProerties objectForKey:(NSString *)kCGImagePropertyGIFLoopCount] unsignedIntegerValue];
    self.images  = [NSMutableArray arrayWithCapacity:numberOfFrames];
    
    NSNull *aNull = [NSNull null];
    for (NSUInteger i = 0; i < numberOfFrames; i++) {
        [self.images addObject:aNull];
        NSTimeInterval frameDuration = CGImageSourceGetGifFrameDelay(imageSource,i);
        self.frameDurations[i] = frameDuration;
        self.totalDuratoin += frameDuration;
    }
    
    NSUInteger num = MIN(_prefetchedNum, numberOfFrames);
    for (int i = 0; i < num; i++) {
        
        CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
        [self.images replaceObjectAtIndex:i withObject:[UIImage imageWithCGImage:image scale:scale orientation:UIImageOrientationUp]];
        CGImageRelease(image);
    }
    
}
@end
