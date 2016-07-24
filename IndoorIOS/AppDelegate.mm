//
//  AppDelegate.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/11/20.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK-2.0/AlipaySDK/AlipaySDK.h>
#import "CADPayViewController.h"
#import "CADStoryBoardUtilities.h"
#import "CADStartViewController.h"
#import "SDWebImageManager.h"
#import "ImageLoader.h"
#import "AFNetworkActivityIndicatorManager.h"

// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>

@interface AppDelegate ()

// the main data model for our UITableView
@property (nonatomic, strong) NSArray *stadiums;

@end

BMKMapManager* _mapManager;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // launch screen显示增加1秒
//    [NSThread sleepForTimeInterval:1.0];
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"lcYxq08FGbAZ8OqlYLsn5qlT" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    // [self.window makeKeyAndVisible];
    
    ///////////////////////////////////////////////////////////////////////////////////
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
//    UITabBarController* tabController = (UITabBarController*)[CADStoryBoardUtilities viewControllerForStoryboardName:@"Home" class:[UITableViewController class]];
    
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeTabBarController"];
    */
    
    UINavigationController *rootViewController = (UINavigationController *)[CADStoryBoardUtilities viewControllerForStoryboardName:@"Start" class:[CADStartViewController class]];
    
    [self.window setRootViewController:rootViewController];
    
    [self setupNavigationTitleLabelStyle];
    [self setupStatusBarStyle];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [SDWebImageManager sharedManager].delegate = [ImageLoader sharedImageLoader];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return YES;
}

#pragma mark -
#pragma mark App Style Setup Methods

- (void)setupNavigationTitleLabelStyle
{
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:@"GillSans-Light" size:20] forKey:NSFontAttributeName];
    [titleBarAttributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

- (void)setupStatusBarStyle
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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

// BaiduMapManager callback
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

// BaiduMapManager callback
- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

// Alipay callback
/*
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //如果极简 SDK 不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给 SDK
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            // 使用支付宝钱包时，回调到这里
            NSLog(@"异步返回 safepay result = %@",resultDic);
            [self alipayResultHandler:resultDic];
        }];
    }
    if ([url.host isEqualToString:@"platformapi"]){
        //支付宝钱包快登授权返回 authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
//            NSLog(@"异步返回 platformapi result = %@",resultDic);
            [self alipayResultHandler:resultDic];
        }];
    }
    return YES;
}
 */

-(void) alipayResultHandler:(NSDictionary*) resultDic
{
    int resultCode = [[resultDic objectForKey:@"resultStatus"] intValue];
    NSString *title = [[NSString alloc] init];
    bool success = false;
    switch (resultCode) {
        case 9000:
            title = @"订单支付成功";
            success = true;
            break;
        case 8000:
            title = @"正在处理中";
            break;
        case 4000:
            title = @"订单支付失败";
            break;
        case 6001:
            title = @"用户中途取消";
            break;
        case 6002:
            title = @"网络连接出错";
            break;
    }
    NSString *memo = [resultDic objectForKey:@"memo"];
    
    if (success){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:memo
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:memo
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            [self alipayResultHandler:resultDic];
        }];
    }
    return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            [self alipayResultHandler:resultDic];
        }];
    }
    return YES;
}

#pragma mark - alvert view button action
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        
        UIViewController *vc = ((UINavigationController *)((UITabBarController*)self.window.rootViewController).selectedViewController).visibleViewController;
        
        if ([vc isKindOfClass:[CADPayViewController class]]) {
            [vc.navigationController popToRootViewControllerAnimated:YES];
        }
        
    }
}

@end
