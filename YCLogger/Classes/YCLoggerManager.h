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

- (void)addConsoleLogger:(NSString *)log;
- (void)removeAllConsoleLoggers;


/**
 获取所有按日期降序的日志文件路径

 @return 日志文件路径列表
 */
- (NSArray<NSString *> *)logFilePaths;


/**
 获取所有按日期降序的日志文件名

 @return 文件名列表
 */
- (NSArray<NSString *> *)logFileNames;

- (NSString *)zipPath;

@end

NS_ASSUME_NONNULL_END
