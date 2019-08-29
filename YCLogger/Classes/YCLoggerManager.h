//
//  YCLoggerManager.h
//  YCLogger
//
//  Created by shenweihang on 2019/8/20.
//

#import <Foundation/Foundation.h>
#import "YCFileManagerConfig.h"
NS_ASSUME_NONNULL_BEGIN
@class YCConsoleLoggerModel;
@interface YCLoggerManager : NSObject

+ (instancetype)shareManager;

/* 文件日志配置项 */
@property (nonatomic, strong) YCFileManagerConfig *fileConfig;
/* 控制台日志 */
@property (nonatomic, strong,readonly) NSMutableArray<NSString *> *loggers;

- (void)startLogger;

- (NSArray<NSString *> *)logFileNames;

- (void)addConsoleLogger:(NSString *)log;
- (void)removeAllConsoleLoggers;
@end

NS_ASSUME_NONNULL_END
