//
//  ViewController.m
//  SystemVedio
//
//  Created by sen.ke on 2017/7/21.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSFileManager+File.h"
#import "KKSysVideoSource.h"
#import "KKGPUImageVideoSource.h"
#import "KKOpenCVVideoSource.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *openCVView;
@property (weak, nonatomic) IBOutlet UIImageView *portrait;

@end

@implementation ViewController {
    FILE *fp;
    const char *file;
    
    KKSysVideoSource *_videoSource;
    KKGPUImageVideoSource *_giVideoSource;
    KKOpenCVVideoSource *_opencvVideoSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self systemCamera];
    
//    [self gpuImageCamera];
    
//    [self opencvCamera];
}

- (void)opencvCamera {
    _opencvVideoSource = [[KKOpenCVVideoSource alloc] initWithParentView:self.openCVView];
    [_opencvVideoSource start];
}

- (void)gpuImageCamera {
    _giVideoSource = [[KKGPUImageVideoSource alloc] initWithParentView:self.view];
    [_giVideoSource start];
}

- (void)systemCamera {
    _videoSource = [[KKSysVideoSource alloc] initWithParentView:self.view];
    [_videoSource start];
}

- (IBAction)startAction:(id)sender {
    file = [[kCacheDirectory stringByAppendingPathComponent:@"test.yuv"] UTF8String];
    fp = fopen(file, "wb+");
    if (fp == NULL) {
        printf("打开文件失败");
    }
    
    [_videoSource start];
}

- (IBAction)stopAction:(id)sender {
    [_videoSource stop];
    
    fclose(fp);
}

@end
