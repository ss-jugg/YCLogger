//
//  YCLoggerMacor.h
//  Pods
//
//  Created by shenweihang on 2019/8/21.
//
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "YCDynamicLogLevel.h"

#define LOG_LEVEL_CUSTOM [YCDynamicLogLevel ddLogLevel]

// First undefine the default stuff we don't want to use
#undef DDLogError
#undef DDLogWarn
#undef DDLogInfo
#undef DDLogDebug
#undef DDLogVerbose

// 自定义log level
#define LOG_FLAG_ERROR      (1 << 0)
#define LOG_FLAG_WARN       (1 << 1)
#define LOG_FLAG_NOTICE     (1 << 2)
#define LOG_FLAG_INFO       (1 << 3)
#define LOG_FLAG_DEBUG      (1 << 4)

#define LOG_LEVEL_ERROR     (LOG_FLAG_ERROR)
#define LOG_LEVEL_WARN      (LOG_LEVEL_ERROR    | LOG_FLAG_WARN)
#define LOG_LEVEL_NOTICE    (LOG_LEVEL_WARN     | LOG_FLAG_NOTICE)
#define LOG_LEVEL_INFO      (LOG_LEVEL_NOTICE   | LOG_FLAG_INFO)
#define LOG_LEVEL_DEBUG     (LOG_LEVEL_INFO     | LOG_FLAG_DEBUG)

#define YCLogError(frmt, ...)   LOG_MAYBE(NO,   LOG_LEVEL_ERROR, LOG_FLAG_ERROR,  0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define YCLogWarn(frmt, ...)    LOG_MAYBE(YES,  LOG_LEVEL_WARN, LOG_FLAG_WARN,  0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define YCLogNotice(frmt, ...)  LOG_MAYBE(YES,  LOG_LEVEL_NOTICE, LOG_FLAG_NOTICE,  0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define YCLogInfo(frmt, ...)    LOG_MAYBE(YES,  LOG_LEVEL_INFO, LOG_FLAG_INFO,  0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define YCLogDebug(frmt, ...)   LOG_MAYBE(YES,  LOG_LEVEL_DEBUG, LOG_FLAG_DEBUG,  0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
