//
//  XPUtility.m
//  FileDownload
//
//  Created by 王飞 on 2020/10/27.
//

#import "XPUtility.h"

@implementation XPUtility

+ (NSString *)documentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

@end
