//
//  XPFileDownloadModel.h
//  pandora_p
//
//  Created by 王飞 on 2019/4/16.
//  Copyright © 2019 搜狗企业IT部. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPFileDownloadHeader.h"

/**
 下载model
 */
@interface XPFileDownloadModel : NSObject

// 文件下载url
@property (nonatomic, strong) NSString *url;
// 文件本地保存路径(统一放到tmp目录下，下载完成后，外部可将文件移到其他目录)
@property (nonatomic, strong) NSString *filePath;
// 文件缓存字节数
@property (nonatomic, assign) long long cacheFileSize;
// 文件总字节数
@property (nonatomic, assign) long long totalFileSize;
// 下载文件的最终路径
@property (nonatomic, strong) NSString *destFilePath;
// 设置优先级(与session task的一致)
@property (nonatomic, assign) CGFloat priority;
// 是否处于下载中
@property (nonatomic, assign) BOOL bDownloading;
// 下载task
@property (nonatomic, strong) NSURLSessionTask *task;
// 文件流
@property (nonatomic, strong) NSOutputStream *outputStream;
// 下载进度回调
@property (nonatomic, copy) XPFileDownloadProgressBlock progressBlock;
// 下载完成回调
@property (nonatomic, copy) XPFileDownloadFinishBlock finishBlock;

/**
 实例化对象

 @param url 文件下载url
 @param tmpFolderPath 文件缓存文件夹路径
 @return 对象
 */
- (instancetype)initWithUrl:(NSString *)url tmpFolderPath:(NSString *)tmpFolderPath;

/**
 实例化对象(本地缓存下载列表数据)

 @param dictionary 字典数据
 @return 对象
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 更新文件缓存字节数
 */
- (void)updateCacheFileSize;

/**
 生成本地缓存下载列表数据

 @param dicModels 下载models
 @return 本地缓存下载列表数据
 */
+ (NSArray *)localCacheWithModels:(NSDictionary *)dicModels;

@end
