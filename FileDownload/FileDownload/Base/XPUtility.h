//
//  XPUtility.h
//  FileDownload
//
//  Created by 王飞 on 2020/10/27.
//

#import <Foundation/Foundation.h>

/// 通用方法
@interface XPUtility : NSObject

/// 文档目录
+ (NSString *)documentPath;

/// 删除指定目录下所有文件
/// @param directory 指定目录
+ (void)removeAllFilesInFolder:(NSString *)directory;

@end
