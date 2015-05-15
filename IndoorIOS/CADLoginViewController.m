//
//  CADLoginViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/24.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADLoginViewController.h"
#import "Constants.h"
#import "CADParseUserLogin.h"
#import "CADParseTimeStamp.h"
#import "CADUserManager.h"
#import "Utils.h"

@interface CADLoginViewController ()

@end

@implementation CADLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.Password.delegate = self;
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:kTimeStampUrl]];
    _timeStampConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(self.timeStampConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    self.LoginButton.layer.cornerRadius = 5;
    
    // TODO: to delete
    [_UserName setText:@"13359290886"];
    [_Password setText:@"aaaaaa"];
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


- (IBAction)LoginAction:(id)sender {
    
    if ( [_UserName.text isEqualToString:@"" ] || [_Password.text isEqualToString:@"" ]) {
                
        NSString *domain = @"com.chinaairdome.indoorios";;
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"请输入用户名和密码" };
        NSError *error = [NSError errorWithDomain:domain code:-101 userInfo:userInfo];
        [self handleError:error];
        
    } else {
        
        // 登录
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kLoginUrl]];
        [postRequest setHTTPMethod:@"POST"];
        
//        NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'account':'18092558744','password':'111111','randTime':'43243243543','secret':'M89FFNNKMNJ894893NNNNN'}"];
        NSString *timeStamp = [[CADUserManager sharedInstance] getTimeStamp];
        NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,timeStamp ];
        NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'account':'%@','password':'%@','randTime':'%@','secret':'%@'}",_UserName.text,_Password.text,timeStamp,[Utils md5:beforeMd5]];
        
        [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
        self.jsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
        
        // Test the validity of the connection object. The most likely reason for the connection object
        // to be nil is a malformed URL, which is a programmatic error easily detected during development
        // If the URL is more dynamic, then you should implement a more flexible validation technique, and
        // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
        //
        NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
        
        // show in the status bar that network activity is starting
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"TextField Should Return Method Called!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    [textField resignFirstResponder];
    
    return YES;
    
}


// -------------------------------------------------------------------------------
//	handleError:error
//  Reports any error with an alert which was received from connection or loading failures.
// -------------------------------------------------------------------------------
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录错误"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
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
    
    self.timeStampConnection = nil;   // release our connection
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
//  Called when all connection processing has completed successfully, before the delegate
//  is released by the connection.
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];
    
    // 获取时间戳
    if ([connection.currentRequest.URL isEqual:[NSURL URLWithString:kTimeStampUrl]]) {
        self.timeStampConnection = nil;   // release our connection
        
        // create an ParseOperation (NSOperation subclass) to parse the RSS feed data
        // so that the UI is not blocked
        CADParseTimeStamp *parser = [[CADParseTimeStamp alloc] initWithData:self.jsonData];
        
        parser.errorHandler = ^(NSError *parseError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleError:parseError];
            });
        };
        
        // Referencing parser from within its completionBlock would create a retain cycle.
        __weak CADParseTimeStamp *weakParser = parser;
        
        parser.completionBlock = ^(void) {
            if (weakParser.timeStamp) {
                // The completion block may execute on any thread.  Because operations
                // involving the UI are about to be performed, make sure they execute
                // on the main thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@ - %@", NSStringFromClass([self class]), @"时间戳已更新");
                });
            }
            
            // we are finished with the queue and our ParseOperation
            self.queue = nil;
        };
        
        [self.queue addOperation:parser]; // this will start the "ParseOperation"
        
    } else if ([connection.currentRequest.URL isEqual:[NSURL URLWithString:kLoginUrl]]){
        // 登录结果
        
        self.jsonConnection = nil;   // release our connection
        
        // create an ParseOperation (NSOperation subclass) to parse the RSS feed data
        // so that the UI is not blocked
        CADParseUserLogin *parser = [[CADParseUserLogin alloc] initWithData:self.jsonData];
        
        parser.errorHandler = ^(NSError *parseError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleError:parseError];
            });
        };
        
        // Referencing parser from within its completionBlock would create a retain cycle.
        __weak CADParseUserLogin *weakParser = parser;
        
        parser.completionBlock = ^(void) {
            if (weakParser.user && weakParser.user.phone) {
                // The completion block may execute on any thread.  Because operations
                // involving the UI are about to be performed, make sure they execute
                // on the main thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    // dismiss a View controller from a Push Segue
                    [self.navigationController popViewControllerAnimated:YES];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // nothing to do here
                    NSLog(@"%@ - %@", NSStringFromClass([self class]), @"error happened");
                });
            }
            
            // we are finished with the queue and our ParseOperation
            self.queue = nil;
        };
        
        [self.queue addOperation:parser]; // this will start the "ParseOperation"
    }
    
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.jsonData = nil;
}

@end
