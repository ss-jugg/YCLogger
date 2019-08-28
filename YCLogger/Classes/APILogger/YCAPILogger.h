//
//  YCAPILogger.h
//  YCAPILogger
//
//  Created by haima on 2019/4/20.
//

#import <Foundation/Foundation.h>

//======================================
// 运行期可通过LLDB `expr`命令实时修改的变量
//======================================

// 所有API日志的统一开关
CF_EXPORT BOOL YCAPILoggerEnabled;
// 请求日志的可定制格式符号
CF_EXPORT char *YCAPILoggerRequestLogIcon;
// 响应日志的可定制格式符号
CF_EXPORT char *YCAPILoggerResponseLogIcon;
// 异常日志的可定制格式符号
CF_EXPORT char *YCAPILoggerErrorLogIcon;


//============================
//   可定制的API日志的组成元素
//============================

typedef NS_OPTIONS(NSUInteger, YCAPILoggerRequestElement) {
    /** API起飞时间 */
    YCAPILoggerRequestElementTakeOffTime        = 1 << 0,
    /** API请求方式 */
    YCAPILoggerRequestElementMethod             = 1 << 1,
    /** API有效的请求路径 */
    YCAPILoggerRequestElementVaildURL           = 1 << 2,
    /** API请求头字段 */
    YCAPILoggerRequestElementHeaderFields       = 1 << 3,
    /** API请求体(一般是入参) */
    YCAPILoggerRequestElementHTTPBody           = 1 << 4,
    /** API任务唯一标识 */
    YCAPILoggerRequestElementTaskIdentifier     = 1 << 5,
    /** API请求任务所有标识 */
    YCAPILoggerRequestElementAll                = ~0UL
};

typedef NS_OPTIONS(NSUInteger, YCAPILoggerResponseElement) {
    /** API着陆时间 */
    YCAPILoggerResponseElementLandTime          = 1 << 0,
    /** API请求-响应耗时 */
    YCAPILoggerResponseElementTimeConsuming     = 1 << 1,
    /** API请求方式 */
    YCAPILoggerResponseElementMethod            = 1 << 2,
    /** API有效的请求路径 */
    YCAPILoggerResponseElementVaildURL          = 1 << 3,
    /** API响应头字段 */
    YCAPILoggerResponseElementHeaderFields      = 1 << 4,
    /** API响应状态码 */
    YCAPILoggerResponseElementStatusCode        = 1 << 5,
    /** API响应主体(或者异常) */
    YCAPILoggerResponseElementResponse          = 1 << 6,
    /** API任务唯一标识 */
    YCAPILoggerResponseElementTaskIdentifier    = 1 << 7,
    /** API响应任务所有标识 */
    YCAPILoggerResponseElementAll               = ~0UL
};


@interface YCAPILogger : NSObject

/**
 请求日志 可定制的组成元素
 */
@property (nonatomic, assign) YCAPILoggerRequestElement requestLoggerElements;

/**
 响应日志/异常日志 可定制的组成元素
 */
@property (nonatomic, assign) YCAPILoggerResponseElement responseLoggerElements;

+ (instancetype)sharedInstance;
/**
 开启API日志
 */
- (void)open;

@end

