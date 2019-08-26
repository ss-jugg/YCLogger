//
//  YCFileManager.m
//  YCLogger
//
//  Created by shenweihang on 2019/8/21.
//

#import "YCFileManager.h"
#import "YCFileManagerConfig.h"

@interface YCFileManager ()
/* 日志文件名 */
@property (nonatomic, copy) NSString *fileName;
@end

@implementation YCFileManager

- (instancetype)initManagerWithConfig:(YCFileManagerConfig *)config {
    
    
    self = [super initWithLogsDirectory:config.logsDirectory defaultFileProtectionLevel:NSFileProtectionCompleteUntilFirstUserAuthentication];
    
    if (self) {
        self.maximumNumberOfLogFiles = config.maximumNumberOfLogFiles;
        self.logFilesDiskQuota = config.logFilesDiskQuota;
        self.fileName = config.fileName;
        
    }
    return self;
}

#pragma mark -重写创建日志文件名方法
- (NSString *)newLogFileName {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@_%@.log", self.fileName, date];
}

- (BOOL)isLogFile:(NSString *)fileName {
    BOOL hasPrefix = [fileName hasPrefix:self.fileName];
    BOOL hasSufffix = [fileName hasSuffix:@".log"];
    return (hasPrefix && hasSufffix);
}

@end
