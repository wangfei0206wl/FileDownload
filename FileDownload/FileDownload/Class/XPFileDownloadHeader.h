//
//  XPFileDownloadHeader.h
//  pandora_p
//
//  Created by 王飞 on 2019/4/18.
//  Copyright © 2019 搜狗企业IT部. All rights reserved.
//

#ifndef XPFileDownloadHeader_h
#define XPFileDownloadHeader_h

// 下载文件列表(单项记录只记录: url、filePath、totalFileSize)-----因为实现机制原因，本地化记录下载列表可以忽略
#define kFileDownloadListFile [[XPUtility documentPath] stringByAppendingPathComponent:@"xpFileDownload.plist"]
// 文件下载临时目录
#define kFileDownloadTmpFolder NSTemporaryDirectory()

// 下载进度回调定义
typedef void(^XPFileDownloadProgressBlock)(long long cacheFileSize, long long totalFileSize);
// 下载完成回调定义
typedef void(^XPFileDownloadFinishBlock)(NSError *error, NSString *filePath);

/**
 文件下载优先级定义

 - XPFileDownloadPriorityLow: 底优先级
 - XPFileDownloadPriorityMid: 中优先级
 - XPFileDownloadPriorityHigh: 高优先级
 - XPFileDownloadPriorityDefault: 默认优先级
 */
typedef NS_ENUM(NSInteger, XPFileDownloadPriority) {
    XPFileDownloadPriorityLow = 0,
    XPFileDownloadPriorityMid,
    XPFileDownloadPriorityHigh,
    XPFileDownloadPriorityDefault,
};

#endif /* XPFileDownloadHeader_h */
