//
//  NSFileManager+SKS.m
//  SKS_Collection
//
//  Created by KeSen on 7/21/16.
//  Copyright © 2016 SenKe. All rights reserved.
//

#import "NSFileManager+File.h"

#define PerformBlock(blockName, ...) \
    if (blockName) { \
    blockName (__VA_ARGS__); \
}

@implementation NSFileManager (SKS)

//返回单个文件的大小
- (long long)fileSizeInPath:(NSString *)path
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        return [[manager attributesOfItemAtPath:path error:nil] fileSize];
    }
    return 0;
}

//多线程计算单个文件的大小
- (void)countFileSizeWithFileName:(NSString *)fileName
                           result:(void (^)(long long size) )result
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager* manager = [NSFileManager defaultManager];
        long long fileSize = 0;
        if ([manager fileExistsAtPath:fileName]) {
            fileSize = [[manager attributesOfItemAtPath:fileName error:nil] fileSize];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            result(fileSize);
        });
    });
}

//遍历文件夹获得文件夹大小
- (NSString *)folderSizeInPath:(NSString *)path
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:path]) return 0;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:path] objectEnumerator];
    NSString *fileName;
    long long folderSize = 0;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil) {
        NSString *fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeInPath:fileAbsolutePath];
    }
    
    // 需要注意:iOS中1G == 1000Mb ==1000 * 1000kb == 1000 * 1000 * 1000b
    if (folderSize >= pow(10, 12)) {
        return [NSString stringWithFormat:@"%.1fTB", folderSize/pow(10, 12)];
    }else if (folderSize >= pow(10, 9)) {
        return [NSString stringWithFormat:@"%.1fGB", folderSize/pow(10, 9)];
    }else if (folderSize >= pow(10, 6)) {
        return [NSString stringWithFormat:@"%.1fMB", folderSize/pow(10, 6)];
    }if (folderSize >= pow(10, 3)) { //KB
        return  [NSString stringWithFormat:@"%fKB", folderSize/pow(10, 3)];
    }else {
        return [NSString stringWithFormat:@"%.1lldB", folderSize];
    }
}

// 多线程计算文件夹的大小
- (void)countFoldSizeWithFoldPath:(NSString *)path
                           result:(void (^)(long long size))result
{
    __block long long size = 0;
    
    // 文件属性
    NSFileManager* manager = [NSFileManager defaultManager];
    
    NSDictionary *attrs = [manager attributesOfItemAtPath:path error:nil];
    // 如果这个文件或者文件夹不存在,或者路径不正确;
    if (attrs == nil) {
        result(0);
    }
    
    if ([attrs.fileType isEqualToString:NSFileTypeDirectory]) { // 如果是文件夹
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSFileManager* manager = [NSFileManager defaultManager];
            if (![manager fileExistsAtPath:path]) {
                size = 0;
            }
            
            NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:path] objectEnumerator];
            NSString *fileName;
            
            while ((fileName = [childFilesEnumerator nextObject]) != nil) {
                NSString *fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
                size += [self fileSizeInPath:fileAbsolutePath];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                result(size);
            });
        });
    }
}

#pragma mark - public method

// 多线程计算文件夹或文件的大小
- (void)countFileOrFoldSizeWith:(NSString *)directory
                         result:(void (^)(long long size))result
{
    NSFileManager* manager = [NSFileManager defaultManager];
    NSDictionary *attrs = [manager attributesOfItemAtPath:directory error:nil];
    
    // is fold
    if ([attrs.fileType isEqualToString:NSFileTypeDirectory]) {
        [self countFoldSizeWithFoldPath:directory result:result];
    } else { // is file
        [self countFileSizeWithFileName:directory result:result];
    }
}

// 创建文件夹
+ (void)createFoldWithDirectory:(NSString *)directery
                   withFoldName:(NSString *)name
                        success:(void (^)(NSString *newFoldDirectory))success
                        failure:(void (^)(NSError *error))failure
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *newFoldDirectory = [directery stringByAppendingPathComponent:name];;
    
    NSError *error = nil;
    BOOL result = [fileManager createDirectoryAtPath:newFoldDirectory
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:&error];
    if (result) {
        PerformBlock(success, newFoldDirectory);
    } else {
        PerformBlock(failure, error);
    }
}

// 创建文件
+ (void)createFileWithDirectory:(NSString *)directery
                       withName:(NSString *)fileName
                        success:(void (^)(NSString *newFilePath))success
                        failure:(void (^)(NSError *error))failure
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *newFilePath = newFilePath = [directery stringByAppendingPathComponent:fileName];;
    
    BOOL result = [fileManager createFileAtPath:newFilePath contents:nil attributes:nil];
    if (result) {
        PerformBlock(success, newFilePath);
    } else {
        NSDictionary *userInfo = @{@"msg": @"创建文件失败"};
        NSError *domainError = [NSError errorWithDomain:@"SuperKeSen" code:10001 userInfo:userInfo];
        PerformBlock(failure, domainError);
    }
}

// 删除文件/文件夹
+ (void)deleteFileOrFoldWithDirectery:(NSString *)directery
                              Success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    if (![fileManager fileExistsAtPath:directery]) {
        NSDictionary *userInfo = @{@"msg": @"文件/文件夹不存在"};
        NSError *domainError = [NSError errorWithDomain:@"SuperKeSen" code:10000 userInfo:userInfo];
        PerformBlock(failure, domainError);
    }
    
    NSError *error = nil;
    BOOL result = [fileManager removeItemAtPath:directery error:&error];
    if (result) {
        PerformBlock(success);
    } else {
        PerformBlock(failure, error);
    }
}

@end
