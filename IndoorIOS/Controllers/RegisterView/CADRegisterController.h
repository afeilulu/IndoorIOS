//
//  CADRegisterController.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/27.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface CADRegisterController : UIViewController<UITextFieldDelegate>

@property (strong,nonatomic) NSString *timeStamp;
@property (strong,nonatomic) AFHTTPSessionManager *afm;

@property (weak, nonatomic) IBOutlet UITextField *Username;
@property (weak, nonatomic) IBOutlet UITextField *Valicode;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UITextField *PasswordConfirm;

@property (weak, nonatomic) IBOutlet UIButton *GetCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *RegisterButton;

- (IBAction)GetValiCodeAction:(id)sender;
- (IBAction)RegisterAction:(id)sender;

@property (nonatomic,strong) NSString *inputValicode;

@end
