//
//  CADChangePasswordController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/28.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADChangePasswordController.h"
#import "Constants.h"
#import "Utils.h"
#import "CADAlertManager.h"
#import "CADUserManager.h"

@interface CADChangePasswordController ()

@end

@implementation CADChangePasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.afm = [AFHTTPSessionManager manager];
    
    self.okButton.layer.cornerRadius = 5;
    
    UIImageView *iconPhone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_phone"]];
    iconPhone.frame = CGRectMake(0, 0, 25, 25);
    iconPhone.backgroundColor = nil;
    self.phone.leftView = iconPhone;
    self.phone.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *iconKey = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_key"]];
    iconKey.frame = CGRectMake(0, 0, 25, 25);
    iconKey.backgroundColor = nil;
    self.oldPassword.leftView = iconKey;
    self.oldPassword.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *iconKey1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_key"]];
    iconKey1.frame = CGRectMake(0, 0, 25, 25);
    iconKey1.backgroundColor = nil;
    self.freshPassword.leftView = iconKey1;
    self.freshPassword.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *iconKey2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_key"]];
    iconKey2.frame = CGRectMake(0, 0, 25, 25);
    iconKey2.backgroundColor = nil;
    self.confirmPassword.leftView = iconKey2;
    self.confirmPassword.leftViewMode = UITextFieldViewModeAlways;
}

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

- (IBAction)okAction:(id)sender {
    if ([_phone.text length] != 11){
        UIAlertView * alertView = [[UIAlertView alloc] init];
        alertView.title = @"手机号长度不正确！";
        alertView.delegate = nil;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
        
        return;
    }
    
    if ([_freshPassword.text length] < 6) {
        UIAlertView * alertView = [[UIAlertView alloc] init];
        alertView.title = @"密码长度太短";
        alertView.delegate = nil;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
        
        return;
    }
    
    if ([_freshPassword.text length] > 12) {
        UIAlertView * alertView = [[UIAlertView alloc] init];
        alertView.title = @"密码长度太长";
        alertView.delegate = nil;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
        
        return;
    }
    
    if (![_freshPassword.text isEqualToString:_confirmPassword.text]) {
        UIAlertView * alertView = [[UIAlertView alloc] init];
        alertView.title = @"确认密码不匹配";
        alertView.delegate = nil;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
        
        return;
    }

    [self changePassword];
}

/*
 * 重置密码
 */
- (void) changePassword {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','phone':'%@','oldPassword':'%@','newPassword':'%@'}",self.timeStamp,[Utils md5:beforeMd5],self.phone.text,self.oldPassword.text,self.freshPassword.text]};
            
            [self.afm POST:KModifyPasswordJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
                    //                    NSLog(@"JSON: %@", responseObject);
                    
                    
                    UIAlertController *alertController = [UIAlertController
                                                          alertControllerWithTitle:@"密码修改成功，请重新登录。"
                                                          message:nil
                                                          preferredStyle:UIAlertControllerStyleAlert
                                                          ];
                    
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"确定", @"OK action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                                                   [defaults removeObjectForKey:@"user"];
                                                   [[CADUserManager sharedInstance] setUser:nil];
                                                   
                                                   [self.navigationController popViewControllerAnimated:true];

                                               }];
                    [alertController addAction:okAction];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"密码修改错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"密码修改错误" setMessage:[error localizedDescription]];
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
