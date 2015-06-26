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
@property (weak, nonatomic) IBOutlet UITextField *Valicode;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UITextField *PasswordConfirm;
@property (weak, nonatomic) IBOutlet UITextField *Email;

@property (weak, nonatomic) IBOutlet UIButton *GetCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *RegisterButton;


- (IBAction)GetValiCodeAction:(id)sender;
- (IBAction)RegisterAction:(id)sender;

@property (nonatomic,strong) NSString *inputValicode;

@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic,strong) NSURLConnection *jsonConnection;

@end
