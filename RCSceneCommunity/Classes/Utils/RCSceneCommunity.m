//
//  RCSceneCommunity.m
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/17.
//

#import "RCSceneCommunity.h"

#define RCSceneCommunityVersion @"1.0.0"

@implementation RCSceneCommunity

+ (void)load {
    Class class = NSClassFromString(@"RCUtilities");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (class && [class respondsToSelector:@selector(setModuleName: version:)]) {
        [class performSelector:@selector(setModuleName: version:)
#pragma clang diagnostic pop
                    withObject:@"scenecommunity"
                    withObject:RCSceneCommunityVersion];
    }
}

+ (NSString *)getVersion {
    return RCSceneCommunityVersion;
}
@end
