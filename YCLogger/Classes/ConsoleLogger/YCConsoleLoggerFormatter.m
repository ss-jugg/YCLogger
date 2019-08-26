//
//  YCConsoleLoggerFormatter.m
//  YCLogger
//
//  Created by shenweihang on 2019/8/26.
//

#import "YCConsoleLoggerFormatter.h"
#import "YCConsoleLoggerModel.h"
#import "YCLoggerManager.h"

@interface YCConsoleLoggerFormatter ()
{
    NSDateFormatter *_dateFormatter;
}

@end

@implementation YCConsoleLoggerFormatter

- (instancetype)init {
    
    if (self = [super init]) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {

    YCConsoleLoggerModel *loggerModel = [[YCConsoleLoggerModel alloc] init];
    loggerModel.dateTime = [_dateFormatter stringFromDate:logMessage->_timestamp];
    loggerModel.fileName = logMessage->_fileName;
    loggerModel.lineNum = @(logMessage->_line).stringValue;
    loggerModel.methodName = logMessage->_function;
    loggerModel.msg = logMessage->_message;
    
    [[YCLoggerManager shareManager] addConsoleLogger:loggerModel];
    return [loggerModel description];
}

@end
