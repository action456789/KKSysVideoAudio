//
//  NSFileManager+SKS.h
//  SKS_Collection
//
//  Created by KeSen on 7/21/16.
//  Copyright © 2016 SenKe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (SKS)

#define kHomeDirectory NSHomeDirectory()
#define kDocumentDirectory NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
#define kLibraryDirectory NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject
#define kCacheDirectory NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTempDirectory NSTemporaryDirectory()

+ (void)createFileWithDirectory:(NSString *)directery
                       withName:(NSString *)fileName
                        success:(void (^)(NSString *newFilePath))success
                        failure:(void (^)(NSError *error))failure;

+ (void)createFoldWithDirectory:(NSString *)directery
                   withFoldName:(NSString *)name
                        success:(void (^)(NSString *newFoldDirectory))success
                        failure:(void (^)(NSError *error))failure;

+ (void)deleteFileOrFoldWithDirectery:(NSString *)directery
                              Success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure;

@end
