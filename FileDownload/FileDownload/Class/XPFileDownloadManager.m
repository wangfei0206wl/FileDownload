//
//  XPFileDownloadManager.m
//  pandora_p
//
//  Created by 王飞 on 2019/4/16.
//  Copyright © 2019 搜狗企业IT部. All rights reserved.
//

#import "XPFileDownloadManager.h"
#import "XPFileDownloadQueue.h"

@interface XPFileDownloadManager () <NSURLSessionDataDelegate>

// 下载队列
@property (nonatomic, strong) XPFileDownloadQueue *downloadQueue;

@end

@implementation XPFileDownloadManager

DEFINE_SINGLETON_FOR_CLASS(XPFileDownloadManager)

- (void)initForAppRun {
    self.downloadQueue = [[XPFileDownloadQueue alloc] init];
}

- (void)downloadFileWithUrl:(NSString *)url
               destFilePath:(NSString *)destFilePath
                   progress:(XPFileDownloadProgressBlock)progress
                     finish:(XPFileDownloadFinishBlock)finish {
    [self downloadFileWithUrl:url destFilePath:destFilePath priority:XPFileDownloadPriorityDefault progress:progress finish:finish];
}

- (void)downloadFileWithUrl:(NSString *)url
               destFilePath:(NSString *)destFilePath
                   priority:(XPFileDownloadPriority)priority
                   progress:(XPFileDownloadProgressBlock)progress
                     finish:(XPFileDownloadFinishBlock)finish {
    XPFileDownloadModel *model = [self downloadModelWithUrl:url destFilePath:destFilePath priority:priority progress:progress finish:finish];
    
    if (!model.bDownloading) {
        // 下载流程
        model.bDownloading = YES;

        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDelegate>)self delegateQueue:[NSOperationQueue mainQueue]];
        NSMutableURLRequest *request = [self initializeRequest:model];
        NSURLSessionDataTask *task = [self initializeSessionTask:session request:request model:model];

        [task resume];
    }
}

- (void)cancelDownloadWithUrl:(NSString *)url {
    [self.downloadQueue cancelFileDownloadWithUrl:url];
}

- (XPFileDownloadModel *)isExistDownloadFileCache:(NSString *)url {
    return [self.downloadQueue isExistDownloadFileCache:url];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    // 根据dataTask找到对应的model
    NSLog(@"---------XPFileDownloadManager receive response");
    XPFileDownloadModel *model = [self.downloadQueue fileDownloadWithTask:dataTask];
    
    if (model) {
        NSOutputStream *outputStream = model.outputStream;
        long long totalFileSize = response.expectedContentLength + model.cacheFileSize;
        
        [self.downloadQueue updateFileDownloadWithUrl:model.url totalFileSize:totalFileSize];
        [outputStream open];
    }
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // 处理数据接收回调
    NSLog(@"---------XPFileDownloadManager receive data");
    XPFileDownloadModel *model = [self.downloadQueue fileDownloadWithTask:dataTask];
    NSOutputStream *outputStream = model.outputStream;
    
    
    if (data && outputStream && model) {
        NSInteger result = [outputStream write:data.bytes maxLength:data.length];
        
        if (result == -1) {
            NSLog(@"---------XPFileDownloadManager write file failure");
            [dataTask cancel];
        } else {
            [model updateCacheFileSize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model.progressBlock) {
                    model.progressBlock(model.cacheFileSize, model.totalFileSize);
                }
            });
        }
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"---------XPFileDownloadManager complete download");
    XPFileDownloadModel *model = [self.downloadQueue fileDownloadWithTask:task];
    NSOutputStream *outputStream = model.outputStream;
    
    if (model && outputStream) {
        [outputStream close];
        // 下载结束，则删除此下载任务
        [self.downloadQueue removeFileDonwloadWithUrl:model.url];

        if (!error) {
            if (kIsStringValid(model.destFilePath)) {
                // 转换文件到指定目录
                NSURL *srcFileUrl = [[NSURL alloc] initFileURLWithPath:model.filePath];
                NSURL *destFileUrl = [[NSURL alloc] initFileURLWithPath:model.destFilePath];
                // 这里将旧的目标文件删除(如果存在的话)，如果不删除，moveItemAtURL就会无效
                if ([[NSFileManager defaultManager] fileExistsAtPath:model.destFilePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:model.destFilePath error:nil];
                }
                [[NSFileManager defaultManager] moveItemAtURL:srcFileUrl toURL:destFileUrl error:nil];
            }
        } else {
            // 失败了
            model.bDownloading = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (model.finishBlock) {
                model.finishBlock(error, [model destFilePath]);
            }
        });
    }
}

#pragma mark - private

- (XPFileDownloadModel *)downloadModelWithUrl:(NSString *)url
                                 destFilePath:(NSString *)destFilePath
                                     priority:(XPFileDownloadPriority)priority
                                     progress:(XPFileDownloadProgressBlock)progress
                                       finish:(XPFileDownloadFinishBlock)finish {
    XPFileDownloadModel *model = [self.downloadQueue addFileDownloadWithUrl:url];
    
    model.destFilePath = destFilePath;
    model.progressBlock = progress;
    model.finishBlock = finish;
    model.priority = [self sessionTaskPriority:priority];
    
    return model;
}

- (CGFloat)sessionTaskPriority:(XPFileDownloadPriority)priority {
    CGFloat value = NSURLSessionTaskPriorityDefault;
    
    switch (priority) {
        case XPFileDownloadPriorityLow:
            value = NSURLSessionTaskPriorityLow;
            break;
        case XPFileDownloadPriorityMid:
            value = (NSURLSessionTaskPriorityLow + NSURLSessionTaskPriorityHigh) / 2;
            break;
        case XPFileDownloadPriorityHigh:
            value = NSURLSessionTaskPriorityHigh;
            break;
        case XPFileDownloadPriorityDefault:
            value = NSURLSessionTaskPriorityDefault;
            break;
    }

    return value;
}

- (NSMutableURLRequest *)initializeRequest:(XPFileDownloadModel *)model {
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:model.url]];
    
    // 设置HTTP的header中的Range
    NSString *rangeString = [NSString stringWithFormat:@"bytes=%lld-", model.cacheFileSize];
    [request setValue:rangeString forHTTPHeaderField:@"Range"];
    
    // 设置HTTP请求超时
    request.timeoutInterval = 10;
    
    return request;
}

- (NSURLSessionDataTask *)initializeSessionTask:(NSURLSession *)session request:(NSURLRequest *)request model:(XPFileDownloadModel *)model {
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];

    task.priority = model.priority;
    model.task = task;
    model.outputStream = [[NSOutputStream alloc] initWithURL:[NSURL fileURLWithPath:model.filePath] append:YES];
    
    return task;
}

@end
