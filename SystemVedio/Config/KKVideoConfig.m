//
//  KKVideoConfig.m
//  SystemVedio
//
//  Created by sen.ke on 2017/7/25.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import "KKVideoConfig.h"

@implementation KKVideoConfig

+ (instancetype)defaultConfig {
    KKVideoConfig *config = [[self alloc] init];
    config.videoSize = CGSizeMake(480, 640);
    config.bitrate = 512 *1024;
    config.fps = 15;
    config.level = SGProfileLevel_H264_Baseline_AutoLevel;
    config.keyframeInterval = config.fps *2;
    return config;
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString string];
    [desc appendString:@"{\n"];
    [desc appendFormat:@"class: %@\n",[self class]];
    [desc appendFormat:@"videoSize:%@\n",NSStringFromCGSize(self.videoSize)];
    [desc appendFormat:@"bitRate:%d\n",self.bitrate];
    [desc appendFormat:@"fps:%d\n}",self.fps];
    return desc;
}
@end
