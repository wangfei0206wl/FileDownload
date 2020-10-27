//
//  XPFileDownloadQueue.m
//  pandora_p
//
//  Created by 王飞 on 2019/4/16.
//  Copyright © 2019 搜狗企业IT部. All rights reserved.
//

#import "XPFileDownloadQueue.h"

@interface XPFileDownloadQueue ()

// 下载model缓存
@property (nonatomic, strong) NSMutableDictionary *dicDownloads;

@end

@implementation XPFileDownloadQueue

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initDownloadCache];
    }
    
    return self;
}

- (XPFileDownloadModel *)addFileDownloadWithUrl:(NSString *)url {
    XPFileDownloadModel *model = nil;
    
    if (kIsStringValid(url)) {
        model = self.dicDownloads[url];
        if (!model) {
            // 缓存中不存在，则创建一个
            @synchronized (self) {
                model = [[XPFileDownloadModel alloc] initWithUrl:url tmpFolderPath:kFileDownloadTmpFolder];
                [self.dicDownloads setValue:model forKey:url];
                [self saveDownloadCache];
            }
        }
    }
    
    return model;
}

- (XPFileDownloadModel *)fileDownloadWithTask:(NSURLSessionTask *)task {
    XPFileDownloadModel *destModel = nil;
    NSArray *arrAllModels = [self.dicDownloads allValues];
    
    for (XPFileDownloadModel *model in arrAllModels) {
        if (model.task == task) {
            destModel = model;
            break;
        }
    }
    
    return destModel;
}

- (void)updateFileDownloadWithUrl:(NSString *)url totalFileSize:(long long)totalFileSize {
    if (kIsStringValid(url)) {
        XPFileDownloadModel *model = self.dicDownloads[url];
        
        if (model) {
            @synchronized (self) {
                model.totalFileSize = totalFileSize;
                [self saveDownloadCache];
            }
        }
    }
}

- (void)cancelFileDownloadWithUrl:(NSString *)url {
    if (kIsStringValid(url)) {
        XPFileDownloadModel *model = self.dicDownloads[url];
        
        if (model) {
            [model.task cancel];
        }
    }
}

- (void)removeFileDonwloadWithUrl:(NSString *)url {
    if (kIsStringValid(url)) {
        @synchronized (self) {
            [self.dicDownloads setValue:nil forKey:url];
            [self saveDownloadCache];
        }
    }
}

- (XPFileDownloadModel *)isExistDownloadFileCache:(NSString *)url {
    XPFileDownloadModel *model = nil;
    
    if (kIsStringValid(url)) {
        model = self.dicDownloads[url];
        if (!model) {
            // 缓存中不存在，则创建一个
            XPFileDownloadModel *tmpModel = [[XPFileDownloadModel alloc] initWithUrl:url tmpFolderPath:kFileDownloadTmpFolder];
            if (tmpModel.cacheFileSize > 0) {
                model = tmpModel;
            }
        }
    }
    
    return model;
}

- (void)removeAllFileCaches {
    @synchronized (self) {
        [XPUtility removeAllFilesInFolder:kFileDownloadTmpFolder];
        
        [self.dicDownloads removeAllObjects];
        [self saveDownloadCache];
    }
}

#pragma mark - private

- (void)initDownloadCache {
    // 初始化下载内存缓存数据
    self.dicDownloads = [NSMutableDictionary dictionary];
    NSArray *arrDownloads = [NSArray arrayWithContentsOfFile:kFileDownloadListFile];
    
    for (NSDictionary *dicDownload in arrDownloads) {
        NSString *url = dicDownload[@"url"];
        XPFileDownloadModel *model = [[XPFileDownloadModel alloc] initWithDictionary:dicDownload];
        
        [self.dicDownloads setValue:model forKey:url];
    }
}

- (void)saveDownloadCache {
    // 保存下载列表到缓存文件
    NSArray *arrCaches = [XPFileDownloadModel localCacheWithModels:self.dicDownloads];
    [arrCaches writeToFile:kFileDownloadListFile atomically:YES];
}

@end
