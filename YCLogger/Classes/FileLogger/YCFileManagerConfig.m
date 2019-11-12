//
//  YCFileManagerConfig.m
//  YCLogger
//
//  Created by shenweihang on 2019/8/21.
//

#import "YCFileManagerConfig.h"

//日志文件路径
static NSString *const kYCLoggerFilePath = @"YCLoggers";
//压缩包名
static NSString *const kZipFileName = @"/YCLoggers.zip";

NSUInteger         const kYCDefaultLogMaxNumLogFiles   = 0;                //最大归档数量，默认不可用
unsigned long long const kYCDefaultLogFilesDiskQuota   = 1024 * 1024 * 30; // 日志最大磁盘存储 30 MB
unsigned long long const kYCDefaultLogMaxFileSize      = 1024 * 500;      // 单个文件最大 500 KB
NSTimeInterval     const kYCDefaultLogRollingFrequency = 0;     //日志回滚周期,默认不可用


@implementation YCFileManagerConfig

+ (YCFileManagerConfig *)defaultConfig {
    
    YCFileManagerConfig *config = [[YCFileManagerConfig alloc] init];
    
    return config;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.maximumNumberOfLogFiles = kYCDefaultLogMaxNumLogFiles;
        self.logFilesDiskQuota = kYCDefaultLogFilesDiskQuota;
        self.maximumFileSize = kYCDefaultLogMaxFileSize;
        self.rollingFrequency = kYCDefaultLogRollingFrequency;
        self.fileName = [[NSBundle mainBundle] bundleIdentifier];
        self.zipName = kZipFileName;
        self.logsDirectory = [self defultLogsDirectory];
    }
    return self;
}

- (NSString *)defultLogsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *baseDir = paths.firstObject;
    NSString *logsDirectory = [baseDir stringByAppendingPathComponent:kYCLoggerFilePath];
    return logsDirectory;
}

@end
