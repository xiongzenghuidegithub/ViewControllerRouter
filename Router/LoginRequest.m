//
//  LoginRequest.m
//  Router
//
//  Created by xiongzenghui on 16/6/1.
//  Copyright © 2016年 xiongzenghui. All rights reserved.
//

#import "LoginRequest.h"

@interface LoginRequest ()
@property (nonatomic, copy) NSString *uname;
@property (nonatomic, copy) NSString *pwd;
@end

@implementation LoginRequest

- (instancetype)initWithUsername:(NSString *)uname password:(NSString *)pwd
{
    self = [super init];
    if (self) {
        _uname = [uname copy];
        _pwd = [pwd copy];
    }
    return self;
}

- (NSString *)requestMethod {
    return @"GET";
}

- (NSString *)requestPath {
    return @"loginapi/login";
}

- (NSDictionary *)requestHeaders {
    return @{
             @"请求头参数" : @"参数值",
             };
}

- (NSDictionary *)requestParams {
    return @{
             @"uname" : (_uname != nil) ? _uname : @"",
             @"pwd" : (_pwd != nil) ? _pwd : @"",
             };
}

- (Class)responseJSONClass {
    return Nil;
}

// json 验证格式
- (id)jsonValidator {
    return @{
             @"nick": [NSString class],
             @"level": [NSNumber class]
             };
}

// 请求缓存间隔时间
- (NSInteger)cacheTimeInSeconds {
    // 3分钟 = 180 秒
    return 60 * 3;
}

// 读取指定的版本的缓存data
- (NSInteger)cacheVersion {
    return 4;
}


@end
