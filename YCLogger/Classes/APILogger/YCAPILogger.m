//
//  YCAPILogger.m
//  YCAPILogger
//
//  Created by haima on 2019/4/20.
//

#import "YCAPILogger.h"
#import <AFNetworking/AFURLSessionManager.h>
#import <objc/runtime.h>

BOOL   YCAPILoggerEnabled         = YES;
char  *YCAPILoggerRequestLogIcon  = "✈️";
char  *YCAPILoggerResponseLogIcon = "☀️";
char  *YCAPILoggerErrorLogIcon    = "❌";

static void * YCAPILoggerTakeOffDate = &YCAPILoggerTakeOffDate;

static dispatch_queue_t _ycJsonResponseFormatQueue;

//分割符
static const char* YCAPILoggerMarkedLine(char* c, uint length) {
    NSMutableString *foldLeft = @"".mutableCopy;
    [[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, length)] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [foldLeft appendString:[NSString stringWithUTF8String:c]];
    }];
    return [[foldLeft copy] UTF8String];
}


@implementation YCAPILogger

+ (instancetype)sharedInstance {
    
    static YCAPILogger *logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[self alloc] init];
        _ycJsonResponseFormatQueue = dispatch_queue_create("YCAPILogger.loggerQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return logger;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.requestLoggerElements = YCAPILoggerRequestElementAll;
        self.responseLoggerElements = YCAPILoggerResponseElementAll;
    }
    return self;
}

- (void)open {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiDidTakeOff:) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiDidLand:) name:AFNetworkingTaskDidCompleteNotification object:nil];
}


#pragma mark - 处理请求起飞日志
- (void)apiDidTakeOff:(NSNotification *)notification {
    
    if (!YCAPILoggerEnabled) {
        return;
    }
    NSURLRequest *request = [self requestFromAFNotification:notification];
    
    if (!request) {
        return;
    }
    
    //记录请求开始时间
    objc_setAssociatedObject(notification.object, YCAPILoggerTakeOffDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSMutableString *frmtString = @"".mutableCopy;
    //记录请求taskIdentifier
    if (self.requestLoggerElements & YCAPILoggerRequestElementTaskIdentifier) {
        NSString *taskIdentifier = [self taskIdentifierFromAFNotification:notification];
        NSString *taskIdentifierDes = [NSString stringWithFormat:@"\n<API序列号> %@", taskIdentifier];
        [frmtString appendString:taskIdentifierDes];
    }
    
    //记录API描述
    NSURLSessionTask *task = (NSURLSessionTask *)notification.object;
    NSUInteger taskDescLength = [task.taskDescription stringByReplacingOccurrencesOfString:@" " withString:@""].length;
    if (taskDescLength) {
        NSString *apiTaskDes = [NSString stringWithFormat:@"\n<API描述>    %@", task.taskDescription];
        [frmtString appendString:apiTaskDes];
    }
    //请求起飞时间
    if (self.requestLoggerElements & YCAPILoggerRequestElementTakeOffTime) {
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timeStr = [df stringFromDate:objc_getAssociatedObject(notification.object, YCAPILoggerTakeOffDate)];
        NSString *milestoneTimeDes = [NSString stringWithFormat:@"\n<起飞时间>  %@", timeStr];
        [frmtString appendString:milestoneTimeDes];
    }
    //请求方法
    if (self.requestLoggerElements & YCAPILoggerRequestElementMethod) {
        NSString *methodDes = [NSString stringWithFormat:@"\n<请求方式>  %@", request.HTTPMethod];
        [frmtString appendString:methodDes];
    }
    //请求地址
    if (self.requestLoggerElements & YCAPILoggerRequestElementVaildURL) {
        NSString *validURLDes = [NSString stringWithFormat:@"\n<请求地址>  %@", [request.URL absoluteString]];
        [frmtString appendString:validURLDes];
    }
    //请求头
    if (self.requestLoggerElements & YCAPILoggerRequestElementHeaderFields) {
        NSDictionary *headerFields = request.allHTTPHeaderFields;
        NSMutableString *headerFieldFrmtStr = @"".mutableCopy;
        [headerFields enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [headerFieldFrmtStr appendFormat:@"\n\t\"%@\" = \"%@\"", key, obj];
        }];
        NSString *headerFieldsDes = [NSString stringWithFormat:@"\n<HeaderFields>%@", headerFieldFrmtStr];
        [frmtString appendString:headerFieldsDes];
    }
    //请求体，一般是请求参数
    if (self.requestLoggerElements & YCAPILoggerRequestElementHTTPBody) {
        __block id httpBody = nil;
        
        if ([request HTTPBody]) {
            httpBody = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
        }
        // if a request does not set HTTPBody, so here it's need to check HTTPBodyStream
        else if ([request HTTPBodyStream]) {
            NSInputStream *httpBodyStream = request.HTTPBodyStream;
            __weak __typeof(self) w_self = self;
            [self apiLoggerAsyncHttpBodyStreamParse:httpBodyStream block:^(NSData *data) {
                __strong __typeof(w_self) s_self = w_self;
                httpBody = data;
                NSString *httpBodyDes = [NSString stringWithFormat:@"\n<Body>\n\t%@", httpBody];
                [frmtString appendString:httpBodyDes];
                
                NSString *logMsg = [frmtString copy];
                [s_self showRequestLogger:logMsg];
            }];
            return;
        }
        
        if ([httpBody isKindOfClass:[NSString class]] && [(NSString *)httpBody length]) {
            __weak __typeof(self) w_self = self;
            [self apiLoggerHttpBodyJsonParse:httpBody block:^(NSString *formatString) {
                __strong __typeof(w_self) s_self = w_self;
                NSString *httpBodyDes = [NSString stringWithFormat:@"\n<Body>%@", formatString];
                [frmtString appendString:httpBodyDes];
                NSString *logMsg = [frmtString copy];
                [s_self showRequestLogger:logMsg];
            }];
            return;
        }
    }
    
    NSString *logMsg = [frmtString copy];
    [self showRequestLogger:logMsg];
}


