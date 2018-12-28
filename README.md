# ATDownLoader

[![CI Status](https://img.shields.io/travis/Spaino/ATDownLoader.svg?style=flat)](https://travis-ci.org/Spaino/ATDownLoader)
[![Version](https://img.shields.io/cocoapods/v/ATDownLoader.svg?style=flat)](https://cocoapods.org/pods/ATDownLoader)
[![License](https://img.shields.io/cocoapods/l/ATDownLoader.svg?style=flat)](https://cocoapods.org/pods/ATDownLoader)
[![Platform](https://img.shields.io/cocoapods/p/ATDownLoader.svg?style=flat)](https://cocoapods.org/pods/ATDownLoader)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

- usage

  ``````objective-c
  - (void)viewDidLoad {
      [super viewDidLoad];
  	// set download URL
      self.downdURL = [NSURL URLWithString:@"https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.1.dmg"];
  }
  
  // start download action
  - (IBAction)startAndContnue:(id)sender {
      /**
      * downLoadWithURL 
      * download success target cacheDirectory
      * fileInfo: response block, it's file info
      * success : download success block
      * fail    : download fail block
      * progress: downloading progress..
      * state   : download state
      */
      [[ATDownLoaderManager shareInstance] downLoadWithURL:self.downdURL
                                            cacheDirectory:@"QQ"
                                                  fileInfo:^(long long totalFileSize) {                                                    NSLog(@"totalFileSize==========>%lld", totalFileSize);
      } success:^(NSString *cachePath, long long totalFileSize) {
          NSLog(@"%@++++++%lld", cachePath, totalFileSize);
      } fail:^(NSString *errorMsg) {
          NSLog(@"errorMsg========%@", errorMsg);
      } progress:^(float progress) {
          NSLog(@"progress========%lf", progress);
      } state:^(ATDownLoaderState state) {
          NSLog(@"state-----------%lu", state);
      }];
  }
  
  // pause download action
  - (IBAction)pause:(id)sender {
      [[ATDownLoaderManager shareInstance] pauseWithURL:self.downdURL];
  }
  
  // cancel download action
  - (IBAction)cancel:(id)sender {
      [[ATDownLoaderManager shareInstance] cancelWithURL:self.downdURL];
  }
  ``````


## Requirements

## Installation

ATDownLoader is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ATDownLoader'
```

## Author

Spaino, captain_spaino@163.com

## License

ATDownLoader is available under the MIT license. See the LICENSE file for more info.
