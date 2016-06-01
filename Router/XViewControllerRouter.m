//
//  ViewControllerRouter.m
//  Router
//
//  Created by xiongzenghui on 16/6/1.
//  Copyright © 2016年 xiongzenghui. All rights reserved.
//

#import "XViewControllerRouter.h"

static const NSInteger PopDepthError = -1;
static const NSInteger PopClass = -2;

static XViewControllerRouter *_router = NULL;

@implementation XViewControllerRouter (Convenience)

+ (NSArray *)push:(UIViewController *)viewController {
    return [[XViewControllerRouter router] routeTo:[XRouteTarget targetWithViewController:viewController]];
}

+ (NSArray *)popTo:(UIViewController *)viewController{
    return [[XViewControllerRouter router] routeTo:[XRouteTarget targetWithViewController:viewController]];
}

+ (NSArray *)pop {
    return [[XViewControllerRouter router] routeTo:[XRouteTarget targetWithPop]];
}

+ (NSArray *)popToRoot {
    return [[XViewControllerRouter router] routeTo:[XRouteTarget targetWithPopToRoot]];
}

+ (NSArray *)popToClass:(Class)aClass {
    return [[XViewControllerRouter router] routeTo:[XRouteTarget targetWithPopToClass:aClass]];
}

+ (NSArray *)popDepth:(NSInteger)depth {
    return [[XViewControllerRouter router] routeTo:[XRouteTarget targetWithPopDepth:depth]];
}

@end

@implementation XViewControllerRouter

+ (instancetype)router {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _router = [[XViewControllerRouter alloc] init];
    });
    return _router;
}

- (UIViewController *)topViewController {
    return [self x_topViewController:_rootVC];
}

- (NSArray *)routeTo:(XRouteTarget *)routeTarget {
    return [self routeTo:routeTarget animated:YES];
}

- (NSArray *)routeTo:(XRouteTarget *)routeTarget animated:(BOOL)animated {
    if (routeTarget==nil) {
        //TODO: target为nil，什么都不做
        return nil;
    }
    
    if (routeTarget.needDismiss) {
        UIViewController *topViewController = [self topViewController];
        UIViewController *presentingVC = topViewController.presentingViewController;
        
        // 对于present出来的VC，判断是否push之前需要dismiss掉之前的VC
        if (presentingVC != nil) {
            __weak __typeof(self)weakSelf = self;
            [topViewController dismissViewControllerAnimated:animated completion:^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf routeTo:routeTarget animated:animated];
            }];
            return nil;
        }else{
            return [self x_routeToTargetAfterDismiss:routeTarget animated:animated];
        }
    }else{
        return [self x_routeToTargetAfterDismiss:routeTarget animated:animated];
    }
}

- (NSArray *)routeAfterPop:(XRouteTarget *)routeTarget animated:(BOOL)animated {
    if (routeTarget.needDismiss) {
        UIViewController *topViewController = [self topViewController];
        UIViewController *presentingVC = topViewController.presentingViewController;
        if (presentingVC!=nil) {
            [topViewController dismissViewControllerAnimated:animated completion:^{
                [self routeAfterPop:routeTarget animated:animated];
            }];
            return nil;
        }else{
            return [self x_routeToTargetAfterPopAfterDismiss:routeTarget animated:animated];
        }
    }else{
        return [self x_routeToTargetAfterPopAfterDismiss:routeTarget animated:animated];
    }
}

- (NSArray *)x_routeToTargetAfterDismiss:(XRouteTarget*)routeTarget animated:(BOOL)animated{
    UIViewController *rootVC = _rootVC;
    
    if (routeTarget.routePath == nil) {//当前UINavigationController视图栈push或者pop
        // 页面统计事件暂时不需要
//        if (routeTarget.param != nil) {
//            routeTarget.targetVC.pageEvent.parentPage = routeTarget.param;
//        }
        UINavigationController *container = [self topViewController].navigationController;
        return [self x_routeTo:routeTarget inContainer:container animated:animated];
    }
    
    if (!(rootVC = [self x_jumpByPath:routeTarget.routePath fromRootController:rootVC])){
        //在tabbar或者自定义容器VC中跳转，进行选中操作，而不是push
        return nil;
    };
    
    NSArray *popedViewControllers=nil;
    if (routeTarget.targetVC != nil) {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            //NavigaitonController，做push操作
            popedViewControllers=[self x_routeTo:routeTarget inContainer:(UINavigationController *)rootVC animated:animated];
        }else if ([rootVC conformsToProtocol:@protocol(XRoutableViewController)]){
            //TabBarController、自定义容器VC，做selected操作
            if ([[(UIViewController <XRoutableViewController>*)rootVC viewControllers] indexOfObject:routeTarget.targetVC] != NSNotFound) {
                // VC存在于TabVC容器中
                if ([rootVC respondsToSelector:@selector(setSelectedViewController:)]){
                    [rootVC performSelector:@selector(setSelectedViewController:) withObject:routeTarget.targetVC];
                }
            }
        }
    }else if (routeTarget.param!=nil){
        // 页面统计事件暂时不需要
//        if ([rootVC isKindOfClass:[UINavigationController class]]){
//            [[[(UINavigationController *) rootVC viewControllers] firstObject] pageEvent].parentPage=routeTarget.param;
//        }else {
//            rootVC.pageEvent.parentPage = routeTarget.param;
//        }
    }
    return popedViewControllers;
}

