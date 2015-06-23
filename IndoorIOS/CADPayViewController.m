//
//  CADPayViewController.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/4/15.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CADPayViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import "Constants.h"
#import <AlipaySDK/AlipaySDK.h>
#import "CADUserManager.h"
#import "CADUser.h"
#import "Utils.h"
#import "StadiumManager.h"
#import "StadiumRecord.h"
#import "ParseStadiumDetail.h"

@interface CADPayViewController ()

@end

@implementation CADPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.RemainPayButton.layer.cornerRadius = 5;
    self.AlipayButton.layer.cornerRadius = 5;
    
    self.OrderSeqLabel.text = [[NSString alloc] initWithFormat:@"订单号:%@",self.orderInfo.orderSeq];
    self.totalLabel.text = [[NSString alloc] initWithFormat:@"应付金额:%@元",self.orderInfo.totalMoney];
    
    // 场馆名称 和 预订时间
    NSArray *tmpStrings = [[self.orderInfo.orderTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@" "];
    self.dateLabel.text = [tmpStrings objectAtIndex:tmpStrings.count - 1];
    self.SiteNameLabel.text = [tmpStrings objectAtIndex:0];
    
    // 总额
    self.totalLabel.text = [[NSString alloc] initWithFormat:@"应付金额:%@元",self.orderInfo.totalMoney];
    
    // 地址
    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
    StadiumRecord *stadium = [stadiumManager.stadiumList objectForKey:self.orderInfo.sportId];
    if (stadium.gotDetail) {
        self.addressLabel.text = stadium.address;
    } else {
        // need get stadium detail
        // 从服务器获取场馆详情
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kStadiumDetailJsonUrl]];
        [postRequest setHTTPMethod:@"POST"];
        NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'sportSiteId':'%@'}",self.orderInfo.sportId];
        [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
        self.jsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
        NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
        
        // show in the status bar that network activity is starting
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    // 运动图片
    self.sportImageView.image = [stadium.imagesOfSportType objectForKey:self.orderInfo.sportTypeId];
    
    // 详细
    int count = [self.orderInfo.siteTimeList count];
    if (count == 4) {
        self.place4Label.text = [self.orderInfo.siteTimeList objectAtIndex:3];
        self.place3Label.text = [self.orderInfo.siteTimeList objectAtIndex:2];
        self.place2Label.text = [self.orderInfo.siteTimeList objectAtIndex:1];
        self.place1Label.text = [self.orderInfo.siteTimeList objectAtIndex:0];
    }
    if (count == 3) {
        self.place3Label.text = [self.orderInfo.siteTimeList objectAtIndex:2];
        self.place2Label.text = [self.orderInfo.siteTimeList objectAtIndex:1];
        self.place1Label.text = [self.orderInfo.siteTimeList objectAtIndex:0];

        self.orderContainerHeightConstraint.constant =self.orderContainerHeightConstraint.constant - self.place4HeightConstraint.constant;
        self.place4HeightConstraint.constant = 0;
    }
    if (count == 2) {
        self.place2Label.text = [self.orderInfo.siteTimeList objectAtIndex:1];
        self.place1Label.text = [self.orderInfo.siteTimeList objectAtIndex:0];

        self.orderContainerHeightConstraint.constant =self.orderContainerHeightConstraint.constant - 2 * self.place4HeightConstraint.constant;
        self.place3HeightConstraint.constant = 0;
        self.place4HeightConstraint.constant = 0;
    }
    if (count == 1) {
        self.place1Label.text = [self.orderInfo.siteTimeList objectAtIndex:0];
        
        self.orderContainerHeightConstraint.constant =self.orderContainerHeightConstraint.constant - 3 * self.place4HeightConstraint.constant;
        self.place2HeightConstraint.constant = 0;
        self.place3HeightConstraint.constant = 0;
        self.place4HeightConstraint.constant = 0;
    }

    if ([self.orderInfo.orderStatus isEqualToString:@"已支付"] || [self.orderInfo.orderStatus isEqualToString:@"支付中"] ){
//        [self.RemainPayButton setEnabled:false];
//        self.RemainPayButton.backgroundColor = [UIColor lightGrayColor];
//        [self.AlipayButton setEnabled:false];
//        self.AlipayButton.backgroundColor = [UIColor lightGrayColor];
        [self.RemainPayButton removeFromSuperview];
        [self.AlipayButton removeFromSuperview];
        
        [self setTitle:self.orderInfo.orderStatus];
    } else if(self.orderInfo.remainTime == 0){
//        [self.RemainPayButton setEnabled:false];
//        self.RemainPayButton.backgroundColor = [UIColor lightGrayColor];
//        [self.AlipayButton setEnabled:false];
//        self.AlipayButton.backgroundColor = [UIColor lightGrayColor];
        
        [self.RemainPayButton removeFromSuperview];
        [self.AlipayButton removeFromSuperview];
    } else {
        [self.RemainPayButton setEnabled:true];
        self.RemainPayButton.backgroundColor = self.view.tintColor;
        [self.AlipayButton setEnabled:true];
        self.AlipayButton.backgroundColor = self.view.tintColor;
        
        [self setTitle:[[NSString alloc] initWithFormat:@"确认支付(%i分钟内支付有效)",self.orderInfo.remainTime]];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    // update user info
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kGetUserInfoJsonUrl]];
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *timeStamp = [[CADUserManager sharedInstance] getTimeStamp];
    CADUser *user = [[CADUserManager sharedInstance] getUser];
    NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,timeStamp ];
    NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'phone':'%@','randTime':'%@','secret':'%@'}",user.phone,timeStamp,[Utils md5:beforeMd5]];
    
    [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
    self.jsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
    
    NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark -
#pragma mark   ==============产生随机订单号==============

- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

#pragma mark -
#pragma mark   ==============查询账户是否存在==============

- (IBAction)checkAccount:(id)sender {
    BOOL hasAuthorized = [[AlipaySDK defaultService] isLogined];
    NSLog(@"result = %d",hasAuthorized);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询账户"
                                                    message:hasAuthorized?@"有":@"没有"
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    [alert show];
}

- (IBAction)RemainPayAction:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"余额支付"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"请输入余额支付密码", @"Password");
         textField.secureTextEntry = YES;
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"确定", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *password = alertController.textFields.lastObject;
                                   [self RemainPayWithPassword:password.text];
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"取消", @"CANCEL action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)AlipayAction:(id)sender {
    NSLog(@"Alipay clicked");
    
    // 先确认订单
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kPreAliPayUrl]];
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *timeStamp = [[CADUserManager sharedInstance] getTimeStamp];
    NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,timeStamp ];
    NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'orderId':'%@','randTime':'%@','secret':'%@','payParam':{'orderId':'%@'}}",self.orderInfo.orderId,timeStamp,[Utils md5:beforeMd5],self.orderInfo.orderId];
    
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"不能连接服务器"
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
    
    // 重新获取用户信息
    if ([connection.currentRequest.URL isEqual:[NSURL URLWithString:kGetUserInfoJsonUrl]]) {
        self.jsonConnection = nil;   // release our connection
        
        NSError* error;
        NSDictionary *result = [NSJSONSerialization
                                JSONObjectWithData:self.jsonData
                                options:kNilOptions
                                error:&error];
        
        CADUser *user = [[CADUserManager sharedInstance] getUser];
        
        if ([[result objectForKey:@"success"] boolValue] == true){
            NSDictionary *userInfo = [result objectForKey:@"userInfo"];
            
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
            user.score = [userInfo objectForKey:@"score"];
            user.qq = [userInfo objectForKey:@"qq"];
            
            [self.RemainPayButton setTitle:[[NSString alloc] initWithFormat:@"余额(%@)",user.fee] forState:UIControlStateNormal];
            if (self.RemainPayButton.isEnabled){
                int fee = [user.fee intValue];
                if (fee == 0 || fee < [self.orderInfo.totalMoney intValue]) {
                    [self.RemainPayButton setEnabled:false];
                    self.RemainPayButton.backgroundColor = [UIColor lightGrayColor];
                } else {
                    [self.RemainPayButton setEnabled:true];
                    self.RemainPayButton.backgroundColor = self.view.tintColor;
                }
            }
        } else {
            NSString *domain = @"com.chinaairdome.indoorios";
            NSString *desc = [result objectForKey:@"msg"];
            
            // if we can identify the error, we can present a more precise message to the user.
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:desc};
            NSError *error = [NSError errorWithDomain:domain
                                                 code:-105
                                             userInfo:userInfo];
            [self handleError:error];
            
        }
        
    }
    
    // 调用支付宝支付前的订单验证
    if ([connection.currentRequest.URL isEqual:[NSURL URLWithString:kPreAliPayUrl]]) {
        self.jsonConnection = nil;   // release our connection
        
        NSError* error;
        NSDictionary *result = [NSJSONSerialization
                                JSONObjectWithData:self.jsonData
                                options:kNilOptions
                                error:&error];
//        NSLog(@"%@ - %@", NSStringFromClass([self class]), result);
        
        if ([[result objectForKey:@"success"] boolValue] == true){
            // real alipay invocation
            [self Alipay:[result objectForKey:@"payId"] inTime:[result objectForKey:@"remainTime"]];
            
        } else {
            NSString *desc = [result objectForKey:@"msg"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取订单状态异常"
                                                            message:desc
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
    // 余额支付结果
    if ([connection.currentRequest.URL isEqual:[NSURL URLWithString:kFeePayUrl]]) {
        self.jsonConnection = nil;   // release our connection
        
        NSError* error;
        NSDictionary *result = [NSJSONSerialization
                                JSONObjectWithData:self.jsonData
                                options:kNilOptions
                                error:&error];
//        NSLog(@"%@ - %@", NSStringFromClass([self class]), result);
        
        if ([[result objectForKey:@"success"] boolValue] == true){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付完成"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            NSString *desc = [result objectForKey:@"msg"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取订单异常"
                                                            message:desc
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
    // 获取场馆详情
    if ([connection.currentRequest.URL isEqual:[NSURL URLWithString:kStadiumDetailJsonUrl]]) {
        self.jsonConnection = nil;   // release our connection
        
        // create the queue to run our ParseOperation
        self.queue = [[NSOperationQueue alloc] init];
        
        ParseStadiumDetail *parser = [[ParseStadiumDetail alloc] initWithData:self.jsonData];
        
        parser.errorHandler = ^(NSError *parseError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleError:parseError];
            });
        };
        
        parser.completionBlock = ^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 重新设置地址
                StadiumManager *stadiumManager = [StadiumManager sharedInstance];
                StadiumRecord *stadium = [stadiumManager.stadiumList objectForKey:self.orderInfo.sportId];
                if (stadium.gotDetail) {
                    self.addressLabel.text = stadium.address;
                }
            });
            // we are finished with the queue and our ParseOperation
            self.queue = nil;
        };
        
        [self.queue addOperation:parser]; // this will start the "ParseOperation"
        
    }
    
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.jsonData = nil;
}

