//
//  CADRegisterController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/27.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADRegisterController.h"
#import "Constants.h"
#import "Utils.h"
#import "CADAlertManager.h"

@interface CADRegisterController ()

@end

@implementation CADRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _inputValicode = [[NSString alloc] init];
    
    self.GetCodeButton.layer.cornerRadius = 5;
    self.RegisterButton.layer.cornerRadius = 5;
    
    self.afm = [AFHTTPSessionManager manager];
    
    UIImageView *iconPhone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_phone"]];
    iconPhone.frame = CGRectMake(0, 0, 25, 25);
    iconPhone.backgroundColor = nil;
    self.Username.leftView = iconPhone;
    self.Username.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *iconKey = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_key"]];
    iconKey.frame = CGRectMake(0, 0, 25, 25);
    iconKey.backgroundColor = nil;
    self.Password.leftView = iconKey;
    self.Password.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *iconKey2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_key"]];
    iconKey2.frame = CGRectMake(0, 0, 25, 25);
    iconKey2.backgroundColor = nil;
    self.PasswordConfirm.leftView = iconKey2;
    self.PasswordConfirm.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *iconSms = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_sms"]];
    iconSms.frame = CGRectMake(0, 0, 25, 25);
    iconSms.backgroundColor = nil;
    self.Valicode.leftView = iconSms;
    self.Valicode.leftViewMode = UITextFieldViewModeAlways;
    
}

// 点击背景隐藏键盘
- (IBAction)viewTouchDown:(id)sender {
    // 发送resignFirstResponder.
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)GetValiCodeAction:(id)sender {
    if ([_Username.text length] != 11){
        UIAlertView * alertView = [[UIAlertView alloc] init];
        alertView.title = @"手机号长度不正确！";
        alertView.delegate = nil;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
        
        _inputValicode = nil;
    } else {
        [self getValiCode];
    }
}

- (IBAction)RegisterAction:(id)sender {
    
    if ([_Username.text length] != 11){
        UIAlertView * alertView = [[UIAlertView alloc] init];
        alertView.title = @"手机号长度不正确！";
        alertView.delegate = nil;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
        
        return;
    }
    
    if (_inputValicode == nil || ![_Valicode.text isEqualToString:_inputValicode]) {
        UIAlertView * alertView = [[UIAlertView alloc] init];
        alertView.title = @"验证码不正确！";
        alertView.delegate = nil;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
        
        return;
    }
    
    if ([_Password.text length] < 6) {
        UIAlertView * alertView = [[UIAlertView alloc] init];
        alertView.title = @"密码长度太短";
        alertView.delegate = nil;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
        
        return;
    }
    
    if ([_Password.text length] > 12) {
        UIAlertView * alertView = [[UIAlertView alloc] init];
        alertView.title = @"密码长度太长";
        alertView.delegate = nil;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
        
        return;
    }
    
    if (![_Password.text isEqualToString:_PasswordConfirm.text]) {
        UIAlertView * alertView = [[UIAlertView alloc] init];
        alertView.title = @"确认密码不匹配";
        alertView.delegate = nil;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
        
        return;
    }
    /*
     if (_Email.text.length == 0) {
     UIAlertView * alertView = [[UIAlertView alloc] init];
     alertView.title = @"请输入电子邮箱";
     alertView.delegate = nil;
     [alertView addButtonWithTitle:@"确定"];
     [alertView show];
     
     return;
     } else if([_Email.text rangeOfString:@"@"].location == NSNotFound
     || [_Email.text rangeOfString:@"."].location == NSNotFound
     || [_Email.text rangeOfString:@"/"].location != NSNotFound
     || [_Email.text rangeOfString:@":"].location != NSNotFound
     || [_Email.text rangeOfString:@";"].location != NSNotFound
     || [_Email.text rangeOfString:@"("].location != NSNotFound
     || [_Email.text rangeOfString:@")"].location != NSNotFound
     || [_Email.text rangeOfString:@"&"].location != NSNotFound
     || [_Email.text rangeOfString:@"\""].location != NSNotFound
     || [_Email.text rangeOfString:@","].location != NSNotFound
     || [_Email.text rangeOfString:@"?"].location != NSNotFound
     || [_Email.text rangeOfString:@"!"].location != NSNotFound
     || [_Email.text rangeOfString:@"\\"].location != NSNotFound
     || [_Email.text rangeOfString:@"\'"].location != NSNotFound){
     UIAlertView * alertView = [[UIAlertView alloc] init];
     alertView.title = @"电子邮箱格式错误";
     alertView.delegate = nil;
     [alertView addButtonWithTitle:@"确定"];
     [alertView show];
     
     return;
     }*/
    
    // 注册
    [self register];
}

#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"TextField Should Return Method Called!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    [textField resignFirstResponder];
    return YES;
}

/*
 * 获取手机验证码
 */
- (void) getValiCode {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','phone':'%@'}",self.timeStamp,[Utils md5:beforeMd5],self.Username.text]};
            
            [self.afm POST:kValiCodeJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
                    //                    NSLog(@"JSON: %@", responseObject);
                    _inputValicode = [responseObject objectForKey:@"validateCode"];
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"errmsg"];
                    [CADAlertManager showAlert:self setTitle:@"获取验证码错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取验证码错误" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"errmsg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/*
 * 注册
 */
- (void) register {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','phone':'%@','validateCode':'%@','password':'%@'}",self.timeStamp,[Utils md5:beforeMd5],self.Username.text,self.Valicode.text,self.Password.text]};
            
            [self.afm POST:kRegisterUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
                    //                    NSLog(@"JSON: %@", responseObject);
                    // 注册成功
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"errmsg"];
                    [CADAlertManager showAlert:self setTitle:@"注册错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"注册错误" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"errmsg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