- (NSArray *)x_routeToTargetAfterPopAfterDismiss:(XRouteTarget *)routeTarget animated:(BOOL)animated{
    UIViewController *rootVC = _rootVC;
    if (routeTarget.routePath == nil) {//当前UINavigationController视图栈push或者pop
        if (routeTarget.param!=nil) {
//            routeTarget.targetVC.pageEvent.parentPage = routeTarget.param;
        }
        return [self pushController:routeTarget.targetVC afterPopAllInContainer:[self topViewController].navigationController animated:animated];
    }
    
    if (!(rootVC = [self x_jumpByPath:routeTarget.routePath fromRootController:rootVC])){//在tabbar或者自定义容器VC中跳转
        return nil;
    };
    
    NSArray *popedViewControllers=nil;
    if (routeTarget.targetVC!=nil) {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {//最后的位置在NavigaitonController，做push操作
            popedViewControllers=[self x_routeTo:routeTarget inContainer:(UINavigationController *)rootVC animated:animated];
        }else if ([rootVC conformsToProtocol:@protocol(XRoutableViewController)]){//最后的位置在TabBarController或者自定义容器VC，做selected操作
            if ([[(UIViewController <XRoutableViewController>*)rootVC viewControllers] indexOfObject:routeTarget.targetVC] != NSNotFound) {
                if ([rootVC respondsToSelector:@selector(setSelectedViewController:)]){
                    [rootVC performSelector:@selector(setSelectedViewController:) withObject:routeTarget.targetVC];
                }
            }
        }
    }else if (routeTarget.param!=nil){
//        if ([rootVC isKindOfClass:[UINavigationController class]]){
//            [[[(UINavigationController *) rootVC viewControllers] firstObject] pageEvent].parentPage=routeTarget.param;
//        }else {
//            rootVC.pageEvent.parentPage = routeTarget.param;
//        }
    }
    return popedViewControllers;
}

- (UIViewController *)x_jumpByPath:(NSArray *)routePath fromRootController:(UIViewController *)rootViewController{
    
    for (int i = 0; i < [routePath count]; i++) {
        
        if ([rootViewController isKindOfClass:[UINavigationController class]]) {//navigation VC
            //取其视图栈内的第一个 视图VC
            
            UIViewController *containerVC = [self x_findContainerInNavigationController:(UINavigationController *)rootViewController];
            if (!containerVC) {
                rootViewController = [[(UINavigationController *)rootViewController viewControllers] lastObject];
            }else{
                [self pushController:containerVC toContainer:(UINavigationController *)rootViewController animated:YES];
                rootViewController = containerVC;
            }
        }
        
        if ([rootViewController conformsToProtocol:@protocol(XRoutableViewController)]) {//自定义容器VC
            XRouteElement *element=(XRouteElement *)routePath[i];
            
            //一个element可能提供有index信息或者params信息，分别做处理
            
            if (element.routeParams != nil) {
                //让容器VC进行选中tab vc传入参数
                if ([rootViewController respondsToSelector:@selector(setSelectedViewControllerByParams:)]) {
                    [rootViewController performSelector:@selector(setSelectedViewControllerByParams:)
                                             withObject:((XRouteElement *)routePath[i]).routeParams];
                }
            }else{
                //根据index跳转，要先判断index是否超出范围
                NSArray *viewControllers = [(UIViewController <XRoutableViewController>*)rootViewController viewControllers];
                UIViewController *targetController;
                
                BOOL isOver = element.routeIndex < 0 || element.routeIndex >= [viewControllers count];
                
                if (isOver) {
                    // 如果超出范围默认使用当前容器VC选中的视图VC
                    targetController = [(UIViewController <XRoutableViewController>*)rootViewController selectedViewController];
                }else{
                    targetController = viewControllers[element.routeIndex];
                }
                
                if ([rootViewController respondsToSelector:@selector(setSelectedViewController:)]){
                    [rootViewController performSelector:@selector(setSelectedViewController:) withObject:targetController];
                }
            }
            rootViewController = [(UIViewController <XRoutableViewController>*)rootViewController selectedViewController];
        }else {
            return nil;
        }
    }
    
    return rootViewController;
}

