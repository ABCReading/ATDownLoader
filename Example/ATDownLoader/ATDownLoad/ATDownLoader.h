//
//  ATDownLoader.h
//  ATDownLoad
//
//  Created by Spaino on 12/24/2018.
//  Copyright © 2016年 Spaino. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDownLoadURLOrStateChangeNotification @"downLoadURLOrStateChangeNotification"

typedef enum : NSUInteger {
    /** 下载暂停 */
    ATDownLoaderStatePause,
    /** 正在下载 */
    ATDownLoaderStateDowning,
    /** 已经下载 */
    ATDownLoaderStateSuccess,
    /** 下载失败 */
    ATDownLoaderStateFailed
} ATDownLoaderState;

typedef void(^kATDownLoadInfoBlock)(long long totalFileSize);
typedef void(^kATDownLoadSuccessBlock)(NSString *cachePath, long long totalFileSize);
typedef void(^kATDownLoadFailBlock)(NSString *errorMsg);
typedef void(^kATDownLoadStateChangeBlock)(ATDownLoaderState state);
typedef void(^kATDownLoadProgressBlock)(float progress);

@interface ATDownLoader : NSObject
// 根据url查找对应缓存, 如果不存在, 则返回0
// 正在下载或下载一半的内容都会只放在temp路径下,所以只需要class访问就可以拿到!
+ (long long)tmpCacheSizeWithURL:(NSURL *)url;


/**
 下面的加减号方法设计哲学:
 如果你单纯地只是需要去查看没有中间文件夹的下载内容,或者已经有ATDownLoader实例,那么它会调用到类方法去获取到结果;
 如果你一开始没有ATDownLoader实例,只是想去查看下当前URL及保存文件夹的内容,那么你就需要给我完整的信息.
 */
// 根据URL(和文件夹路径)获取当前存储路径
- (NSString *)cachePathWithURL:(NSURL *)url;
+ (NSString *)cachePathWithCacheDirectory:(NSString *)cacheDirectory
                                      URL:(NSURL *)url;
// 根据URL(和文件夹路径)清除当前存储内容
- (void)clearCacheWithURL:(NSURL *)url;
+ (void)clearCacheWithCacheDirectory:(NSString *)cacheDirectory
                                 URL:(NSURL *)url;

// 根据url地址, 进行下载
- (void)downLoadWithURL:(NSURL *)url
         cacheDirectory:(NSString *)cacheDirectory
               fileInfo:(kATDownLoadInfoBlock)downLoadInfoBlcok
                success:(kATDownLoadSuccessBlock)successBlock
                   fail:(kATDownLoadFailBlock)failBlock
               progress:(kATDownLoadProgressBlock)progressBlock
                  state:(kATDownLoadStateChangeBlock)stateBlock;


// 继续
- (void)resume;

// 暂停
- (void)pause;

// 取消
- (void)cancel;

// 取消下载, 并删除缓存
- (void)cancelAndClearCache;

@end
