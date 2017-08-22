//
//  KKSysAudioSource.m
//  SystemVedio
//
//  Created by sen.ke on 2017/8/18.
//  Copyright © 2017年 sen.ke. All rights reserved.
//

#import "KKSysAudioSource.h"
#import <AVFoundation/AVFoundation.h>

@interface KKSysAudioSource()

@end

@implementation KKSysAudioSource {
    AVAudioSession *_session;
    AudioComponent _component;
    AudioComponentInstance _outInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setAudioSession];
    }
    return self;
}

- (void)start {
    AudioOutputUnitStart(_outInstance);
}

- (void)stop {
    AudioOutputUnitStop(_outInstance);
}

- (void)setAudioSession {
    // 创建 AVAudioSession
    _session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    if (error) {
        NSLog(@"初始化音频设备失败");
        error = nil;
    }
    
    [_session setMode:AVAudioSessionModeVideoRecording error:&error];
    if (error) {
        NSLog(@"AudioSource setModeError");
        error = nil;
    }
    
    [_session setActive:YES error:&error];
    if (error) {
        NSLog(@"AudioSource setActiveError");
        error = nil;
    }
    
    // 描述音频单元
    AudioComponentDescription acd = {0};
    acd.componentType = kAudioUnitType_Output;
    acd.componentSubType = kAudioUnitSubType_RemoteIO;
    acd.componentManufacturer = kAudioUnitManufacturer_Apple;
    acd.componentFlags = 0;
    acd.componentFlagsMask = 0;
    //查找音频单元
    _component = AudioComponentFindNext(NULL, &acd);
    //获取音频单元实例
    OSStatus status = AudioComponentInstanceNew(_component, &_outInstance);
    if (status != noErr) {
        NSLog(@"AudioSource new AudioComponent error");
        status = noErr;
    }
    
    UInt32 flagOne = 1;
    AudioUnitSetProperty(_outInstance, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &flagOne, sizeof(flagOne));
    
    //音频流描述
    AudioStreamBasicDescription desc = {0};
    desc.mSampleRate = 44100;
    desc.mFormatID = kAudioFormatLinearPCM;//原始数据为PCM格式
    desc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    desc.mChannelsPerFrame = (UInt32)2; // 声道数
    desc.mFramesPerPacket = 1;//一个包里多少帧
    desc.mBitsPerChannel = 16;//16位
    desc.mBytesPerFrame = desc.mChannelsPerFrame * desc.mBitsPerChannel /8;//bytes -> bit / 8
    desc.mBytesPerPacket = desc.mFramesPerPacket * desc.mBytesPerFrame ;
    
    AURenderCallbackStruct cb;
    cb.inputProcRefCon = (__bridge void *)self;
    cb.inputProc = audioBufferCallBack;
    
    status =  AudioUnitSetProperty(_outInstance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &desc, sizeof(desc));
    
    if(status != noErr){
        NSLog(@"AudioUnitSetProperty StreamFormat error");
        status = noErr;
    }
    
    status = AudioUnitSetProperty(_outInstance, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 1, &cb, sizeof(cb));
    
    if(status != noErr){
        NSLog(@"AudioUnitSetProperty StreamFormat InputCallback error");
        status = noErr;
    }
    status = AudioUnitInitialize(_outInstance);
    
    [_session setPreferredSampleRate:44100 error:&error];
    
    if (error) {
        NSLog(@"AudioSource setPreferredSampleRate error");
        error = nil;
    }
}

#pragma mark -------回调---------
//static 内部函数
static OSStatus audioBufferCallBack(void *inRefCon,
                                    AudioUnitRenderActionFlags *ioActionFlags,
                                    const AudioTimeStamp *inTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList *ioData) {
    @autoreleasepool {
        KKSysAudioSource *source = (__bridge KKSysAudioSource *)inRefCon;
        if(!source) return -1;
        
        AudioBuffer buffer;
        buffer.mData = NULL;
        buffer.mDataByteSize = 0;
        buffer.mNumberChannels = 1;
        
        AudioBufferList buffers;
        buffers.mNumberBuffers = 1;
        buffers.mBuffers[0] = buffer;
        
        OSStatus status = AudioUnitRender(source->_outInstance,
                                          ioActionFlags,
                                          inTimeStamp,
                                          inBusNumber,
                                          inNumberFrames,
                                          &buffers);
        
        if(status == noErr) {
//            if([source.delegate respondsToSelector:@selector(audioSource:didOutputAudioBufferList:)]){
//                [source.delegate audioSource:source didOutputAudioBufferList:buffers];
//            }
        }
        return status;
    }
}

- (void)dealloc {
    [self stop];
    AudioComponentInstanceDispose(_outInstance);
}



@end
