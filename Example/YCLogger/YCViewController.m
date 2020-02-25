//
//  YCViewController.m
//  YCLogger
//
//  Created by 沈伟航 on 08/20/2019.
//  Copyright (c) 2019 沈伟航. All rights reserved.
//

#import "YCViewController.h"
#import <YCLogger/YCLogger.h>
@interface YCViewController ()

@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"日志";
    [[YCLoggerManager shareManager] startLogger];
    [self outputLoggers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)outputLoggers {
    
    YCLogDebug(@"这是一条调试日志");
    YCLogInfo(@"这是一条信息日志");
    YCLogWarn(@"这是一条警告日志");
    YCLogError(@"这是一条错误日志");
}

@end
