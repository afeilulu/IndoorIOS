//
//  CADRegisterViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/24.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CADRegisterViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *Username;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UITextField *ConfirmPassword;
- (IBAction)RegisterAction:(id)sender;
@end
