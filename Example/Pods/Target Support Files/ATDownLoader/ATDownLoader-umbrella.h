#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ATDownLoader.h"
#import "ATDownLoaderManager.h"
#import "ATFileTool.h"
#import "NSString+ATMD5.h"

FOUNDATION_EXPORT double ATDownLoaderVersionNumber;
FOUNDATION_EXPORT const unsigned char ATDownLoaderVersionString[];