- (NSArray *)x_routeTo:(XRouteTarget *)routeTarget inContainer:(UINavigationController *)container animated:(BOOL)animated{
    if ([routeTarget willPush]) {
        if (routeTarget.targetVC == nil) {
            return nil;
        }
        return [self pushController:routeTarget.targetVC toContainer:container animated:animated];
    }else if (routeTarget.popDepth != PopClass){
        return [self popWithDepth:routeTarget.popDepth forContainer:container animated:animated];
    }else {
        return [self popWithClass:routeTarget.param forContainer:container animated:animated];
    }
}

// 将 视图VC 放入 容器VC栈顶 显示出来
- (NSArray *)pushController:(UIViewController *)controller toContainer:(UINavigationController *)containerNav animated:(BOOL)animated{
    if ([containerNav.viewControllers indexOfObject:controller] != NSNotFound) {
        //controller 存在于 容器VC中
        return [containerNav popToViewController:controller animated:animated];
    }else{
        // controller 不存在于 容器VC中
        if (controller==nil) {
            return nil;
        }else{
            [containerNav pushViewController:controller animated:animated];
            return nil;
        }
    }
}

- (NSArray *)popWithDepth:(NSInteger)depth forContainer:(UINavigationController *)containerNav animated:(BOOL)animated{
    if (depth<=0) {
        return nil;
    }
    NSArray *currentVCStack=[containerNav viewControllers];
    if (depth>=[currentVCStack count]) {
        return [containerNav popToRootViewControllerAnimated:animated];
    }else{
        return [containerNav popToViewController:currentVCStack[[currentVCStack count]-depth-1] animated:animated];
    }
}

- (NSArray *)popWithClass:(Class)aClass forContainer:(UINavigationController *)containerNav animated:(BOOL)animated{
    NSString *className=NSStringFromClass(aClass);
    if ([className length]<=0) {
        return nil;
    }
    NSArray *currentVCStack=[containerNav viewControllers];
    for (UIViewController *subVC in currentVCStack) {
        if ([subVC isKindOfClass:aClass]) {
            return [containerNav popToViewController:subVC animated:animated];
        }
    }
    return nil;
}

- (NSArray *)pushController:(UIViewController *)controller afterPopAllInContainer:(UINavigationController *)containerNav animated:(BOOL)animated{
    NSArray *popedViewController=nil;
    if (controller==nil || controller==containerNav.viewControllers[0]) {
        popedViewController=[containerNav popToRootViewControllerAnimated:animated];
    }else{
        NSMutableArray *viewControllers=[NSMutableArray arrayWithArray:[containerNav viewControllers]];
        [viewControllers removeObjectAtIndex:0];
        popedViewController=[viewControllers copy];
        NSArray *vcs=@[containerNav.viewControllers[0],controller];
        [containerNav setViewControllers:vcs animated:animated];
    }
    return popedViewController;
}

- (void)pushViewControllers:(NSArray *)viewControllers willPopBefore:(BOOL)willPopBefore{
    UINavigationController *nav=[self topViewController].navigationController;
    if (willPopBefore==NO) {
        for (UIViewController *viewController in viewControllers) {
            if ([nav.viewControllers indexOfObject:viewController]) {
                NSLog(@"%@",@"试图push已经存在的viewController");
                return;
            }
        }
    }
    NSMutableArray *vcs=[NSMutableArray arrayWithArray:nav.viewControllers];
    if (!willPopBefore) {
        [vcs addObjectsFromArray:viewControllers];
    }else{
        vcs = [NSMutableArray arrayWithObject:vcs[0]];
        [vcs addObjectsFromArray:viewControllers];
    }
    [nav setViewControllers:vcs animated:YES];
}

- (UIViewController *)x_topViewController:(UIViewController *)rootVC {
    
    // 过滤 UITabBarController
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        return [self x_topViewController:[(UITabBarController *)rootVC selectedViewController]];
    }
    
    // 过滤 UINavigationController
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootVC;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self x_topViewController:lastViewController];
    }
    
    // 过滤 presentViewController
    if (rootVC.presentedViewController) {
        return [self x_topViewController:rootVC.presentedViewController];
    }
    
    // 找到视图VC直接返回
    return rootVC;
}

