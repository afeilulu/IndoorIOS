//
//  CADLoginViewController.h
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/24.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CADLoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *UserName;
@property (weak, nonatomic) IBOutlet UITextField *Password;

- (IBAction)LoginAction:(id)sender;

- (IBAction)GoRegisterAction:(id)sender;

@end
