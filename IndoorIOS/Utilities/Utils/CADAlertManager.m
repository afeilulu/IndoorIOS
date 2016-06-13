//
//  CADAlertManager.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/10.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADAlertManager.h"

@implementation CADAlertManager


+ (void)showAlert:(UIViewController*)instance setTitle:(NSString*)title setMessage:(NSString*)message{
    
    if (instance.presentedViewController != nil) {
        return;
    }
        
    UIAlertController *alert = [UIAlertController
             alertControllerWithTitle:@""
             message:@""
             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    [alert addAction:okAction];
    [alert setTitle:title];
    [alert setMessage:message];

    [instance presentViewController:alert animated:YES completion:nil];
}

@end
