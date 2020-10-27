//
//  SynthesizeSingleton.h
//  XinYan
//
//  Created by 王飞 on 2019/1/25.
//  Copyright © 2019 企业IT. All rights reserved.
//

#ifndef SynthesizeSingleton_h
#define SynthesizeSingleton_h

#define DEFINE_SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared;

#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}


#endif /* SynthesizeSingleton_h */
