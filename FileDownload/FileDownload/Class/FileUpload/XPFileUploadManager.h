//
//  XPFileUploadManager.h
//  FileDownload
//
//  Created by 王飞 on 2020/11/6.
//

#import <Foundation/Foundation.h>

/**
 文件上传实现是基于AFN的方法实现，不做说明
 至于大文件分块断点续传，需要客户端与服务端确定一套协议来实现，网上相关文章很多，这里不做描述
 以后有空再补一套方案吧~~
 */
/// 文件上传管理类
@interface XPFileUploadManager : NSObject

DEFINE_SINGLETON_FOR_HEADER(XPFileUploadManager)

// 上传进度回调定义
typedef void(^XPFileUploadProgressBlock)(double fractionCompleted);
// 上传完成回调定义
typedef void(^XPFileUploadFinishBlock)(NSError *error);

- (void)uploadFileWithData:(NSData *)data fileName:(NSString *)fileName progress:(XPFileUploadProgressBlock)progress finish:(XPFileUploadFinishBlock)finish;

@end
