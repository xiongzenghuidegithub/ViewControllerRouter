//
//  VC1.m
//  Router
//
//  Created by xiongzenghui on 16/6/1.
//  Copyright © 2016年 xiongzenghui. All rights reserved.
//

#import "VC1.h"
#import "XViewControllerRouter.h"


@implementation VC1

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UIViewController *vc = [UIViewController new];
    
    UITabBarController *tabvc = [[UITabBarController alloc] init];
    
    UIViewController *vc1 = [UIViewController new];
    UIViewController *vc2 = [UIViewController new];
    UIViewController *vc3 = [UIViewController new];
    UIViewController *vc4 = [UIViewController new];
    tabvc.viewControllers = @[vc1, vc2, vc3, vc4];
    
    for(int i=0; i<tabvc.tabBar.items.count; i++) {
        UITabBarItem *item = [tabvc.tabBar.items objectAtIndex:i];
        
        item.title = [NSString stringWithFormat:@"子栏目%d",i];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor],UITextAttributeTextColor, nil];
        [item setTitleTextAttributes:dict forState:UIControlStateNormal];
        
        NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor redColor],
                               UITextAttributeTextColor,nil];
        [item setTitleTextAttributes:dict2 forState:UIControlStateSelected];
    }
    
    [XViewControllerRouter pushViewController:tabvc];
}

@end
