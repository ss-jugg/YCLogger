//
//  YCConsoleLoggerModel.m
//  YCLogger
//
//  Created by shenweihang on 2019/8/26.
//

#import "YCConsoleLoggerModel.h"

@implementation YCConsoleLoggerModel

- (NSString *)description {
    return [NSString stringWithFormat:@"\n日期:%@\n文件:%@\n行数:第%@行\n方法:%@\n输出:%@\n",self.dateTime,self.fileName,self.lineNum,self.methodName,self.msg];
}
@end
