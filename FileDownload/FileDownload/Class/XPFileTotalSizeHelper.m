//
//  XPFileTotalSizeHelper.m
//  FileDownload
//
//  Created by 王飞 on 2020/10/27.
//

#import "XPFileTotalSizeHelper.h"

#define kFinishHandler(finish, totalSize, bSuccess) \
if (finish) {\
    finish(totalSize, bSuccess);\
}

@interface XPFileTotalSizeHelper ()

@property (nonatomic, copy) void(^finishHandler)(long long totalSize, BOOL bSuccess);

@end

@implementation XPFileTotalSizeHelper

- (void)asyncFileSizeWithUrl:(NSString *)url finish:(void(^)(long long totalSize, BOOL bSuccess))finish {
    if (kIsStringValid(url)) {
        self.finishHandler = finish;
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"HEAD"];
        request.timeoutInterval = 5.0;
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDelegate>)self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
        [dataTask resume];
    } else {
        kFinishHandler(finish, 0, NO)
    }
    
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSDictionary *dicField = [(NSHTTPURLResponse *)response allHeaderFields];
    long long fileSize = [dicField[@"Content-Length"] longLongValue];
    
    kFinishHandler(self.finishHandler, fileSize, YES)
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    kFinishHandler(self.finishHandler, 0, NO)
}

@end
