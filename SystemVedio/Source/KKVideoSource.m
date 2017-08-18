//
//  KKVideoSource.m
//  SystemVedio
//
//  Created by sen.ke on 2017/7/27.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import "KKVideoSource.h"

@implementation KKVideoSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addNotification];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void) willEnterForeground {
    self.inBackground = NO;
}

-(void) didEnterBackground {
    self.inBackground = YES;
}

- (void)start {
    
}

- (void)stop {
    
}

@end
