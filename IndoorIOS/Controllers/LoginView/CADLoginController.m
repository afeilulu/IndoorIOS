//
//  CADLoginViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/24.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADLoginController.h"
#import "Constants.h"
#import "CADParseUserLogin.h"
#import "CADParseTimeStamp.h"
#import "CADUserManager.h"
#import "Utils.h"
#import "CADPreOrderViewController.h"
#import "CADStoryBoardUtilities.h"
#import "CADAlertManager.h"
#import "CADAccountViewController.h"
#import "CADRegisterController.h"
#import "CADResetPasswordController.h"

@interface CADLoginController ()

@end

@implementation CADLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.Password.delegate = self;
    
    self.afm = [AFHTTPSessionManager manager];
    
    self.LoginButton.layer.cornerRadius = 5;
    
    // set back title
    UIBarButtonItem *blankButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:blankButton];
    
    UIImageView *iconPhone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_phone"]];
    iconPhone.frame = CGRectMake(0, 0, 25, 25);
    iconPhone.backgroundColor = nil;
    self.UserName.leftView = iconPhone;
    self.UserName.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *iconKey = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_key"]];
    iconKey.frame = CGRectMake(0, 0, 25, 25);
    iconKey.backgroundColor = nil;
    self.Password.leftView = iconKey;
    self.Password.leftViewMode = UITextFieldViewModeAlways;
    
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


- (IBAction)LoginAction:(id)sender {
    
    if ( [_UserName.text isEqualToString:@"" ] || [_Password.text isEqualToString:@"" ]) {
        
        [CADAlertManager showAlert:self setTitle:@"登录错误" setMessage:@"请输入用户名和密码"];
        
    } else {
        
        // 登录
        [self login];
    }
}

- (IBAction)registerAction:(id)sender {
    CADRegisterController * vc = (CADRegisterController *)[CADStoryBoardUtilities viewControllerForStoryboardName:@"Register" class:[CADRegisterController class]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)resetPasswordAction:(id)sender {
    CADResetPasswordController *vc = (CADResetPasswordController *)[CADStoryBoardUtilities viewControllerForStoryboardName:@"ResetPassword" class:[CADResetPasswordController class]];
    [self.navigationController pushViewController:vc animated:YES];
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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"choose"]){
        
        CADChooseViewController *destination = [segue destinationViewController];
        [destination setSportTypeId:self.sportTypeId];
        [destination setSportSiteId:self.sportSiteId];
        
    }
}
 */

/*
 * 登录
 */
- (void) login {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','account':'%@','password':'%@'}",self.timeStamp,[Utils md5:beforeMd5],_UserName.text,_Password.text]};
            
            [self.afm POST:kLoginUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
//                    NSLog(@"JSON: %@", responseObject);
                    
                    CADUser* user = [[CADUser alloc] init];
                    
                    NSDictionary *userInfo = [responseObject objectForKey:@"userInfo"];
                    user.fee = [userInfo objectForKey:@"fee"];
                    user.idString = [userInfo objectForKey:@"id"];
                    user.mail = [userInfo objectForKey:@"mail"];
                    user.phone = [userInfo objectForKey:@"phone"];
                    user.sex_code = [userInfo objectForKey:@"sex_code"];
                    user.sex_name = [userInfo objectForKey:@"sec_name"];
                    user.imgUrl = [userInfo objectForKey:@"image_url"];
                    user.address = [userInfo objectForKey:@"address"];
                    user.area_code = [userInfo objectForKey:@"area_code"];
                    user.area_name = [userInfo objectForKey:@"area_name"];
                    user.name = [userInfo objectForKey:@"name"];
                    user.score = [[userInfo objectForKey:@"score"] stringValue];
                    user.qq = [userInfo objectForKey:@"qq"];
                    
                    [[CADUserManager sharedInstance] setUser:user];
                    
                    // save at local
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
                    [defaults setObject:data forKey:@"user"];
                    [defaults synchronize];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    // go next view
                    if ([self.nextView isEqualToString:@"PreOrder"]) {
                        CADPreOrderViewController* vc = (CADPreOrderViewController*)[CADStoryBoardUtilities viewControllerForStoryboardName:self.nextView class:self.nextClass];
                        
                        [self.navigationController pushViewController:vc animated:YES];
                        [vc setSportTypeId:self.sportTypeId];
                        [vc setSportSiteId:self.sportSiteId];
                    }
                    
                    if ([self.nextView isEqualToString:@"Account"]) {
                        CADAccountViewController* vc = (CADAccountViewController*)[CADStoryBoardUtilities viewControllerForStoryboardName:self.nextView class:self.nextClass];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    
                    
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"登录错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"登录错误" setMessage:[error localizedDescription]];
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
