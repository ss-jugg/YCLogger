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
#import "YCConsoleLoggerFormatter.h"
#import "YCAPILogger.h"

@interface YCLoggerManager ()

/* 文件日志 */
@property (nonatomic, strong) DDFileLogger *fileLogger;
/* 发送日志语句到苹果的日志系统，以便它们显示在Console.app上 */
@property (nonatomic, strong) DDASLLogger *asLogger;
/* Xcode控制台日志 */
@property (nonatomic, strong) DDTTYLogger *consoleLogger;
/* 控制台日志 */
@property (nonatomic, strong,readwrite) NSMutableArray<NSString *> *loggers;
@end

@implementation YCLoggerManager

+ (instancetype)shareManager {
    
    static YCLoggerManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YCLoggerManager alloc] init];
        _instance.fileConfig = [YCFileManagerConfig defaultConfig];
        _instance.loggers = [[NSMutableArray alloc] init];
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
        //Console.app/Xcode console
        [[DDOSLogger sharedInstance] setLogFormatter:consoleFormatter];
        [DDLog addLogger:[DDOSLogger sharedInstance] withLevel:LOG_LEVEL_DEBUG];
    }else {
        [[DDASLLogger sharedInstance] setLogFormatter:consoleFormatter];
        //Console.app日志
        [DDLog addLogger:[DDASLLogger sharedInstance] withLevel:LOG_LEVEL_DEBUG];
        //xcode控制台日志
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:LOG_LEVEL_DEBUG];
    }
    
    //开启网络请求日志
    [[YCAPILogger sharedInstance] open];
}

- (void)addConsoleLogger:(NSString *)log {
    
    [self.loggers insertObject:log atIndex:0];
}

- (void)removeAllConsoleLoggers {
    [self.loggers removeAllObjects];
}

- (NSArray<NSString *> *)logFileNames {
    return [self.fileLogger.logFileManager sortedLogFileNames];
}
@end
