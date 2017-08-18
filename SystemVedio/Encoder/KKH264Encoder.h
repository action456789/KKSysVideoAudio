//
//  KKVideoEncoder.h
//  SystemVedio
//
//  Created by sen.ke on 2017/7/22.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KKVideoConfig.h"

@class KKH264Encoder;

@protocol KKH264EncoderDeleagte <NSObject>

- (void)h264Encoder:(KKH264Encoder *)encoder didGetSps:(NSData *)spsData pps:(NSData *)ppsData timestamp:(uint64_t)timestamp;

- (void)h264Encoder:(KKH264Encoder *)encoder didEncodeFrame:(NSData *)data timestamp:(uint64_t)timestamp isKeyFrame:(BOOL)isKeyFrame;

@end

@interface KKH264Encoder : NSObject

@property (nonatomic,weak) id<KKH264EncoderDeleagte> delegate;

+ (instancetype)encoderWithConfig:(KKVideoConfig *)config;

- (void)stopEncoder;

- (void)encodeVideoData:(CVPixelBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp;

@end
