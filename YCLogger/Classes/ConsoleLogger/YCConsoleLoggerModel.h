//
//  YCConsoleLoggerModel.h
//  YCLogger
//
//  Created by shenweihang on 2019/8/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCConsoleLoggerModel : NSObject

/* 日期 */
@property (nonatomic, copy) NSString *dateTime;
/* 文件名 */
@property (nonatomic, copy) NSString *fileName;
/* 行数 */
@property (nonatomic, copy) NSString *lineNum;
/* 调用方法 */
@property (nonatomic, copy) NSString *methodName;
/* 消息 */
@property (nonatomic, copy) NSString *msg;

@end

NS_ASSUME_NONNULL_END
