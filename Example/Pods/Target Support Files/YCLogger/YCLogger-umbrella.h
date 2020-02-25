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

#import "YCAPILogger.h"
#import "YCConsoleLoggerFormatter.h"
#import "YCFileLoggerFormatter.h"
#import "YCFileManager.h"
#import "YCFileManagerConfig.h"
#import "YCLoggerReporter.h"
#import "YCDynamicLogLevel.h"
#import "YCLogger.h"
#import "YCLoggerMacor.h"
#import "YCLoggerManager.h"

FOUNDATION_EXPORT double YCLoggerVersionNumber;
FOUNDATION_EXPORT const unsigned char YCLoggerVersionString[];

