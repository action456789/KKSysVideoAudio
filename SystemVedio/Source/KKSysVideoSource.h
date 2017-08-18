//
//  KKVideoSource.h
//  SystemVedio
//
//  Created by sen.ke on 2017/7/27.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKVideoSource.h"
#import <AVFoundation/AVFoundation.h>
@class KKSysVideoSource;

@protocol KKSysVideoSourceDelegate <NSObject>

@optional
- (void)sysVideoSource:(KKSysVideoSource *)videoSource didOutputUImage:(UIImage *)uiImage;

@end

typedef NS_ENUM(NSUInteger, KKVideoOutputType) {
    KKVideoOutputTypeNV12,
    KKVideoOutputType32BGRA,
};

@interface KKSysVideoSource : KKVideoSource

@property (nonatomic, weak) id <KKSysVideoSourceDelegate> delegate;

@property (nonatomic, assign) KKVideoOutputType videoOutputType;

- (instancetype)initWithParentView:(UIView *)view;

- (BOOL)isFrontCamera;

- (void)toggleCamera;

- (void)snapStillImageResult:(void (^)(UIImage *image))resultBlock;

@end
