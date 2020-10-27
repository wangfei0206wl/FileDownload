//
//  XPFileDownloadModel.m
//  pandora_p
//
//  Created by 王飞 on 2019/4/16.
//  Copyright © 2019 搜狗企业IT部. All rights reserved.
//

#import "XPFileDownloadModel.h"

@implementation XPFileDownloadModel

- (instancetype)initWithUrl:(NSString *)url tmpFolderPath:(NSString *)tmpFolderPath {
    self = [super init];
    
    if (self) {
        self.url = url;
        // 根据url生成临时文件名
        self.filePath = [tmpFolderPath stringByAppendingPathComponent:[url md5]];
        self.cacheFileSize = [self getCacheFileSize];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.url = dictionary[@"url"];
        self.filePath = dictionary[@"filePath"];
        self.totalFileSize = [dictionary[@"totalFileSize"] longLongValue];
        self.cacheFileSize = [self getCacheFileSize];
    }
    
    return self;
}

- (void)updateCacheFileSize {
    self.cacheFileSize = [self getCacheFileSize];
}

+ (NSArray *)localCacheWithModels:(NSDictionary *)dicModels {
    NSMutableArray *arrCaches = [NSMutableArray array];
    
    for (NSString *key in dicModels.allKeys) {
        XPFileDownloadModel *model = dicModels[key];
        [arrCaches addObject:[model localCacheDictionary]];
    }
    
    return arrCaches;
}

#pragma mark - private

- (long long)getCacheFileSize {
    // 根据filePath得到文件大小
    long long fileSize = 0;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:self.filePath]) {
        NSError *error = nil;
        NSDictionary *dicAttributes = [fileManager attributesOfItemAtPath:self.filePath error:&error];
        
        if (!error && dicAttributes) {
            fileSize = [dicAttributes[NSFileSize] longLongValue];
        }
    }
    
    return fileSize;
}

- (NSDictionary *)localCacheDictionary {
    return @{
             @"url": SafeString(self.url),
             @"filePath": SafeString(self.filePath),
             @"totalFileSize": @(self.totalFileSize),
             };
}

@end