#pragma mark - 请求着陆日志处理
- (void)apiDidLand:(NSNotification *)notification {
    
    if (!YCAPILoggerEnabled) {
        return;
    }
    
    NSURLRequest *request = [self requestFromAFNotification:notification];
    NSURLResponse *response = [self responseFromAFNNotification:notification];
    NSError *error = [self errorFromAFNNotification:notification];
    if (!request) {
        return;
    }
    
    NSInteger responseStatusCode = 0;
    NSDictionary *responseHeaderFields = nil;
    // NSHTTPURLResponse inherit NSURLResponse，it has statusCode and allHeaderFields prop..
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        responseStatusCode = [(NSHTTPURLResponse *)response statusCode];
        responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
    }
    
    NSMutableString *frmtString = @"".mutableCopy;
    // avoid compile time deviation..
    NSDate *landDate = [NSDate date];
    
    if (self.responseLoggerElements & YCAPILoggerResponseElementTaskIdentifier) {
        NSString *taskIdentifier = [self taskIdentifierFromAFNotification:notification];
        NSString *taskIdentifierDes = [NSString stringWithFormat:@"\n<API序列号> %@", taskIdentifier];
        [frmtString appendString:taskIdentifierDes];
    }
    
    NSURLSessionTask *task = (NSURLSessionTask *)notification.object;
    NSUInteger taskDescLength = [task.taskDescription stringByReplacingOccurrencesOfString:@" " withString:@""].length;
    if (taskDescLength) {
        NSString *apiTaskDes = [NSString stringWithFormat:@"\n<API描述>    %@", task.taskDescription];
        [frmtString appendString:apiTaskDes];
    }
    
    if (self.responseLoggerElements & YCAPILoggerResponseElementLandTime) {
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timeStr = [df stringFromDate:landDate];
        NSString *milestoneTimeDes = [NSString stringWithFormat:@"\n<着陆时间>  %@", timeStr];
        [frmtString appendString:milestoneTimeDes];
    }
    
    if (self.responseLoggerElements & YCAPILoggerResponseElementTimeConsuming) {
        NSTimeInterval timeConsuming = [landDate timeIntervalSinceDate:objc_getAssociatedObject(notification.object, YCAPILoggerTakeOffDate)];
        NSString *secondConsuming = [NSString stringWithFormat:@"%.3f秒", timeConsuming];
        NSString *timeConsumingDes = [NSString stringWithFormat:@"\n<请求耗时>  %@", secondConsuming];
        [frmtString appendString:timeConsumingDes];
    }
    
    if (self.responseLoggerElements & YCAPILoggerResponseElementMethod) {
        NSString *methodDes = [NSString stringWithFormat:@"\n<请求方式>  %@", request.HTTPMethod];
        [frmtString appendString:methodDes];
    }
    
    if (self.responseLoggerElements & YCAPILoggerResponseElementStatusCode) {
        if (responseStatusCode) {
            NSString *statusCodeDes = [NSString stringWithFormat:@"\n<状态码>     %ld", responseStatusCode];
            [frmtString appendString:statusCodeDes];
        }
    }
    
    if (self.responseLoggerElements & YCAPILoggerResponseElementVaildURL) {
        NSString *validURLDes = [NSString stringWithFormat:@"\n<请求地址>  %@", [request.URL absoluteString]];
        [frmtString appendString:validURLDes];
    }
    
    if (self.responseLoggerElements & YCAPILoggerResponseElementHeaderFields) {
        if (responseHeaderFields) {
            NSMutableString *headerFieldFrmtStr = @"".mutableCopy;
            [responseHeaderFields enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [headerFieldFrmtStr appendFormat:@"\n\t\"%@\" = \"%@\"", key, obj];
            }];
            NSString *headerFieldsDes = [NSString stringWithFormat:@"\n<HeaderFields>%@", headerFieldFrmtStr];
            [frmtString appendString:headerFieldsDes];
        }
    }
    
    if (self.responseLoggerElements & YCAPILoggerResponseElementResponse) {
        if (error) {
            NSString *errorDes = [NSString stringWithFormat:@"\n<Error>\n\tErrorDomain = %@\n\tCode = %ld\n\tLocalizedDescription = %@", error.domain, error.code, error.localizedDescription];
            [frmtString appendString:errorDes];
        } else {
            // JSON pretty print format, by async to improve performance..
            id serializedResponse = notification.userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey];
            
            __weak __typeof(self) w_self = self;
            [self apiLoggerAsyncJsonResponsePrettyFormat:serializedResponse block:^(id betterResponseString) {
                __strong __typeof(w_self) s_self = w_self;
                NSString *responseDes = [NSString stringWithFormat:@"\n<Response>\n%@", betterResponseString];
                [frmtString appendString:responseDes];
                NSString *logMsg = [frmtString copy];
                [s_self showResponseLogger:logMsg];
            }];

            return;
        }
    }
    
    NSString *logMsg = [frmtString copy];
    
    if (error) {
        [self showErrorLogger:logMsg];
    } else {
        [self showResponseLogger:logMsg];
    }
    
}