#pragma mark - remain pay
-(void) RemainPayWithPassword:(NSString *) password
{
    
     CADUser *user = [[CADUserManager sharedInstance] getUser];
     
     NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kFeePayUrl]];
     [postRequest setHTTPMethod:@"POST"];
     
     NSString *timeStamp = [[CADUserManager sharedInstance] getTimeStamp];
     NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,timeStamp ];
     NSString *params = [[NSString alloc] initWithFormat:@"jsonString={'orderId':'%@','phone':'%@','payPassword':'%@','randTime':'%@','secret':'%@'}",self.orderInfo.orderId, user.phone,password,timeStamp,[Utils md5:beforeMd5]];
     
     [postRequest setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
     self.jsonConnection = [[NSURLConnection alloc]initWithRequest:postRequest delegate:self];
     
     NSAssert(self.jsonConnection != nil, @"Failure to create URL connection.");
     
     // show in the status bar that network activity is starting
     [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
     
}


#pragma mark - alipay
-(void) Alipay:(NSString *)payId inTime:(NSString *)remainTime
{
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088811279837648";
    NSString *seller = @"info@chinaairdome.com";
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAO7tQfnnNNKh+1rn2CqsxFW098XqwW17A9UhILCIGR7zWd82oBGOI027qm6pBnNNgf+GQ6yKGgIqIXNNtffpX5hcQK542M28gxY4LvqJi0O/hJR7UTwSNcIplViQrwQM9MXKrhmubTCy+F7B04ZCUAM8GJ6mvsZmHxnTHl4yTiohAgMBAAECgYBPk+5ZkcxiK1lQmc/BxvFNqoyr+tiZ4lMQdYwxv+K+EEdqtQLzVegkR9EoMlvXo4Uc2ldH7GdlOSsTAFsPS0dvDtnZxurfLy7Uggpjo+ICsgQqKro/lfvCfhCCHoTsvWsf0Ae0q91k13RqARkZyI7bvrkPd16ouwp9HysmJG5EwQJBAP6jGPEVaxeSkalclfHrqS7jM5KH7BMSL39blrcG59q9EhlfIinsdB21XiBlaKXkbwCqAAWn3raBe7oYWjMJvDUCQQDwNKJUDu+vbJqwtJV+vZjsN2bVUBxv+HR6nxXhpJm0rpwnEFSwt4WXi7MFIQ1QIihoyWqBNg22PU4LyoP6hju9AkEA4WNKG3Li5O2WQvuxuX3ntZnjt0raWhMZubg/EmhpZ0M9tvlvCv7B1N4Jn9FDLLuiyUqwVFE/n/nCo3kUteJjFQJAdMuC6pBgptGN3cHQttGFm8XMcIgFa8RJDp5vy0l3m00TjEL6ivqRMICyyRmrGX2iXGEjMjSQMj5Yxo7v4U6HmQJAMl0l0gptkDEy4c7c7Qvc+4Rf7UIxoGQuN/L5ru7wpxqNZswTQ8ZRzxuHf+Kse69clUaQwpxzY/onIGn+oSRgjg==";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 || [seller length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    //    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.tradeNO = payId;
    order.productName =  @"铁人场地预订"; //商品标题
    order.productDescription = self.orderInfo.orderTitle; //商品描述;
//        order.amount = [NSString stringWithFormat:@"%.2f",0.01]; //商品价格
    order.amount = self.orderInfo.totalMoney;
    order.notifyURL =  kAlipayCallbackUrl; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    //    order.itBPay = @"30m";
//    order.itBPay =[[NSString alloc] initWithFormat:@"%im",self.orderInfo.remainTime];
    order.itBPay = remainTime;
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"IndoorIOS";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
//    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"同步返回 reslut = %@",resultDic);
            int resultCode = [[resultDic objectForKey:@"resultStatus"] intValue];
            NSString *title = [[NSString alloc] init];
            bool success = false;
            switch (resultCode) {
                case 9000:
                    title = @"订单支付成功";
                    success = true;
                    break;
                case 8000:
                    title = @"正在处理中";
                    break;
                case 4000:
                    title = @"订单支付失败";
                    break;
                case 6001:
                    title = @"用户中途取消";
                    break;
                case 6002:
                    title = @"网络连接出错";
                    break;
            }
            NSString *memo = [resultDic objectForKey:@"memo"];
            if (success){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                    message:memo
                                                                   delegate:self
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                    message:memo
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
}

#pragma mark - alvert view button action
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        // dismiss a View controller from a Push Segue
        [self.navigationController popToRootViewControllerAnimated:YES];

    }
}
@end