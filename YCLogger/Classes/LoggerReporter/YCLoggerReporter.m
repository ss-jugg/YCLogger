//
//  YCLoggerReporter.m
//  YCLogger
//
//  Created by shenweihang on 2019/9/2.
//

#import "YCLoggerReporter.h"

@implementation YCLoggerReporter

- (instancetype)init {
    
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:nil];
    }
    return self;
}

@end
