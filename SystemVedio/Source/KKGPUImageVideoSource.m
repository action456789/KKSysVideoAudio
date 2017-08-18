//
//  KKGIVideoSource.m
//  SystemVedio
//
//  Created by sen.ke on 2017/7/27.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import "KKGPUImageVideoSource.h"
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautifyFilter.h"

@implementation KKGPUImageVideoSource {
    UIView *_parentView;
    
    GPUImageVideoCamera *_giVideoSource;
    GPUImageView *_giView;
}

- (instancetype)initWithParentView:(UIView *)view
{
    self = [super init];
    if (self) {
        _parentView = view;
        
        // 1. GPUImageVideoCamera
        _giVideoSource = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
        _giVideoSource.outputImageOrientation = UIInterfaceOrientationPortrait;
        _giVideoSource.horizontallyMirrorFrontFacingCamera = YES;
        
        // 2. 滤镜(Filter)
        // 反色
        //    GPUImageColorInvertFilter *invert = [[GPUImageColorInvertFilter alloc] init];
        
        // 双边滤波(Bilateral Filter)：美颜效果不好
        //    GPUImageBilateralFilter *filter = [[GPUImageBilateralFilter alloc] init];
        
        // 琨君的美颜滤镜，简书：http://www.jianshu.com/p/945fc806a9b4，github: https://github.com/Guikunzhi/BeautifyFaceDemo
        GPUImageBeautifyFilter *filter = [[GPUImageBeautifyFilter alloc] init];
        
        [_giVideoSource addTarget:filter];
        
        // 3. GPUImageView
        _giView = [[GPUImageView alloc] initWithFrame:_parentView.frame];
        _giView.center = _parentView.center;
        [_parentView addSubview:_giView];
        
        [filter addTarget:_giView];
    }
    return self;
}

- (void)start {
    [_giVideoSource startCameraCapture];
}

- (void)stop {
    [_giVideoSource stopCameraCapture];
}

@end
