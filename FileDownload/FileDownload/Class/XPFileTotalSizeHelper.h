//
//  XPFileTotalSizeHelper.h
//  FileDownload
//
//  Created by 王飞 on 2020/10/27.
//

#import <Foundation/Foundation.h>

/// 获取文件大小工具类
@interface XPFileTotalSizeHelper : NSObject

/// 异步获取下载文件大小(http方式)
/// @param url 文件下载地址
/// @param finish 完成回调
- (void)asyncFileSizeWithUrl:(NSString *)url finish:(void(^)(long long totalSize, BOOL bSuccess))finish;

@end
