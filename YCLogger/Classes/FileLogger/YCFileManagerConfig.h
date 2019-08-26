//
//  YCFileManagerConfig.h
//  YCLogger
//
//  Created by shenweihang on 2019/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCFileManagerConfig : NSObject

/* 最多日志文件数，默认20 */
@property (nonatomic, assign) NSUInteger maximumNumberOfLogFiles;
/* 日志文件最大内存，默认10MB */
@property (nonatomic, assign) unsigned long long logFilesDiskQuota;
/* 单个日志文件大小 ，默认500KB*/
@property (nonatomic, assign) unsigned long long maximumFileSize;
/* 日志文件回写周期，默认24小时 */
@property (nonatomic, assign) NSTimeInterval rollingFrequency;
/* 日志文件名 */
@property (nonatomic, copy) NSString *fileName;
/* 日志文件路径 */
@property (nonatomic, copy) NSString *logsDirectory;
/* 压缩包名 */
@property (nonatomic, copy) NSString *zipName;

+ (YCFileManagerConfig *)defaultConfig;

@end

NS_ASSUME_NONNULL_END
