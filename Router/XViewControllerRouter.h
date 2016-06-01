//
//  ViewControllerRouter.h
//  Router
//
//  Created by xiongzenghui on 16/6/1.
//  Copyright © 2016年 xiongzenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


/**
 *  TabBarController or 自定义容器类VC
 *  需要实现这个协议，在跳转时会调用该协议要求的方法
 */
@protocol XRoutableViewController <NSObject>

@required

/* 设置当前容器VC选中传入的子内容VC */
- (void)setSelectedViewController:(UIViewController *)selectedViewController;

/* 外界获取当前容器VC选中的子内容VC */
- (UIViewController *)selectedViewController;

/* 外界获取当前容器VC中所有的子内容VC */
- (NSArray *)viewControllers;

@optional

/* 设置当前容器VC选中传入的子内容VC，并传入参数 */
- (void)setSelectedViewControllerByParams:(id)params;

@end


@interface XRouteElement : NSObject

@property (nonatomic, assign, readonly) NSInteger routeIndex;
@property (nonatomic, strong, readonly) id routeParams;

- (instancetype)initWithRouteIndex:(NSInteger)index;

- (instancetype)initWithRouteParams:(id)params;

+ (instancetype)routeElementWithRouteIndex:(NSInteger)index;

+ (instancetype)routeElementWithRouteParams:(id)params;

@end

@interface XRouteTarget : NSObject

@property (nonatomic, strong, readonly, nonnull) UIViewController    *targetVC;
@property (nonatomic, strong, readonly, nullable) NSArray             *routePath;
@property (nonatomic, assign, readonly) NSInteger           popDepth;
@property (nonatomic, assign) BOOL                          needDismiss;// 呈现之前是否需要dissmiss之前的VC
@property (nonatomic, strong, nullable) id                            param;

+ (instancetype)targetWithViewController:(UIViewController *)viewController path:(NSArray *)path;
+ (instancetype)targetWithViewController:(UIViewController *)viewController;

- (instancetype)initWithViewController:(UIViewController *)viewController path:(NSArray *)path;
- (instancetype)initWithPopDepth:(NSInteger)popDepth path:(NSArray *)path;

/* 在当前视图栈pop一层 */
+ (instancetype)targetWithPop;

/* 在当前视图栈pop到栈底 */
+ (instancetype)targetWithPopToRoot;

/* 指示在当前视图栈pop的深度 */
+ (instancetype)targetWithPopDepth:(NSInteger)depth;

/* 在当前视图栈pop到指定Class的viewController */
+ (instancetype)targetWithPopToClass:(Class)aClass;

/* 判断Target对象是否带有Pop信息 */
- (BOOL)willPush;

@end

@interface XViewControllerRouter : NSObject

@property (nonatomic, strong) UIViewController *rootVC;

+ (instancetype)router;

/* 栈顶ViewController对象 */
- (UIViewController *)topViewController;

/* 返回被pop掉的所有ViewController对象 */
- (NSArray *)routeTo:(XRouteTarget *)routeTarget;

/* 返回被pop掉的所有ViewController对象 */
- (NSArray *)routeTo:(XRouteTarget *)routeTarget animated:(BOOL)animated;

/* 先pop再push */
- (NSArray *)routeAfterPop:(XRouteTarget *)routeTarget animated:(BOOL)animated;

@end

@interface XViewControllerRouter (Convenience)

+ (NSArray *)pushViewController:(UIViewController *)viewController;

+ (NSArray *)popToViewController:(UIViewController *)viewController;

+ (NSArray *)pop;

+ (NSArray *)popToRoot;

+ (NSArray *)popToClass:(Class)aClass;

+ (NSArray *)popDepth:(NSInteger)depth;

@end
