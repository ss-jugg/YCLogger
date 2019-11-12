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
#import "YCLoggerReporter.h"

@interface YCLoggerManager ()
{
    dispatch_semaphore_t semaphore;
}

/* 文件日志 */
@property (nonatomic, strong) DDFileLogger *fileLogger;
/* 控制台日志 */
@property (nonatomic, strong,readwrite) NSMutableArray<NSString *> *loggers;
@end

@implementation YCLoggerManager

+ (instancetype)shareManager {
    
    static YCLoggerManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YCLoggerManager alloc] init];

    });
    return _instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.fileConfig = [YCFileManagerConfig defaultConfig];
        self.loggers = [[NSMutableArray alloc] init];
        semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)startLogger {
    
    //配置日志文件
    YCFileManager *fileManager = [[YCFileManager alloc] initManagerWithConfig:self.fileConfig];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileManager];
    [fileLogger setLogFormatter:[[YCFileLoggerFormatter alloc] init]];
    fileLogger.maximumFileSize = self.fileConfig.maximumFileSize;
    fileLogger.rollingFrequency = self.fileConfig.rollingFrequency;
    self.fileLogger = fileLogger;
    //根据自定义日志等级，记录文件日志，默认等级 LOG_LEVEL_WARN
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
    
    [[YCAPILogger sharedInstance] open];
    [[YCLoggerReporter sharedReporter] checkLogNeedUpload];
}

- (void)addConsoleLogger:(NSString *)log {
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.loggers insertObject:log atIndex:0];
    dispatch_semaphore_signal(semaphore);
}

- (void)removeAllConsoleLoggers {
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.loggers removeAllObjects];
    dispatch_semaphore_signal(semaphore);
}

- (NSArray<NSString *> *)logFilePaths {
    return [self.fileLogger.logFileManager sortedLogFilePaths];
}

- (NSArray<NSString *> *)logFileNames {
    return [self.fileLogger.logFileManager sortedLogFileNames];
}

- (NSString *)zipPath {
    
    return [self.fileConfig.logsDirectory stringByAppendingString:self.fileConfig.zipName];
}

@end
