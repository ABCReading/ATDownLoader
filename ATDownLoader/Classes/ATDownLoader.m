//
//  ATDownLoader.m
//  ATDownLoad
//
//  Created by Spaino on 12/24/2018.
//  Copyright © 2016年 Spaino. All rights reserved.
//

#import "ATDownLoader.h"
#import "ATFileTool.h"


@interface ATDownLoader()<NSURLSessionDataDelegate>
// 临时下载文件的大小
@property (nonatomic, assign) long long tmpFileSize;
// 文件下载的总大小
@property (nonatomic, assign) long long totalFileSize;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, weak) NSURLSessionDataTask *task;

// 文件的缓存路径
@property (nonatomic, copy) NSString *cacheFilePath;

// 文件的临时缓存路径
@property (nonatomic, copy) NSString *tmpFilePath;

// 文件输出流
@property (nonatomic, strong) NSOutputStream *outputStream;


@property (nonatomic, weak) NSURL *url;

// 当前文件的下载状态
@property (nonatomic, assign, readonly) ATDownLoaderState state;
// 当前文件的下载进度
@property (nonatomic, assign, readonly) float progress;

/** 文件下载信息的block */
@property (nonatomic, copy)  kATDownLoadInfoBlock downLoadInfoBlock;
/** 状态改变的block */
@property (nonatomic, copy)  kATDownLoadStateChangeBlock stateChangeBlock;
/** 进度改变的block */
@property (nonatomic, copy)  kATDownLoadProgressBlock progressBlock;
/** 下载成功的block */
@property (nonatomic, copy) kATDownLoadSuccessBlock successBlock;
/** 下载失败的block */
@property (nonatomic, copy) kATDownLoadFailBlock failBlock;

@property (nonatomic, strong) NSString *cacheDirectory;
@end

@implementation ATDownLoader
@synthesize state = _state;

// MARK: - 懒加载
- (NSURLSession *)session {
    if (!_session) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 5;
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"download"]
                                                 delegate:self
                                            delegateQueue:queue];
    }
    return _session;
}

// MARK: - 接口
- (NSString *)cachePathWithURL:(NSURL *)url {
    return [self.class cachePathWithCacheDirectory:self.cacheDirectory
                                               URL:url];
}

+ (NSString *)cachePathWithCacheDirectory:(NSString *)cacheDirectory
                                      URL: (NSURL *)url {
    NSString *cachePath = [ATFileTool getFullCachePathWithDirectory:cacheDirectory
                                                           fileName:url.lastPathComponent];
    if ([ATFileTool isExistsWithFile:cachePath]) {
        return cachePath;
    }
    return nil;
}

+ (long long)tmpCacheSizeWithURL:(NSURL *)url {
    NSString *tmpPath = [ATFileTool tmpFilePathWithURL:url];
    return  [ATFileTool fileSizeWithPath:tmpPath];
}

- (void)clearCacheWithURL:(NSURL *)url {
    [self.class clearCacheWithCacheDirectory:self.cacheFilePath URL:url];
}

+ (void)clearCacheWithCacheDirectory:(NSString *)cacheDirectory
                                 URL: (NSURL *)url {
    NSString *cachePath = [ATFileTool getFullCachePathWithDirectory:cacheDirectory
                                                           fileName:url.lastPathComponent];
    [ATFileTool removeFileAtPath:cachePath];
}

// 注意, 临时缓存的位置(未下载完毕的位置): tmp/MD5(urlStr)
// 正式缓存的位置: cache/cacheDirectory/url.lastCompent

- (void)downLoadWithURL:(NSURL *)url
         cacheDirectory:(NSString *)cacheDirectory
               fileInfo:(kATDownLoadInfoBlock)downLoadInfoBlock
                success:(kATDownLoadSuccessBlock)successBlock
                   fail:(kATDownLoadFailBlock)failBlock
               progress:(kATDownLoadProgressBlock)progressBlock
                  state:(kATDownLoadStateChangeBlock)stateBlock {
    self.url = url;
    self.cacheDirectory = cacheDirectory;
    self.downLoadInfoBlock = downLoadInfoBlock;
    self.successBlock = successBlock;
    self.failBlock = failBlock;
    self.progressBlock = progressBlock;
    self.stateChangeBlock = stateBlock;
    [self downLoadWithURL:url];
}


// 注意内部的容错处理, 如果被多次调用
// 需要根据当前的不同状态, 做不同的业务处理
- (void)downLoadWithURL:(NSURL *)url {
    // 文件下载完成后, 所在路径
    self.cacheFilePath = [ATFileTool getFullCachePathWithDirectory:self.cacheDirectory
                                                          fileName:url.lastPathComponent];

    if ([ATFileTool isExistsWithFile:self.cacheFilePath]) {

        if (self.downLoadInfoBlock) {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.downLoadInfoBlock([ATFileTool fileSizeWithPath:weakSelf.cacheFilePath]);
            });
        }
        self.state = ATDownLoaderStateSuccess;
        self.progress = 1.0;
        [self handleSuccessBlock];
        return;
    }

    // 如果正在下载, 则返回
    if (self.state == ATDownLoaderStateDowning) {
        return;
    }
    if (self.task && self.state == ATDownLoaderStatePause) {
        [self resume];
        return;
    }

    // 文件还没下载完成, 所在路径
    self.tmpFilePath = [ATFileTool tmpFilePathWithURL:url];
    self.tmpFileSize = [ATFileTool fileSizeWithPath:self.tmpFilePath];

    // 使用 tmpFileSize, 作为偏移量进行下载请求
    [self downLoadWithURL:url fromBytesOffset:self.tmpFileSize];
}