#pragma mark - 处理AFNotification
- (NSURLRequest *)requestFromAFNotification:(NSNotification *)notification {
    
    NSURLSessionTask *task = notification.object;
    NSURLRequest *request = task.originalRequest?:task.currentRequest;
    return request;
}

- (NSURLResponse *)responseFromAFNNotification:(NSNotification *)notification {
    NSURLSessionTask *task = notification.object;
    NSURLResponse *response = task.response;
    return response;
}

- (NSString *)taskIdentifierFromAFNotification:(NSNotification *)notification {
    NSURLSessionTask *task = notification.object;
    NSString *taskIdentifier = @(task.taskIdentifier).stringValue;
    return taskIdentifier;
}

- (NSError *)errorFromAFNNotification:(NSNotification *)notification {
    NSURLSessionTask *task = notification.object;
    NSError *error = task.error ?: notification.userInfo[AFNetworkingTaskDidCompleteErrorKey];
    return error;
}

#pragma mark - httpbody
- (void)apiLoggerAsyncHttpBodyStreamParse:(NSInputStream *)originBodyStream block:(void(^)(NSData *data))block {
    
    // this is a bug may cause image can't upload when other thread read the same bodystream
    // copy origin body stream and use the new can avoid this issure
    NSInputStream *bodyStream = [originBodyStream copy];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [bodyStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [bodyStream open];
        
        uint8_t *buffer = NULL;
        NSMutableData *streamData = [NSMutableData data];
        
        while ([bodyStream hasBytesAvailable]) {
            buffer = (uint8_t *)malloc(sizeof(uint8_t) * 1024);
            NSInteger length = [bodyStream read:buffer maxLength:sizeof(uint8_t) * 1024];
            if (bodyStream.streamError || length <= 0) {
                break;
            }
            [streamData appendBytes:buffer length:length];
            free(buffer);
        }
        [bodyStream close];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !block ?: block([streamData copy]);
        });
    });
}

