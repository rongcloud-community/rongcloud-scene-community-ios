//
//  NSString+NSString_RCSC.m
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/25.
//

#import "NSString+NSString_RCSC.h"
#import <objc/runtime.h>

@implementation NSString (NSString_RCSC)
+ (void)load {
    static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self swizzleInstanceMethod:[NSString class] original:@selector(pathExtension) swizzled:@selector(rcsc_pathExtension)];
        });
}

+ (void)swizzleInstanceMethod:(Class)target original:(SEL)originalSelector swizzled:(SEL)swizzledSelector {
    Method originMethod = class_getInstanceMethod(target, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(target, swizzledSelector);
    method_exchangeImplementations(originMethod, swizzledMethod);
}

- (NSString *)rcsc_pathExtension {
    NSString *extension = [self rcsc_pathExtension];
    if ([extension hasPrefix:@"mp4"]) {
        NSArray<NSString *> *result = [extension componentsSeparatedByString:@"?"];
        if (result.count == 2 && [result.firstObject isEqualToString:@"mp4"]) {
            return result.firstObject;
        }
    }
    return [self rcsc_pathExtension];
}
@end
