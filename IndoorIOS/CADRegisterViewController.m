//
//  CADRegisterViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/24.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADRegisterViewController.h"
#import "Constants.h"
#import "CADUserManager.h"
#import "Utils.h"

@interface CADRegisterViewController ()

@end

@implementation CADRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _inputValicode = [[NSString alloc] init];
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
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kValiCodeJsonUrl]];
        [postRequest setHTTPMethod:@"POST"];
        
        NSString *timeStamp = [[CADUserManager sharedInstance] getTimeStamp];
        NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,timeStamp ];
        
        NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'phone':'%@','randTime':'%@','secret':'%@'}",_Username.text,timeStamp,[Utils md5:beforeMd5]];
        [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
        
        self.jsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
        NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
        
        // show in the status bar that network activity is starting
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
    
    // 注册
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kRegisterUrl]];
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'phone':'%@','validateCode':'%@','password':'%@'}",_Username.text,_Valicode.text,_Password.text];
    [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.jsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
    NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"TextField Should Return Method Called!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    [textField resignFirstResponder];
    return YES;
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot connect to Server"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
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
    
    if ([[connection.currentRequest.URL absoluteString] isEqualToString:kValiCodeJsonUrl]) {
         NSDictionary *result = [NSJSONSerialization
                                 JSONObjectWithData:self.jsonData
                                 options:kNilOptions
                                 error:&error];
        
        if ([[result objectForKey:@"success"] boolValue] == true){
            _inputValicode = [result objectForKey:@"validateCode"];
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
    
    if ([[connection.currentRequest.URL absoluteString] isEqualToString:kRegisterUrl]) {
        NSDictionary *result = [NSJSONSerialization
                                           JSONObjectWithData:self.jsonData
                                           options:kNilOptions
                                           error:&error];
        
        if ([[result objectForKey:@"success"] boolValue] == true){
            
            // 注册成功
            // dismiss a View controller from a Push Segue
            [self.navigationController popViewControllerAnimated:YES];
            
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
    
    connection = nil;   // release our connection
}

@end
