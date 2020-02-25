# YCLogger

## YCLogger是基于CocoaLumberjack封装的iOS客户端日志组件。

## 介绍

### 一、组成部分
1、YCFileManager文件日志管理、YCFileManagerConfig日志配置、YCFileLoggerFormatter日志格式。

```
    //配置日志文件
    YCFileManager *fileManager = [[YCFileManager alloc] initManagerWithConfig:self.fileConfig];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileManager];
    [fileLogger setLogFormatter:[[YCFileLoggerFormatter alloc] init]];
    fileLogger.maximumFileSize = self.fileConfig.maximumFileSize;
    fileLogger.rollingFrequency = self.fileConfig.rollingFrequency;
    self.fileLogger = fileLogger;
    //根据自定义日志等级，记录文件日志，默认等级 LOG_LEVEL_WARN
    [DDLog addLogger:fileLogger withLevel:LOG_LEVEL_CUSTOM];
```

2、DDOSLogger\DDASLLogger控制台日志、YCConsoleLoggerFormatter日志格式

```
    //控制台日志
    YCConsoleLoggerFormatter *consoleFormatter = [[YCConsoleLoggerFormatter alloc] init];
    if (@available(iOS 10.0, *)) {
        //Console.app/Xcode console
        [[DDOSLogger sharedInstance] setLogFormatter:consoleFormatter];
        [DDLog addLogger:[DDOSLogger sharedInstance] withLevel:LOG_LEVEL_DEBUG];
    }else {
        [[DDASLLogger sharedInstance] setLogFormatter:consoleFormatter];
        //Console.app日志
        [DDLog addLogger:[DDASLLogger sharedInstance] withLevel:LOG_LEVEL_DEBUG];
        //xcode控制台日志
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:LOG_LEVEL_DEBUG];
    }
```

3、YCAPILogger接口日志，由YCAPILoggerEnabled开关控制是否开启，主要在debug环境下使用。

4、YCLoggerReporter用于检测文件日志是否需要上传。

5、YCDynamicLogLevel动态控制日志级别。

### 二、使用

```
    #import "YCLogger.h"
```

```
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.backgroundColor = [UIColor whiteColor];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[YCViewController alloc] init]];
        self.window.rootViewController = nav;
        
        //MARK:开启日志组件
        [[YCLoggerManager shareManager] startLogger];
        
        [self.window makeKeyAndVisible];
        return YES;
    }

```

```
    //MARK:输出不同级别的日志
    YCLogDebug(@"这是一条调试日志");
    YCLogInfo(@"这是一条信息日志");
    YCLogWarn(@"这是一条警告日志");
    YCLogError(@"这是一条错误日志");
```


## Author

沈伟航, 809827782@qq.com

## License

YCLogger is available under the MIT license. See the LICENSE file for more info.
