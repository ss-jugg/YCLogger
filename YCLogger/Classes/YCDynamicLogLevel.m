//
//  YCDynamicLogLevel.m
//  YCLogger
//
//  Created by shenweihang on 2019/8/21.
//

#import "YCDynamicLogLevel.h"
#import "YCLoggerMacor.h"

@implementation YCDynamicLogLevel

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [YCDynamicLogLevel ddSetLogLevel:LOG_LEVEL_WARN];
    });
}

+ (DDLogLevel)ddLogLevel {
    return d_logLevel;
}

+ (void)ddSetLogLevel:(DDLogLevel)ddLogLevel {
    d_logLevel = ddLogLevel;
}
@end
