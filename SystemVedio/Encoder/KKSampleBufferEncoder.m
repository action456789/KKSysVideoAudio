//
//  KKSampleBufferEncoder.m
//  SystemVedio
//
//  Created by sen.ke on 2017/8/16.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import "KKSampleBufferEncoder.h"
#import <CoreVideo/CoreVideo.h>

@implementation KKSampleBufferEncoder

// CMSampleBufferRef -> UIImage，UIImage只包含Y通道信息，为灰度图片
// sampleBuffer 类型必须为 kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
+ (UIImage *)imageFromSamplebufferY:(CMSampleBufferRef)sampleBuffer {
    CFRetain(sampleBuffer);
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGImageAlphaNone);

    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // 解决图片旋转了90度问题
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];

    CGImageRelease(quartzImage);
    
    CFRelease(sampleBuffer);
    
    return image;
}

// CMSampleBufferRef -> UIImage，图片为彩色
// sampleBuffer 类型必须为 kCVPixelFormatType_32BGRA
+ (UIImage *)imageFromSamplebuffer:(CMSampleBufferRef)sampleBuffer {
    if (sampleBuffer == nil) {
        NSLog(@"【KKSampleBufferEncoder】sampleBuffer cannot be nil");
        return nil;
    }
    
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == nil) {
        NSLog(@"【KKSampleBufferEncoder】pixelBuffer cannot be nil");
        return nil;
    }
    
    CFRetain(pixelBuffer);

    // Lock address，锁定数据，应该是多线程防止重入操作。
    if(CVPixelBufferLockBaseAddress(pixelBuffer, 0) != kCVReturnSuccess){
        NSLog(@"【KKSampleBufferEncoder】encode video lock base address failed");
        return nil;
    }
    
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    NSLog(@"【KKSampleBufferEncoder】w: %zu h: %zu bytesPerRow:%zu", width, height, bytesPerRow);
    
    if (width == 0 || height == 0) {
        NSLog(@"【KKSampleBufferEncoder】: 宽高不能为0");
        return nil;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress,
                                                 width,
                                                 height,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little
                                                 | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);

    UIImage *image = [UIImage imageWithCGImage:quartzImage 
                                         scale:1.0f 
                                   orientation:UIImageOrientationRight];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    CGImageRelease(quartzImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CFRelease(pixelBuffer);
    
    return image;
}

// CMSampleBuffer NV12 to I420
// NV12(即 kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange 或者 KKVideoOutputTypeNV12)

+ (NSData *)sampleBufferNV12ToI420:(CMSampleBufferRef)videoSample {
    CFRetain(videoSample);
    
    // 获取yuv数据
    // 通过CMSampleBufferGetImageBuffer方法，获得CVImageBufferRef。
    // 这里面就包含了yuv420数据的指针
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(videoSample);

    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t pixelWidth = CVPixelBufferGetWidth(pixelBuffer);
    size_t pixelHeight = CVPixelBufferGetHeight(pixelBuffer);
    //yuv中的y所占字节数
    size_t y_size = pixelWidth * pixelHeight;
    //yuv中的u和v分别所占的字节数
    size_t uv_size = y_size / 4;
    
    uint8_t *yuv_frame = malloc(uv_size * 2 + y_size);
    
    //获取CVImageBufferRef中的y数据
    uint8_t *y_frame = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    memcpy(yuv_frame, y_frame, y_size);
    
    //获取CMVImageBufferRef中的uv数据
    uint8_t *uv_frame = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    memcpy(yuv_frame + y_size, uv_frame, uv_size * 2);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    NSData *nv12Data = [NSData dataWithBytesNoCopy:yuv_frame length:y_size + uv_size * 2];

    CFRelease(videoSample);
    
    return nv12Data;
}

@end
