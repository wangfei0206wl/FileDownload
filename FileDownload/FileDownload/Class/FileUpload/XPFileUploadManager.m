//
//  XPFileUploadManager.m
//  FileDownload
//
//  Created by 王飞 on 2020/11/6.
//

#import "XPFileUploadManager.h"
#import "AFNetworking.h"

// 文件上传地址
#define xp_fileupload_url @""

@implementation XPFileUploadManager

DEFINE_SINGLETON_FOR_CLASS(XPFileUploadManager)

- (void)uploadFileWithData:(NSData *)data fileName:(NSString *)fileName progress:(XPFileUploadProgressBlock)progress finish:(XPFileUploadFinishBlock)finish {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 5;
    
    [manager POST:xp_fileupload_url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"Filedata" fileName:fileName mimeType:@"multipart/form-data"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(uploadProgress.fractionCompleted);
            }
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (finish) {
            finish(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (finish) {
            finish(error);
        }
    }];
}

@end
