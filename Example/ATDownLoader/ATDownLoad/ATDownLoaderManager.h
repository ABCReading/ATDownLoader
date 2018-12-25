//
//  ATDownLoaderManager.h
//  ATDownLoad
//
//  Created by Spaino on 12/24/2018.
//  Copyright © 2016年 Spaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATDownLoader.h"

@interface ATDownLoaderManager : NSObject


+ (instancetype)shareInstance;


- (ATDownLoader *)getDownLoaderWithURL: (NSURL *)url;

- (ATDownLoader *)downLoadWithURL:(NSURL *)url
                   cacheDirectory:(NSString *)cacheDirectory
                         fileInfo:(kATDownLoadInfoBlock)downLoadInfoBlcok
                          success:(kATDownLoadSuccessBlock)successBlock
                             fail:(kATDownLoadFailBlock)failBlock
                         progress:(kATDownLoadProgressBlock)progressBlock
                            state:(kATDownLoadStateChangeBlock)stateBlock;

- (void)pauseWithURL: (NSURL *)url;


- (void)resumeWithURL: (NSURL *)url;


- (void)cancelWithURL: (NSURL *)url;


- (void)cancelAndClearCacheWithURL: (NSURL *)url;

- (void)pauseAll;

- (void)resumeAll;





@end
