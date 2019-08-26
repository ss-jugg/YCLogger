//
//  YCFileManager.h
//  YCLogger
//
//  Created by shenweihang on 2019/8/21.
//

#import "DDFileLogger.h"

NS_ASSUME_NONNULL_BEGIN
@class YCFileManagerConfig;
@interface YCFileManager : DDLogFileManagerDefault

- (instancetype)initManagerWithConfig:(YCFileManagerConfig *)config;
@end

NS_ASSUME_NONNULL_END
