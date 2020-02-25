//
//  YCDynamicLogLevel.h
//  YCLogger
//
//  Created by shenweihang on 2019/8/21.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
NS_ASSUME_NONNULL_BEGIN
static DDLogLevel d_logLevel;

@interface YCDynamicLogLevel : NSObject<DDRegisteredDynamicLogging>

+ (void)ddSetLogLevel:(DDLogLevel)ddLogLevel;

@end

NS_ASSUME_NONNULL_END
