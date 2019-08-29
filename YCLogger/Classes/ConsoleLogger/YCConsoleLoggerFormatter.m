//
//  YCConsoleLoggerFormatter.m
//  YCLogger
//
//  Created by shenweihang on 2019/8/26.
//

#import "YCConsoleLoggerFormatter.h"
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

    NSString *date = [_dateFormatter stringFromDate:logMessage->_timestamp];
    NSString *fileName = logMessage->_fileName;
    NSString *lineNum = @(logMessage->_line).stringValue;
    NSString *methodName = logMessage->_function;
    NSString *msg = logMessage->_message;
    NSString *log = [NSString stringWithFormat:@"日期 : %@\n文件 : %@\n行数 : 第%@行\n方法 : %@\n输出 : %@",date,fileName,lineNum,methodName,msg];
    [[YCLoggerManager shareManager] addConsoleLogger:log];
    return log;
}

@end