// 返回 UINavigationController的stack内 查找 `TabBarController or 自定义容器类VC` 第一个
- (UIViewController<XRoutableViewController> *)x_findContainerInNavigationController:(UINavigationController *)navigationVC{
    NSArray *viewControllers=[navigationVC viewControllers];
    for (UIViewController *vc in viewControllers) {
        if ([vc conformsToProtocol:@protocol(XRoutableViewController)]) {
            return (UIViewController<XRoutableViewController> *)vc;
        }
    }
    return nil;
}

+ (UIWindow *)x_keyWindow {
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    
    UIWindow *keyWindow = nil;
    for (UIWindow *window in frontToBackWindows){
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            keyWindow = window;
            break;
        }
    }
    
    return keyWindow;
}

@end

@implementation XRouteElement

- (id)init{
    return [self initWithRouteIndex: PopDepthError];
}

- (instancetype)initWithRouteIndex:(NSInteger)index{
    self = [super init];
    if (self) {
        _routeIndex=index;
        _routeParams=nil;
    }
    return self;
}

- (instancetype)initWithRouteParams:(id)params{
    self = [super init];
    if (self) {
        _routeIndex = NSNotFound;
        _routeParams = params;
    }
    return self;
}

+ (instancetype)routeElementWithRouteIndex:(NSInteger)index{
    return [[XRouteElement alloc] initWithRouteIndex:index];
}

+ (instancetype)routeElementWithRouteParams:(id)params{
    return [[XRouteElement alloc] initWithRouteParams:params];
}

- (void)dealloc{
    _routeParams=nil;
}

@end

@implementation XRouteTarget

- (instancetype)init{
    return [self initWithViewController:nil path:nil];
}

- (instancetype)initWithViewController:(UIViewController *)viewController path:(NSArray *)path{
    self = [super init];
    if (self) {
        if (viewController==nil && path==nil) {
            @throw [NSException exceptionWithName:@"参数错误" reason:@"跳转目标和跳转路径不能同为空" userInfo:nil];
        }
        _targetVC = viewController;
        _popDepth = PopDepthError;
        _routePath = path;
    }
    return self;
}

- (instancetype)initWithPopDepth:(NSInteger)popDepth path:(NSArray *)path{
    self = [super init];
    if (self) {
        if (popDepth<=0 && popDepth!=PopClass) {
            popDepth=PopDepthError;
        }
        if (popDepth==PopDepthError && path==nil) {
            @throw [NSException exceptionWithName:@"参数错误" reason:@"弹栈深度和跳转路径不能同为空" userInfo:nil];
        }
        _targetVC=nil;
        _popDepth=popDepth;
        _routePath=path;
    }
    return self;
}

+ (instancetype)targetWithViewController:(UIViewController *)viewController path:(NSArray *)path{
    return [[XRouteTarget alloc] initWithViewController:viewController path:path];
}

+ (instancetype)targetWithViewController:(UIViewController *)viewController{
    return [self targetWithViewController:viewController path:nil];
}

+ (instancetype)targetWithPop{
    return [XRouteTarget targetWithPopDepth:1];
}

+ (instancetype)targetWithPopToRoot{
    return [XRouteTarget targetWithPopDepth:NSIntegerMax];
}

+ (instancetype)targetWithPopDepth:(NSInteger)depth {
    return [[XRouteTarget alloc] initWithPopDepth:depth path:nil];
}

+ (instancetype)targetWithPopToClass:(Class)aClass {
    XRouteTarget *routeTarget = [[XRouteTarget alloc] initWithPopDepth:PopClass path:nil];
    routeTarget.param=aClass;
    return routeTarget;
}

- (BOOL)willPush{
    return self.popDepth<=0 && self.popDepth!=PopClass;
}

- (void)dealloc{
    _targetVC=nil;
    _routePath=nil;
    _param=nil;
}

@end

@implementation UITabBarController (Router)

- (void)setSelectedViewControllerByParams:(id)params{
    Class targetClass = params;
    
    for (UIViewController *controller in self.viewControllers) {
        
        if ([controller isKindOfClass:targetClass]) {
            [self setSelectedViewController:controller];
            return;
        }
        
        if ([controller isKindOfClass:[UINavigationController class]]
            && [((UINavigationController *)controller).viewControllers[0] isKindOfClass:targetClass]) {
            [self setSelectedViewController:controller];
            return;
        }
    }
}

@end