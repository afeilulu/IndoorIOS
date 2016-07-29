//
//  CADResetPasswordController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/27.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADResetPasswordController.h"
#import "Constants.h"
#import "Utils.h"
#import "CADAlertManager.h"

@interface CADResetPasswordController ()

@end

@implementation CADResetPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.afm = [AFHTTPSessionManager manager];
    
    self.getValicodeButton.layer.cornerRadius = 5;
    self.okButton.layer.cornerRadius = 5;
    
    UIImageView *iconPhone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_phone"]];
    iconPhone.frame = CGRectMake(0, 0, 25, 25);
    iconPhone.backgroundColor = nil;
    self.Username.leftView = iconPhone;
    self.Username.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *iconSms = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_sms"]];
    iconSms.frame = CGRectMake(0, 0, 25, 25);
    iconSms.backgroundColor = nil;
    self.Valicode.leftView = iconSms;
    self.Valicode.leftViewMode = UITextFieldViewModeAlways;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 点击背景隐藏键盘
- (IBAction)viewTouchDown:(id)sender {
    // 发送resignFirstResponder.
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getValicodeAction:(id)sender {
    if ([_Username.text length] != 11){
        UIAlertView * alertView = [[UIAlertView alloc] init];
        alertView.title = @"手机号长度不正确！";
        alertView.delegate = nil;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
        
        _inputValicode = nil;
    } else {
        [self getValiCodeOfResetPassword];
    }
}

- (IBAction)okAction:(id)sender {
    if ([_Username.text length] != 11){
        [CADAlertManager showAlert:self setTitle:@"手机号长度不正确！" setMessage:nil];
        
        return;
    }
    
    if (_inputValicode == nil || ![_Valicode.text isEqualToString:_inputValicode]) {
        [CADAlertManager showAlert:self setTitle:@"验证码不正确！" setMessage:nil];
        
        return;
    }
    
    [self resetPassword];
}

/*
 * 获取手机验证码
 */
- (void) getValiCodeOfResetPassword {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','phone':'%@'}",self.timeStamp,[Utils md5:beforeMd5],self.Username.text]};
            
            [self.afm POST:kValiCodeOfResetPasswordJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
                    //                    NSLog(@"JSON: %@", responseObject);
                    _inputValicode = [responseObject objectForKey:@"validateCode"];
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取验证码错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取验证码错误" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"msg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/*
 * 重置密码
 */
- (void) resetPassword {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','phone':'%@','validateCode':'%@'}",self.timeStamp,[Utils md5:beforeMd5],self.Username.text,self.Valicode.text]};
            
            [self.afm POST:kResetPasswordJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
                    //                    NSLog(@"JSON: %@", responseObject);
//                    [CADAlertManager showAlert:self setTitle:@"重置密码成功，请在接收到短信后重新登录。" setMessage:nil];
//                    [self.navigationController popViewControllerAnimated:true];
                    
                    
                    UIAlertController *alertController = [UIAlertController
                                                 alertControllerWithTitle:@"重置密码成功，请在接收到短信后重新登录。"
                                                 message:nil
                                                 preferredStyle:UIAlertControllerStyleAlert
                                                 ];
                    
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"确定", @"OK action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   [self.navigationController popViewControllerAnimated:true];
                                               }];
                    [alertController addAction:okAction];

                    [self presentViewController:alertController animated:YES completion:nil];
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"重置密码错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"重置密码错误" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"msg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
