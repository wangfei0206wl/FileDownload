//
//  XPGlobalMacro.h
//  FileDownload
//
//  Created by 王飞 on 2020/10/27.
//

#ifndef XPGlobalMacro_h
#define XPGlobalMacro_h

//判断字符串是否有效
#define kIsStringValid(text) (text && [text isKindOfClass:[NSString class]] && [text length] > 0)
// 字符串安全处理
#define SafeString(str)  ((str == nil)?@"":str)
// 字典安全处理(用于setobject:forKey:方法设置时出现字典为nil导致crash)
#define SafeDictionary(dictionary) ((dictionary == nil)?@{}:dictionary)

#import "NSString+Extends.h"
#import "SynthesizeSingleton.h"

#endif /* XPGlobalMacro_h */
