//
//  KKVideoSource.m
//  SystemVedio
//
//  Created by sen.ke on 2017/7/27.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import "KKSysVideoSource.h"

#import "KKSampleBufferEncoder.h"
#import <CoreMedia/CoreMedia.h>
#import "UIImage+IFly.h"

#define NOW (CACurrentMediaTime() * 1000)

@interface KKSysVideoSource()<AVCaptureVideoDataOutputSampleBufferDelegate>

//前后摄像头
@property (nonatomic, strong) AVCaptureDeviceInput *frontCamera;
@property (nonatomic, strong) AVCaptureDeviceInput *backCamera;
//当前使用的视频设备
@property (nonatomic, weak)   AVCaptureDeviceInput *videoInputDevice;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

// 图片输出
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation KKSysVideoSource {
    uint64_t _startTime;
    
    UIView *_parentView;
    
    dispatch_queue_t _captureQueue;
}

- (instancetype)initWithParentView:(UIView *)view
{
    self = [super init];
    if (self) {
        _parentView = view;
        _videoOutputType = KKVideoOutputTypeNV12;
    }
    return self;
}

- (void)start {
    [self createCaptureDevice];
    [self createOutput];
    [self createCaptureSession];
    [self createPreviewLayer];
    
    _startTime = NOW;
}

- (void)stop {
    [self teardownCaptureSession];
    [self.previewLayer removeFromSuperlayer];
}

// 初始化视频设备
- (void)createCaptureDevice{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionFront) {
            self.frontCamera = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        } else if (device.position == AVCaptureDevicePositionBack) {
            self.backCamera =[AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        }
    }
    
    self.videoInputDevice = self.frontCamera;
}

- (void)createOutput {
    _captureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.videoDataOutput setSampleBufferDelegate:self queue:_captureQueue];
    // 抛弃过期帧，保证实时性
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    // 设置输出格式
    if (self.videoOutputType == KKVideoOutputTypeNV12) {
        // 设置输出格式为 yuv420, u和v表示色差(u和v也被称为：Cb－蓝色差，Cr－红色差)
        self.videoDataOutput.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
        
    } else if (self.videoOutputType == KKVideoOutputType32BGRA) {
        self.videoDataOutput.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    }
    
    // 添加图片输出
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG};
    [self.stillImageOutput setOutputSettings:outputSettings];
}

// 创建会话
-(void)createCaptureSession {
    self.captureSession = [[AVCaptureSession alloc] init];
    
    //修改配置
    [self.captureSession beginConfiguration];
    
    if ([self.captureSession canAddInput:self.videoInputDevice]) {
        [self.captureSession addInput:self.videoInputDevice];
    }
    
    if([self.captureSession canAddOutput:self.videoDataOutput]){
        [self.captureSession addOutput:self.videoDataOutput];
    }
    
    if ([self.captureSession canAddOutput:self.stillImageOutput]) {
        [self.captureSession addOutput:self.stillImageOutput];
    }
    
    //设置预览分辨率
    //这个分辨率有一个值得注意的点：
    //iphone4录制视频时 前置摄像头只能支持 480*640 后置摄像头不支持 540*960 但是支持 720*1280
    //诸如此类的限制，所以需要写一些对分辨率进行管理的代码。
    //目前的处理是，对于不支持的分辨率会抛出一个异常
    //但是这样做是不够、不完整的，最好的方案是，根据设备，提供不同的分辨率。
    //如果必须要用一个不支持的分辨率，那么需要根据需求对数据和预览进行裁剪，缩放。
    if (![self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        @throw [NSException exceptionWithName:@"Not supported captureSessionPreset" reason:[NSString stringWithFormat:@"captureSessionPreset is [%@]", AVCaptureSessionPreset640x480] userInfo:nil];
    }
    
    self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    [self.captureSession commitConfiguration];
    
    [self.captureSession startRunning];
}

//创建预览
-(void)createPreviewLayer {
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.frame = _parentView.bounds;
    [_parentView.layer addSublayer:self.previewLayer];
}

-(void)teardownCaptureSession {
    if (self.captureSession) {
        [self.captureSession removeInput:self.videoInputDevice];
        [self.captureSession removeOutput:self.videoDataOutput];
    }
    self.captureSession = nil;
}

- (BOOL)isFrontCamera {
    return self.videoInputDevice.device.position == AVCaptureDevicePositionFront;
}

// 切换摄像头
- (void)toggleCamera {
    AVCaptureDeviceInput *willToggledInput;
    switch (self.videoInputDevice.device.position) {
        case AVCaptureDevicePositionUnspecified:
            willToggledInput = self.frontCamera;
            break;
        case AVCaptureDevicePositionBack:
            willToggledInput = self.frontCamera;
            break;
        case AVCaptureDevicePositionFront:
            willToggledInput = self.backCamera;
            break;
    }
    
    [self.captureSession beginConfiguration];
    
    [self.captureSession removeInput:self.videoInputDevice];
    if ([self.captureSession canAddInput:willToggledInput]) {
        [self.captureSession addInput:willToggledInput];
    }
    
    self.videoInputDevice = willToggledInput;
    
    [self.captureSession commitConfiguration];
}

- (void)snapStillImageResult:(void (^)(UIImage *image))resultBlock {
    // 屏蔽快门声音
    static SystemSoundID soundID = 0;
    if (soundID == 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"photoShutter2" ofType:@"caf"];
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    }
    AudioServicesPlaySystemSound(soundID);
    
    __block UIImage *image = nil;
    
    AVCaptureConnection *videoConnection = [self videoConnection];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         if (imageDataSampleBuffer) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             image = [[UIImage alloc] initWithData:imageData];
             // 水平翻转照片
             image = [image horizontalFlip];
             
             resultBlock(image);
         }
     }];
}

- (AVCaptureConnection *)videoConnection {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    return videoConnection;
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

// 默认情况下，iPhone 6p为30 fps，意味着如下函数每秒调用30次
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    // kCVPixelFormatType_32BGRA -> UIImage
    if ([self.delegate respondsToSelector:@selector(sysVideoSource:didOutputUImage:)]) {
        if (KKVideoOutputType32BGRA) {
            UIImage *image = [KKSampleBufferEncoder imageFromSamplebuffer:sampleBuffer];
            [self.delegate sysVideoSource:self didOutputUImage:image];
        }
    }
}

@end
