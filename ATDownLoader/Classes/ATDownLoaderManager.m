//
//  ATDownLoaderManager.m
//  ATDownLoad
//
//  Created by Spaino on 12/24/2018.
//  Copyright © 2016年 Spaino. All rights reserved.
//

#import "ATDownLoaderManager.h"
#import "NSString+ATMD5.h"

@interface ATDownLoaderManager()

@property (nonatomic, strong) NSMutableDictionary <NSString *, ATDownLoader *>*downLoaderDic;

@end

@implementation ATDownLoaderManager

static ATDownLoaderManager *_shareInstance;

+ (instancetype)shareInstance {

    if (!_shareInstance) {
        _shareInstance = [[ATDownLoaderManager alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [super allocWithZone:zone];
    });

    return _shareInstance;

}


- (NSMutableDictionary *)downLoaderDic {
    if (!_downLoaderDic) {
        _downLoaderDic = [NSMutableDictionary dictionary];
    }
    return _downLoaderDic;
}

- (ATDownLoader *)getDownLoaderWithURL:(NSURL *)url {
    NSString *md5Name = [url.absoluteString MD5Str];
    ATDownLoader *downLoader = self.downLoaderDic[md5Name];
    return downLoader;
}

- (ATDownLoader *)downLoadWithURL:(NSURL *)url
                   cacheDirectory:(NSString *)cacheDirectory
                         fileInfo:(kATDownLoadInfoBlock)downLoadInfoBlcok
                          success:(kATDownLoadSuccessBlock)successBlock
                             fail:(kATDownLoadFailBlock)failBlock
                         progress:(kATDownLoadProgressBlock)progressBlock
                            state:(kATDownLoadStateChangeBlock)stateBlock {

    NSString *md5Name = [url.absoluteString MD5Str];
    ATDownLoader *downLoader = self.downLoaderDic[md5Name];
    if (downLoader == nil) {
        downLoader = [[ATDownLoader alloc] init];
        [self.downLoaderDic setValue:downLoader forKey:md5Name];
    }

    __weak typeof(self) weakSelf = self;
    [downLoader downLoadWithURL:url
                 cacheDirectory:cacheDirectory
                       fileInfo:downLoadInfoBlcok
                        success:^(NSString *cachePath,
                                  long long totalFileSize) {
                            if (successBlock) {
                                successBlock(cachePath, totalFileSize);
                            }
                            [weakSelf.downLoaderDic removeObjectForKey:md5Name];
    
                        } fail:failBlock
                       progress:progressBlock
                          state:stateBlock];
    return downLoader;
}


- (void)pauseWithURL:(NSURL *)url {
    NSString *md5Name = [url.absoluteString MD5Str];
    ATDownLoader *downLoader = self.downLoaderDic[md5Name];
    [downLoader pause];
}


- (void)resumeWithURL:(NSURL *)url {
    NSString *md5Name = [url.absoluteString MD5Str];
    ATDownLoader *downLoader = self.downLoaderDic[md5Name];
    [downLoader resume];
}


- (void)cancelWithURL:(NSURL *)url {
    NSString *md5Name = [url.absoluteString MD5Str];
    ATDownLoader *downLoader = self.downLoaderDic[md5Name];
    [downLoader cancel];
}


- (void)cancelAndClearCacheWithURL:(NSURL *)url {
    NSString *md5Name = [url.absoluteString MD5Str];
    ATDownLoader *downLoader = self.downLoaderDic[md5Name];
    [downLoader cancelAndClearCache];
}

- (void)pauseAll {
    [[self.downLoaderDic allValues] makeObjectsPerformSelector:@selector(pause)];
}

- (void)resumeAll {
    [[self.downLoaderDic allValues] makeObjectsPerformSelector:@selector(resume)];
}



@end