- (void)apiLoggerHttpBodyJsonParse:(NSString *)jsonString block:(void(^)(NSString *formatString))block {
    
    NSMutableString *httpBodyStr = @"".mutableCopy;
    NSArray *params = [jsonString componentsSeparatedByString:@","];
    [params enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *pair = [obj componentsSeparatedByString:@":"];
        
        NSString *key = nil;
        if ([pair.firstObject respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
            key = [pair.firstObject stringByRemovingPercentEncoding];
        }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            key = [pair.firstObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
        }
        NSString *value = nil;
        if ([pair.lastObject respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
            value = [pair.lastObject stringByRemovingPercentEncoding];
        }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            value = [pair.lastObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
        }
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        
        [httpBodyStr appendFormat:@"\n\t%@ = %@", key, value];
    }];
    !block ?: block(httpBodyStr);
    
}

#pragma mark - response
- (void)apiLoggerAsyncJsonResponsePrettyFormat:(id)response block:(void(^)(id betterResponseString))block {
    if (![NSJSONSerialization isValidJSONObject:response]) {
        !block ?: block(response);
        return;
    }
    dispatch_barrier_async(_ycJsonResponseFormatQueue, ^{
        NSError *formatError = nil;
        NSString *prettyJsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:&formatError] encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            id better = formatError ? response : prettyJsonString;
            !block ?: block(better);
        });
    });
}

#pragma mark - 显示日志
- (void)showRequestLogger:(NSString *)fmrtStr {
    
    printf("\n%s", YCAPILoggerMarkedLine(YCAPILoggerRequestLogIcon, 16));
    printf("  ← 请求日志 →  ");
    printf("%s\n", YCAPILoggerMarkedLine(YCAPILoggerRequestLogIcon, 16));
    printf("%s\n", [fmrtStr UTF8String]);
    printf("\n%s\n", YCAPILoggerMarkedLine(YCAPILoggerRequestLogIcon, 40));
}

- (void)showResponseLogger:(NSString *)fmrtStr {
    
    printf("\n%s", YCAPILoggerMarkedLine(YCAPILoggerResponseLogIcon, 16));
    printf("  ← 响应日志 →  ");
    printf("%s\n", YCAPILoggerMarkedLine(YCAPILoggerResponseLogIcon, 16));
    printf("%s\n", [fmrtStr UTF8String]);
    printf("\n%s\n", YCAPILoggerMarkedLine(YCAPILoggerResponseLogIcon, 40));
}

- (void)showErrorLogger:(NSString *)fmrtStr {
    
    printf("\n%s", YCAPILoggerMarkedLine(YCAPILoggerErrorLogIcon, 16));
    printf("  ← 异常日志 →  ");
    printf("%s\n", YCAPILoggerMarkedLine(YCAPILoggerErrorLogIcon, 16));
    printf("%s\n", [fmrtStr UTF8String]);
    printf("\n%s\n", YCAPILoggerMarkedLine(YCAPILoggerErrorLogIcon, 40));
}


@end
