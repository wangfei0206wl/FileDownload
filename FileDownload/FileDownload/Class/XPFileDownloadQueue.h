//
//  XPFileDownloadQueue.h
//  pandora_p
//
//  Created by 王飞 on 2019/4/16.
//  Copyright © 2019 搜狗企业IT部. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPFileDownloadModel.h"

/**
 下载队列
 */
@interface XPFileDownloadQueue : NSObject

/**
 添加一个文件下载(如果已在下载队列，则返回nil)

 @param url 文件下载url
 @return 下载对象模型
 */
- (XPFileDownloadModel *)addFileDownloadWithUrl:(NSString *)url;

/**
 根据task得到文件下载model

 @param task 文件下载task
 @return 下载对象模型
 */
- (XPFileDownloadModel *)fileDownloadWithTask:(NSURLSessionTask *)task;

/**
 更新文件下载

 @param url 文件下载url
 @param totalFileSize 文件总字节数
 */
- (void)updateFileDownloadWithUrl:(NSString *)url totalFileSize:(long long)totalFileSize;

/**
 取消文件下载

 @param url 文件下载url
 */
- (void)cancelFileDownloadWithUrl:(NSString *)url;

/**
 删除一个文件下载

 @param url 文件下载url
 */
- (void)removeFileDonwloadWithUrl:(NSString *)url;

/**
 根据url判断是否有下载缓存文件
 
 @param url 文件下载url
 @return YES: 有下载缓存文件; NO: 没有下载缓存文件
 */
- (XPFileDownloadModel *)isExistDownloadFileCache:(NSString *)url;

/**
 清空所有下载文件及缓存文件
 */
- (void)removeAllFileCaches;

@end
