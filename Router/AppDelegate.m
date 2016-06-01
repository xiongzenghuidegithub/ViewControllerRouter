//
//  AppDelegate.m
//  Router
//
//  Created by xiongzenghui on 16/6/1.
//  Copyright © 2016年 xiongzenghui. All rights reserved.
//

#import "AppDelegate.h"
#import "VC1.h"
#import "VC2.h"
#import "VC3.h"
#import "VC4.h"

#import "XViewControllerRouter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //1.
    UITabBarController *tabvc = [[UITabBarController alloc] init];
    UIViewController *vc1 = [VC1 new];
    UIViewController *vc2 = [VC2 new];
    UIViewController *vc3 = [VC3 new];
    UIViewController *vc4 = [VC4 new];
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
    
    //2.
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tabvc];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    //3.
    [XViewControllerRouter router].rootVC = nav;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
