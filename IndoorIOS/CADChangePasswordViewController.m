//
//  CADChangePasswordViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/7/10.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADChangePasswordViewController.h"
#import "Constants.h"
#import "CADUserManager.h"

@interface CADChangePasswordViewController ()

@end

@implementation CADChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    // 修改密码调用
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:KModifyPasswordJsonUrl]];
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'phone':'%@','oldPassword':'%@','newPassword':'%@'}",_phone.text,_oldPassword.text,_freshPassword.text];
    [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.jsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
    NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - NSURLConnectionDelegate

// -------------------------------------------------------------------------------
//	handleError:error
//  handle connection error
//  Reports any error with an alert which was received from connection or loading failures.
// -------------------------------------------------------------------------------
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"不能连接到服务器"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
    [alertView show];
}

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
//  Called when enough data has been read to construct an NSURLResponse object.
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.jsonData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
//  Called with a single immutable NSData object to the delegate, representing the next
//  portion of the data loaded from the connection.
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.jsonData appendData:data];  // append incoming data
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
//  Will be called at most once, if an error occurs during a resource load.
//  No other callbacks will be made after.
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (error.code == kCFURLErrorNotConnectedToInternet)
    {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"No Connection Error"};
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    }
    else
    {
        // otherwise handle the error generically
        [self handleError:error];
    }
    
    connection = nil;   // release our connection
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
//  Called when all connection processing has completed successfully, before the delegate
//  is released by the connection.
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSError* error;
    
    if ([[connection.currentRequest.URL absoluteString] isEqualToString:KModifyPasswordJsonUrl]) {
        NSDictionary *result = [NSJSONSerialization
                                JSONObjectWithData:self.jsonData
                                options:kNilOptions
                                error:&error];
        
        NSString *errorMsg = [result objectForKey:@"msg"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorMsg
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        if ([[result objectForKey:@"success"] boolValue] == true){
            [CADUserManager.sharedInstance clear];
            [self.navigationController popViewControllerAnimated:true];
        }
        
    }
    
    connection = nil;   // release our connection
    self.jsonData = nil;
    self.jsonConnection = nil;
}

@end
