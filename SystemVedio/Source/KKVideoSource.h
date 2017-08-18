//
//  KKVideoSource.h
//  SystemVedio
//
//  Created by sen.ke on 2017/7/27.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKVideoSource : NSObject

@property (nonatomic, assign) BOOL inBackground;

- (void)start;
- (void)stop;

@end
