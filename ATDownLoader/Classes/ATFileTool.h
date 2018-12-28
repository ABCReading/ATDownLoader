//
//  ATFileTool.h
//  ATDownLoad
//
//  Created by Spaino on 12/24/2018.
//  Copyright © 2016年 Spaino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATFileTool : NSObject

+ (void)moveFilePath:(NSString *)fromPath toFilePath:(NSString *)toPath;

+ (void)removeFileAtPath:(NSString *)filePath;

+ (NSString *)getFullCachePathWithDirectory:(NSString *)cacheDirectory
                                   fileName:(NSString *)fileName;

+ (BOOL)isExistsWithFile:(NSString *)filePath;

+ (BOOL)isExistsWithCacheDirectory:(NSString *)cacheDirectory
                          fileName:(NSString *)fileName;

+ (long long)fileSizeWithPath:(NSString *)filePath;

+ (long long)fileSizeWithCacheDirectory:(NSString *)cacheDirectory
                               fileName:(NSString *)fileName;

+ (NSString *)tmpFilePathWithURL:(NSURL *)url;
@end
