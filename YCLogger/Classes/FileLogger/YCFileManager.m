//
//  YCFileManager.m
//  YCLogger
//
//  Created by shenweihang on 2019/8/21.
//

#import "YCFileManager.h"
#import "YCFileManagerConfig.h"

@interface YCFileManager ()
{
    NSDateFormatter *dateFormatter;
}
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
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return self;
}

#pragma mark -重写创建日志文件名方法
- (NSString *)newLogFileName {
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@_%@.log", self.fileName, date];
}

- (BOOL)isLogFile:(NSString *)fileName {
    BOOL hasPrefix = [fileName hasPrefix:self.fileName];
    BOOL hasSufffix = [fileName hasSuffix:@".log"];
    return (hasPrefix && hasSufffix);
}

- (NSArray *)sortedLogFileInfos {
    return [[self unsortedLogFileInfos] sortedArrayUsingComparator:^NSComparisonResult(DDLogFileInfo *obj1,
                                                                                       DDLogFileInfo *obj2) {
        NSDate *date1 = [NSDate new];
        NSDate *date2 = [NSDate new];
        
        NSArray<NSString *> *arrayComponent = [[obj1 fileName] componentsSeparatedByString:@"_"];
        if (arrayComponent.count > 0) {
            NSString *stringDate = arrayComponent.lastObject;
            stringDate = [stringDate stringByReplacingOccurrencesOfString:@".log" withString:@""];
            stringDate = [stringDate stringByReplacingOccurrencesOfString:@".archived" withString:@""];
            date1 = [self->dateFormatter dateFromString:stringDate] ?: [obj1 creationDate];
        }
        
        arrayComponent = [[obj2 fileName] componentsSeparatedByString:@"_"];
        if (arrayComponent.count > 0) {
            NSString *stringDate = arrayComponent.lastObject;
            stringDate = [stringDate stringByReplacingOccurrencesOfString:@".log" withString:@""];
            stringDate = [stringDate stringByReplacingOccurrencesOfString:@".archived" withString:@""];
            date2 = [self->dateFormatter dateFromString:stringDate] ?: [obj2 creationDate];
        }
        
        return [date2 compare:date1 ?: [NSDate new]];
    }];
}

@end
