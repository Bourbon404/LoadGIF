//
//  CGImageGIFView.h
//  LoadGIF
//
//  Created by ZhengWei on 16/4/26.
//  Copyright © 2016年 Bourbon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CGImageGIFView : UIView

@property (nonatomic,assign,readonly) BOOL isAnimating;

-(instancetype)initWithGIFPath:(NSString *)path;

-(void)startGIF;
-(void)stopGIF;

@end
