//
//  CADAlertManager.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/10.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CADAlertManager : NSObject

@property (nonatomic) UIAlertController *alert;
@property (nonatomic) UIAlertAction *okAction;

+ (void)showAlert:(UIViewController*)instance setTitle:(NSString*)title setMessage:(NSString*)message;

@end
