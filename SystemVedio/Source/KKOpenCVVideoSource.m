//
//  KKOpenCVVideoSource.m
//  SystemVedio
//
//  Created by sen.ke on 2017/7/28.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import "KKOpenCVVideoSource.h"
#import "FJFaceDetector.h"

@interface KKOpenCVVideoSource() <FJFaceDetectorDelegate>

@end

@implementation KKOpenCVVideoSource {
    UIView *_parentView;
    
    UIImageView *_cameraView;
    
    FJFaceDetector *_faceDetector;
}

- (instancetype)initWithParentView:(UIView *)view
{
    self = [super init];
    if (self) {
        _parentView = view;
        
        [self createCameraView];
        _faceDetector = [[FJFaceDetector alloc] initWithCameraView:_cameraView scale:2.0];
        _faceDetector.delegate = self;
    }
    return self;
}

- (void)createCameraView {
    _cameraView = [[UIImageView alloc] initWithFrame:_parentView.bounds];
}

- (void)start {
    [_parentView addSubview:_cameraView];
    [_faceDetector startCapture];
}

- (void)stop {
    [_cameraView removeFromSuperview];
    [_faceDetector stopCapture];
}

- (void)faceDetectorResult:(NSArray<UIImage *> *)images {
    NSLog(@"%@", images);
}


@end
