//
//  AppDelegate.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/11/20.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "CADPayViewController.h"


// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>

@interface AppDelegate ()

// the main data model for our UITableView
@property (nonatomic, strong) NSArray *stadiums;

@end

BMKMapManager* _mapManager;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"lcYxq08FGbAZ8OqlYLsn5qlT" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    [self.window makeKeyAndVisible];
    
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
