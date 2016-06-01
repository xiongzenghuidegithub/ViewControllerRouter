//
//  ViewController.m
//  Router
//
//  Created by xiongzenghui on 16/6/1.
//  Copyright © 2016年 xiongzenghui. All rights reserved.
//

#import "ViewController.h"
#import "LoginRequest.h"

@interface ViewController ()
@property (nonatomic, strong)  LoginRequest *req;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self callApi];
}

- (void)callApi {
    //1.
    _req = [[LoginRequest alloc] initWithUsername:@"zhangsan" password:@"12345"];
    
    //2.
    [_req startWithSuccess:^(LoginRequest *request) {
        //success
    } fail:^(LoginRequest *request) {
        //failt
    }];
}

@end