- (void)resume {
    // 此处坑: 如果连续点击了两次恢复, 则暂停需要点同样的次数
    // 解决方案; 通过状态进行判断
    if (self.task && self.state == ATDownLoaderStatePause) {
        [self.task resume];
        self.state = ATDownLoaderStateDowning;
    }
}

- (void)pause {
    // 此处坑: 如果连续点击了两次暂停, 则恢复需要点同样的次数
    // 解决方案; 通过状态进行判断
    if (self.state == ATDownLoaderStateDowning) {
        [self.task suspend];
        self.state = ATDownLoaderStatePause;
    }
}

// 取消请求并清空各种缓存数据
- (void)cancel {
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)cancelAndClearCache {
    [self cancel];

    // 清理缓存
    [ATFileTool removeFileAtPath:self.tmpFilePath];
}

// MARK: - 私有方法

- (void)setState:(ATDownLoaderState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    if (self.stateChangeBlock) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.stateChangeBlock(state);
        });
    }

    // 发送通知, 让外界监听状态改变
    if (self.url == nil) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadURLOrStateChangeNotification
                                                        object:nil
                                                      userInfo:@{@"state": @(self.state),
                                                                 @"url": self.url}];
}

- (void)setProgress:(float)progress {
    _progress = progress;
    if (self.progressBlock) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressBlock(progress);
        });
    }
}

- (void)setUrl:(NSURL *)url {
    if ([_url isEqual:url] || url == nil) {
        return;
    }
    _url = url;
    
    // 发送通知, 让外界监听状态改变
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadURLOrStateChangeNotification
                                                        object:nil
                                                      userInfo:@{@"state": @(self.state),
                                                                 @"url": self.url}];
}

/**
 根据URL地址, 和偏移量进行下载

 @param url    url
 @param offset 偏移量
 */
- (void)downLoadWithURL:(NSURL *)url fromBytesOffset:(long long)offset {
    // 创建一个请求, 设置缓存策略, 和请求的Range字段
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset]
   forHTTPHeaderField:@"Range"];
    self.task = [self.session dataTaskWithRequest:request];

    [self.task resume];
}


// MARK: - 代理

// 接收到响应之后做事情
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    // 获取文件总大小

//    "Content-Length" = 21574062; 本次请求的总大小
//    "Content-Range" = "bytes 0-21574061/21574062"; 本次请求的区间 开始字节-结束字节 / 总字节
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self.totalFileSize = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue];
    if (httpResponse.allHeaderFields[@"Content-Range"]) {
        NSString *rangeStr = httpResponse.allHeaderFields[@"Content-Range"] ;
        self.totalFileSize = [[[rangeStr componentsSeparatedByString:@"/"] lastObject] longLongValue];
        
    }
    
    if (self.downLoadInfoBlock) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.downLoadInfoBlock(weakSelf.totalFileSize);
        });
    }

    // 如果临时缓存已经足够了, 则, 直接移动文件到缓存路径下, 并取消本次请求
    if (self.tmpFileSize == self.totalFileSize) {
        [ATFileTool moveFilePath:self.tmpFilePath toFilePath:self.cacheFilePath];
        [self cancel];
        completionHandler(NSURLSessionResponseCancel);

        // 给外界返回结果
        NSLog(@"告诉外界, 已经下载完毕: %@", self.cacheFilePath);
        self.progress = 1.0;
        [self handleSuccessBlock];
        return;
    }

    if (self.tmpFileSize > self.totalFileSize) {
        // 删除缓存
        [ATFileTool removeFileAtPath:self.tmpFilePath];
        // 取消本次请求
        [self cancel];
        completionHandler(NSURLSessionResponseCancel);
        // 重新开始新的请求
        [self downLoadWithURL:dataTask.originalRequest.URL];
        return;
    }

    // 开始创建文件输出流, 开始接收数据
    NSLog(@"应该直接接收数据");
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tmpFilePath
                                                          append:YES];
    [self.outputStream open];

    self.state = ATDownLoaderStateDowning;

    // allow: 代表, 继续接收数据
    // cancel: 代表, 取消本次请求
    completionHandler(NSURLSessionResponseAllow);

}


- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    self.tmpFileSize += data.length;
    self.progress = 1.0 * self.tmpFileSize / self.totalFileSize;
    // 接收数据, 会调用多次
    [self.outputStream write:data.bytes maxLength:data.length];
}


- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"下载出错或取消--%@", error);
        self.state = ATDownLoaderStateFailed;
        if (self.failBlock) {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.failBlock(error.localizedDescription);
            });
        }
    } else {
        NSLog(@"下载成功");
        [ATFileTool moveFilePath:self.tmpFilePath toFilePath:self.cacheFilePath];
        self.state = ATDownLoaderStateSuccess;
        [self handleSuccessBlock];
    }

    // 释放资源
    [self.outputStream close];
    self.outputStream = nil;
    [self cancel];
}

- (void)handleSuccessBlock {
    if (self.successBlock) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *targetPath = weakSelf.cacheFilePath;
            if (![weakSelf.cacheFilePath pathExtension].length) {
                targetPath = [targetPath stringByAppendingPathComponent:self.url.lastPathComponent];
            }
            weakSelf.successBlock(targetPath, weakSelf.totalFileSize);
        });
    }
}

@end
