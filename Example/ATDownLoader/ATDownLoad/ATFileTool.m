//
//  ATFileTool.m
//  ATDownLoad
//
//  Created by Spaino on 12/24/2018.
//  Copyright © 2016年 Spaino. All rights reserved.
//

#import "ATFileTool.h"

// 沙盒cache路径
static inline NSString *kCachePath() {
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}

// 沙盒临时文件路径
static inline NSString *kTmpPath () {
    return NSTemporaryDirectory();
}

@implementation ATFileTool

+ (BOOL)isExistsWithCacheDirectory:(NSString *)cacheDirectory
                          fileName:(NSString *)fileName {
    NSString *fullCachePath = [self getFullCachePathWithDirectory:cacheDirectory
                                                         fileName:fileName];
    return [self isExistsWithFile:fullCachePath];
}

+ (BOOL)isExistsWithFile:(NSString *)filePath {
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return result;
}

+ (long long)fileSizeWithCacheDirectory:(NSString *)cacheDirectory
                               fileName:(NSString *)fileName {
    NSString *fullCachePath = [self getFullCachePathWithDirectory:cacheDirectory
                                                         fileName:fileName];
    return [self fileSizeWithPath:fullCachePath];
    
}

+ (long long)fileSizeWithPath:(NSString *)filePath {

    // 如果路径不存在, 返回0
    if (![self isExistsWithFile:filePath]) {
        return 0;
    }

    NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    long long fileSize = [fileInfoDic[NSFileSize] longLongValue];
    return fileSize;
}


+ (void)moveFilePath:(NSString *)fromPath toFilePath:(NSString *)toPath {
    // 如果路径不存在, 返回0
    if (![self isExistsWithFile:fromPath]) {
        return;
    }
    
    if (!(toPath && toPath.length)) {
        return;
    }
    
    NSError *error;
    if (![self isExistsWithFile:toPath] && ![toPath pathExtension].length) {
        [[NSFileManager defaultManager] createDirectoryAtPath:toPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
        toPath = [toPath stringByAppendingPathComponent:fromPath.lastPathComponent];
        
    }
    
    BOOL isMoveSuccess = [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&error];
    NSLog(@"isMoveSuccess========>%d\nerror+++++++++%@", isMoveSuccess, error);
}

+ (void)removeFileAtPath: (NSString *)filePath {
    // 如果路径不存在, 返回0
    if (![self isExistsWithFile:filePath]) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];

}

+ (NSString *)getFullCachePathWithDirectory:(NSString *)cacheDirectory
                                   fileName:(NSString *)fileName {
    NSString *fullCachePath;
    if (cacheDirectory &&
        cacheDirectory.length &&
        [cacheDirectory isKindOfClass:NSString.class]) {
        fullCachePath = [kCachePath() stringByAppendingPathComponent:cacheDirectory];
    } else {
        fullCachePath = [kCachePath() stringByAppendingPathComponent:fileName];
    }
    return fullCachePath;
}

+ (NSString *)tmpFilePathWithURL:(NSURL *)url {
    return [kTmpPath() stringByAppendingPathComponent:url.lastPathComponent];
}

@end
