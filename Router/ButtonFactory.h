//
//  ButtonFactory.h
//  Router
//
//  Created by xiongzenghui on 16/6/1.
//  Copyright © 2016年 xiongzenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Button1 : UIButton

@end

@interface Button2 : UIButton

@end

@interface ButtonFactory : NSObject

+ (Button1 *)btn1;
+ (Button1 *)btn2;


@end
