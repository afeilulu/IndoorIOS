//
//  CADResetPasswordViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/7/9.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADResetPasswordViewController.h"
#import "Constants.h"

@interface CADResetPasswordViewController ()

@end

@implementation CADResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kValiCodeOfResetPasswordJsonUrl]];
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'phone':'%@'}",self.Username.text];
    
    [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
    self.jsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
    NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (IBAction)submitReset:(id)sender {
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kResetPasswordJsonUrl]];
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'phone':'%@','validateCode':'%@'}",self.Username.text,self.Valicode.text];
    
    [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
    self.jsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
    NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// -------------------------------------------------------------------------------
//	handleError:error
//  Reports any error with an alert which was received from connection or loading failures.
// -------------------------------------------------------------------------------
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"服务器连接错误"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
    [alertView show];
}

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how
// the connection object,  which is working in the background, can asynchronously communicate back to
// its delegate on the thread from which it was started - in this case, the main thread.
//
#pragma mark - NSURLConnectionDelegate

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
    
    self.jsonConnection = nil;   // release our connection
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
//  Called when all connection processing has completed successfully, before the delegate
//  is released by the connection.
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSError *error;
    // 获取验证码
    if ([connection.currentRequest.URL isEqual:[NSURL URLWithString:kValiCodeOfResetPasswordJsonUrl]]) {
        NSDictionary *result = [NSJSONSerialization
                                JSONObjectWithData:self.jsonData
                                options:kNilOptions
                                error:&error];
        
        if ([[result objectForKey:@"success"] boolValue] == true){
            self.inputValicode = [result objectForKey:@"validateCode"];
        } else {
            NSString *errorMsg = [result objectForKey:@"msg"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorMsg
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
    } else if ([connection.currentRequest.URL isEqual:[NSURL URLWithString:kResetPasswordJsonUrl]]){
        // 重置密码结果
        NSDictionary *result = [NSJSONSerialization
                                JSONObjectWithData:self.jsonData
                                options:kNilOptions
                                error:&error];
        
        if ([[result objectForKey:@"success"] boolValue] == true){
//            NSString *errorMsg = [result objectForKey:@"msg"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"重置密码成功，请在接收到短信后重新登录。"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            [self.navigationController popViewControllerAnimated:true];
        } else {
            NSString *errorMsg = [result objectForKey:@"msg"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorMsg
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
    
    self.jsonConnection = nil;   // release our connection
    
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.jsonData = nil;
}

@end
