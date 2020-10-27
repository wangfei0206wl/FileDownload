//
//  XPFileDownloadManager.h
//  pandora_p
//
//  Created by 王飞 on 2019/4/16.
//  Copyright © 2019 搜狗企业IT部. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPFileDownloadModel.h"

/**
 文件下载管理类(支持断点续传、下载优先级)
 */
@interface XPFileDownloadManager : NSObject

DEFINE_SINGLETON_FOR_HEADER(XPFileDownloadManager)

/**
 app登录或匿名登录后调用
 */
- (void)initForAppRun;

/**
 文件下载(如果文件已处于下载中状态，则只设置目标文件路径、优先级、下载进度及完成回调)

 @param url 文件下载url
 @param destFilePath 目标下载文件路径
 @param progress 下载进度回调
 @param finish 完成回调(有错返回error)
 */
- (void)downloadFileWithUrl:(NSString *)url
               destFilePath:(NSString *)destFilePath
                   progress:(XPFileDownloadProgressBlock)progress
                     finish:(XPFileDownloadFinishBlock)finish;

/**
 文件下载(如果文件已处于下载中状态，则只设置目标文件路径、优先级、下载进度及完成回调)
 
 @param url 文件下载url
 @param destFilePath 目标下载文件路径
 @param priority 下载优先级
 @param progress 下载进度回调
 @param finish 完成回调(有错返回error)
 */
- (void)downloadFileWithUrl:(NSString *)url
               destFilePath:(NSString *)destFilePath
                   priority:(XPFileDownloadPriority)priority
                   progress:(XPFileDownloadProgressBlock)progress
                     finish:(XPFileDownloadFinishBlock)finish;

/**
 取消下载

 @param url 文件下载url
 */
- (void)cancelDownloadWithUrl:(NSString *)url;

/**
 根据url判断是否有下载缓存文件

 @param url 文件下载url
 @return YES: 有下载缓存文件; NO: 没有下载缓存文件
 */
- (XPFileDownloadModel *)isExistDownloadFileCache:(NSString *)url;

@end
