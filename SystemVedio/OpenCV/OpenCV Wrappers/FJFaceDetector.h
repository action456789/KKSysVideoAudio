//
//  CVCameraProvider.h
//  opencvtest
//
//  Created by Engin Kurutepe on 16/01/15.
//  Copyright (c) 2015 Fifteen Jugglers Software. All rights reserved.
//

#import <opencv2/highgui/cap_ios.h>
#import <UIKit/UIKit.h>

@protocol FJFaceDetectorDelegate <NSObject>

- (void)faceDetectorResult:(NSArray<UIImage *> *)images;

@end

@interface FJFaceDetector : NSObject

@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, assign) id<FJFaceDetectorDelegate> delegate;

- (instancetype)initWithCameraView:(UIImageView *)view scale:(CGFloat)scale;

- (void)startCapture;
- (void)stopCapture;

- (NSArray *)detectedFaces;
- (UIImage *)faceWithIndex:(NSInteger)idx;
@end
