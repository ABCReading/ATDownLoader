//
//  ATViewController.m
//  ATDownLoader
//
//  Created by Spaino on 12/24/2018.
//  Copyright (c) 2018 Spaino. All rights reserved.
//

#import "ATViewController.h"
#import <ATDownLoader/ATDownLoaderManager.h>
#import "SSZipArchive/SSZipArchive.h"

@interface ATViewController ()
@property (nonatomic, strong) NSURL *downdURL;
@end

@implementation ATViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.downdURL = [NSURL URLWithString:@"https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.1.dmg"];
}

- (IBAction)startAndContnue:(id)sender {
    [[ATDownLoaderManager shareInstance] downLoadWithURL:self.downdURL
                                          cacheDirectory:@"QQ"
                                                fileInfo:^(long long totalFileSize) {
                                                    NSLog(@"totalFileSize==========>%lld", totalFileSize);
    } success:^(NSString *cachePath, long long totalFileSize) {
        NSLog(@"%@++++++%lld", cachePath, totalFileSize);
        BOOL isUnzip = [SSZipArchive unzipFileAtPath:cachePath
                                          toDestination:[cachePath stringByDeletingLastPathComponent]];
        if (isUnzip) {
            [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
        }
    } fail:^(NSString *errorMsg) {
        NSLog(@"errorMsg========%@", errorMsg);
    } progress:^(float progress) {
        NSLog(@"progress========%lf", progress);
    } state:^(ATDownLoaderState state) {
        NSLog(@"state-----------%lu", state);
    }];
}

- (IBAction)pause:(id)sender {
    [[ATDownLoaderManager shareInstance] pauseWithURL:self.downdURL];
}

- (IBAction)cancel:(id)sender {
    [[ATDownLoaderManager shareInstance] cancelWithURL:self.downdURL];
}

@end
