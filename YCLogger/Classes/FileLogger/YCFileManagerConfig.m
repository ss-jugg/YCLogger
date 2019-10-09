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

NSUInteger         const kYCDefaultLogMaxNumLogFiles   = 20;                // 20 Files
unsigned long long const kYCDefaultLogFilesDiskQuota   = 1024 * 1024 * 10; // 10 MB
unsigned long long const kYCDefaultLogMaxFileSize      = 1024 * 500;      // 500 KB
NSTimeInterval     const kYCDefaultLogRollingFrequency = 60 * 60 * 24;     // 24 Hours


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
