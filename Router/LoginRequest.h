//
//  LoginRequest.h
//  Router
//
//  Created by xiongzenghui on 16/6/1.
//  Copyright © 2016年 xiongzenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginRequest : NSObject

- (instancetype)initWithUsername:(NSString *)uname password:(NSString *)pwd;

- (void)startWithSuccess:(void (^)(LoginRequest *request))success fail:(void (^)(LoginRequest *request))fail;

@end
