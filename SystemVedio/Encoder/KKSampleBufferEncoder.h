//
//  KKSampleBufferEncoder.h
//  SystemVedio
//
//  Created by sen.ke on 2017/8/16.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface KKSampleBufferEncoder : NSObject

+ (NSData *)sampleBufferNV12ToI420:(CMSampleBufferRef)videoSample;

+ (UIImage *)imageFromSamplebufferY:(CMSampleBufferRef)sampleBuffer;

+ (UIImage *)imageFromSamplebuffer:(CMSampleBufferRef)sampleBuffer;

@end
