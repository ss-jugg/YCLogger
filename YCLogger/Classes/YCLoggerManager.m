//
//  YCLoggerManager.m
//  YCLogger
//
//  Created by shenweihang on 2019/8/20.
//

#import "YCLoggerManager.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "YCDynamicLogLevel.h"
#import "YCFileManager.h"
#import "YCFileLoggerFormatter.h"
#import "YCLoggerMacor.h"
#import "YCConsoleLoggerModel.h"
#import "YCConsoleLoggerFormatter.h"

@interface YCLoggerManager ()

/* 文件日志 */
@property (nonatomic, strong) DDFileLogger *fileLogger;
/* 发送日志语句到苹果的日志系统，以便它们显示在Console.app上 */
@property (nonatomic, strong) DDASLLogger *asLogger;
/* Xcode控制台日志 */
@property (nonatomic, strong) DDTTYLogger *consoleLogger;
/* 控制台日志 */
@property (nonatomic, strong,readwrite) NSMutableArray<YCConsoleLoggerModel *> *loggerModels;
@end

@implementation YCLoggerManager

+ (instancetype)shareManager {
    
    static YCLoggerManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YCLoggerManager alloc] init];
        _instance.fileConfig = [YCFileManagerConfig defaultConfig];
        _instance.loggerModels = [[NSMutableArray alloc] init];
    });
    return _instance;
}

- (void)startLogger {
    
    //配置日志文件
    YCFileManager *fileManager = [[YCFileManager alloc] initManagerWithConfig:self.fileConfig];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileManager];
    [fileLogger setLogFormatter:[[YCFileLoggerFormatter alloc] init]];
    fileLogger.maximumFileSize = self.fileConfig.maximumFileSize;
    fileLogger.rollingFrequency = self.fileConfig.rollingFrequency;
    
    //根据自定义日志等级，记录文件日志，默认等级 LOG_LEVEL_INFO
    [DDLog addLogger:fileLogger withLevel:LOG_LEVEL_CUSTOM];
    
    //控制台日志
    YCConsoleLoggerFormatter *consoleFormatter = [[YCConsoleLoggerFormatter alloc] init];
    if (@available(iOS 10.0, *)) {
        [[DDOSLogger sharedInstance] setLogFormatter:consoleFormatter];
        [DDLog addLogger:[DDOSLogger sharedInstance] withLevel:LOG_LEVEL_DEBUG];
    }else {
        [[DDASLLogger sharedInstance] setLogFormatter:consoleFormatter];
        [[DDTTYLogger sharedInstance] setLogFormatter:consoleFormatter];
        //Console.app日志
        [DDLog addLogger:[DDASLLogger sharedInstance] withLevel:LOG_LEVEL_DEBUG];
        //xcode控制台日志
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:LOG_LEVEL_DEBUG];
    }
    YCLogDebug(@"第一条日志");
    YCLogDebug(@"第二条日志");
    YCLogDebug(@"第三条日志");
}

- (void)addConsoleLogger:(YCConsoleLoggerModel *)loggerModel {
    
    [self.loggerModels addObject:loggerModel];
}

- (NSArray<NSString *> *)logFileNames {
    return [self.fileLogger.logFileManager sortedLogFileNames];
}
@end
