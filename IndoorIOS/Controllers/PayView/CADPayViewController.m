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
#import "Constants.h"
#import <AlipaySDK/AlipaySDK.h>
#import "CADUserManager.h"
#import "CADUser.h"
#import "Utils.h"
#import "StadiumManager.h"
#import "StadiumRecord.h"
#import "ParseStadiumDetail.h"
#import "NSString+AlipaySigner.h"
#import "CADAlertManager.h"

@interface CADPayViewController ()

@end

@implementation CADPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.RemainPayButton.layer.cornerRadius = 5;
    self.AlipayButton.layer.cornerRadius = 5;
    
    // disable RemainPayButton firstly until we know the remains
    [self.RemainPayButton setEnabled:false];
    self.RemainPayButton.backgroundColor = [UIColor lightGrayColor];
    
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
        [self getSiteDetail];
    }
    
    // 运动图片
    self.sportImageView.image = [stadium.imagesOfSportType objectForKey:self.orderInfo.sportTypeId];
    
    // 详细
    NSInteger count = [self.orderInfo.siteTimeList count];
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
//        [self.RemainPayButton setEnabled:true];
//        self.RemainPayButton.backgroundColor = self.view.tintColor;
        [self.AlipayButton setEnabled:true];
        self.AlipayButton.backgroundColor = self.view.tintColor;
        
        [self setTitle:[[NSString alloc] initWithFormat:@"确认支付(%i分钟内支付有效)",self.orderInfo.remainTime]];
    }
    
    self.afm = [AFHTTPSessionManager manager];
    
    // auto-hiding keyboard
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)viewWillAppear:(BOOL)animated{
    // update user info
    [self getUserInfo];
    
    // 获取积分规则
    [self getRule];
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
    [self preAliPay];
}

#pragma mark - remain pay
-(void) RemainPayWithPassword:(NSString *) password
{

    CADUser *user = [[CADUserManager sharedInstance] getUser];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','phone':'%@','orderId':'%@','payPassword':'%@'}",self.timeStamp,[Utils md5:beforeMd5],user.phone,self.orderInfo.orderId,password]};
            
            [self.afm POST:kFeePayUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"余额支付异常" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
                    [CADAlertManager showAlert:self setTitle:@"支付成功" setMessage:@""];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"余额支付异常" setMessage:[error localizedDescription]];
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
    NSString *partner = @"2088421269581781";
    NSString *seller = @"yangf@paopaoty.com";
    NSString *privateKey = @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAM1nPUUuVeAKg+1bpbEL/6qrockOB8j3qBONq+Krrc+UWEC2fpoQi6gNi3Elx3JEXkS29hIaHZA2mFX5BtCtRqcCsWa53L39/9kziB4xs6/zXz+TMfeagTJeXoyNMM4wUAQmxgN6x3ts1Am9SNiXDVCQdQ5uqiVIxe7odrzfvbPZAgMBAAECgYBnYIZdwyxFTgWH+JAzwy4x35/VaNJSOxLEhJD1zCH2T1r7dt3Q/HLNacO8dp8iy3YGb275PVuTsWaKHoNnk03y6Xzsa9Ut+FYZA+r+PuXGlXhnE3CRietXk4QmDMfe6KyTLvxbLGSWnlC0uTrY6Fv1ipcjM/JumvxYFxUGaJx9gQJBAOZy8y6vnfkfzBffn6RSPGelvXD9RlD8yga7UpF7WBO4b+HNtg3K+VuFlCPriHLkvhy+ZpIlsJDQ2SRxbJb5RPUCQQDkLWSDB6ueRQ/y1V5/sIMq3vnQjy6hBvkFxexM8IsIMwY9hcpYrz5to/8tVHrFzg9jyC6yz5Ddn5/UL82aBYTVAkEAyB0dy3a5CXJxOnH4IStARQkJvqpRe1Zo4PudsbOYQlew4DZQVx3g93bBs4d+j7bO2AsG6vZLoxWY2iqcj2WaWQJBAItfyrhalBKNvssmV52JVOV344HoI6RKXQuQtODeQR5WBGbJ9SosiOZxuOmYY5G1ZyMc4KFqNeOZoAf81wpQeq0CQQDUgiGdsE7H/3rzAzoFoWgFzQCQwAewDmjVTaep7d8Otne3LEn2yLWNYb21g3umkoGfwVFeFqhnjGWZNiqxezpG";
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
    order.sellerID = seller;
    //    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.outTradeNO = payId;
    //商品标题
    NSString *aMonth =  [[NSString alloc] initWithFormat:@"%i",[self.dateLabel.text substringWithRange:NSMakeRange(5, 2)].intValue];
    NSString *aDay =  [[NSString alloc] initWithFormat:@"%i",[self.dateLabel.text substringWithRange:NSMakeRange(8, 2)].intValue];
    NSArray *timeSlot1Array = [[self.orderInfo.siteTimeList[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@" "];
    ;
    if (self.orderInfo.siteTimeList.count > 1) {
        order.subject = [[NSString alloc] initWithFormat:@"泡泡体育%@月%@日%@点至%@点%@%@等预定",aMonth,aDay,[timeSlot1Array[2] substringToIndex:2],[timeSlot1Array[4] substringToIndex:2],self.orderInfo.sportTypeName,timeSlot1Array[0]];
    } else {
        order.subject = [[NSString alloc] initWithFormat:@"泡泡体育%@月%@日%@点至%@点%@%@预定",aMonth,aDay,[timeSlot1Array[2] substringToIndex:2],[timeSlot1Array[4] substringToIndex:2],self.orderInfo.sportTypeName,timeSlot1Array[0]];
    }
    order.body = self.orderInfo.orderTitle; //商品描述;
    order.totalFee = self.orderInfo.totalMoney;
    order.notifyURL =  kAlipayCallbackUrl; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = remainTime;
    order.showURL = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"IndoorIOS";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
//    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
//    id<DataSigner> signer = CreateRSADataSigner(privateKey);
//    NSString *signedString = [signer signString:orderSpec];
    NSString *signedString = [[[NSString alloc] init] alipayOrderRSASignWithPrivateKey:privateKey];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//            NSLog(@"同步返回 reslut = %@",resultDic);
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

/**
 * 获取用户详细信息
 */
-(void) getUserInfo{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            CADUser *user = CADUserManager.sharedInstance.getUser;
            if (user == nil || user.phone == nil){
                NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                NSData *data = [defaults objectForKey:@"user"];
                user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if (user != nil){
                    [CADUserManager.sharedInstance setUser:user];
                }
            }

            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','phone':'%@'}",self.timeStamp,[Utils md5:beforeMd5],user.phone]};
            
            [self.afm POST:kGetUserInfoJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取用户信息错误" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
                    NSLog(@"JSON: %@", responseObject);
                    NSDictionary *userInfo = [responseObject objectForKey:@"userInfo"];
                    
                    user.fee = [userInfo objectForKey:@"fee"];
                    user.idString = [userInfo objectForKey:@"id"];
                    user.mail = [userInfo objectForKey:@"mail"];
                    user.phone = [userInfo objectForKey:@"phone"];
                    user.sex_code = [userInfo objectForKey:@"sex_code"];
//                    user.sex_name = [userInfo objectForKey:@"sec_name"];
                    user.imgUrl = [userInfo objectForKey:@"image_url"];
//                    user.address = [userInfo objectForKey:@"address"];
//                    user.area_code = [userInfo objectForKey:@"area_code"];
//                    user.area_name = [userInfo objectForKey:@"area_name"];
                    user.name = [userInfo objectForKey:@"name"];
                    user.score = [userInfo objectForKey:@"score"];
                    user.qq = [userInfo objectForKey:@"qq"];
                    
                    [self.RemainPayButton setTitle:[[NSString alloc] initWithFormat:@"余额(%@)",user.fee] forState:UIControlStateNormal];
                    int fee = [user.fee intValue];
                    if (fee == 0 || fee < [self.orderInfo.totalMoney intValue]) {
                        [self.RemainPayButton setEnabled:false];
                        self.RemainPayButton.backgroundColor = [UIColor lightGrayColor];
                    } else {
                        [self.RemainPayButton setEnabled:true];
                        self.RemainPayButton.backgroundColor = self.view.tintColor;
                    }
                    
                    [self.useScoreText setPlaceholder:[[NSString alloc] initWithFormat:@"您的积分 : %@",user.score]];
                    
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取用户信息错误" setMessage:[error localizedDescription]];
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

/**
 * 获取积分规则 {"item":{"fee":"0.10","percent":"10.00","low":"100.00"},"success":true}
 */
-(void) getRule{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            CADUser *user = CADUserManager.sharedInstance.getUser;
            if (user == nil || user.phone == nil){
                NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                NSData *data = [defaults objectForKey:@"user"];
                user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if (user != nil){
                    [CADUserManager.sharedInstance setUser:user];
                }
            }
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@'}",self.timeStamp,[Utils md5:beforeMd5]]};
            
            [self.afm POST:KRuleJFDK parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取积分规则异常" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
                    NSLog(@"JSON: %@", responseObject);
                    CADUserManager *cm = CADUserManager.sharedInstance;
                    cm.fee2Rmb = [[[responseObject objectForKey:@"item"] objectForKey:@"fee"] floatValue];
                    cm.maxRatio = [[[responseObject objectForKey:@"item"] objectForKey:@"percent"] floatValue];
                    cm.downLimit = [[[responseObject objectForKey:@"item"] objectForKey:@"low"] floatValue];
                    
                    [self.ruleTips setText:[[NSString alloc] initWithFormat:@"*订单%.0f元起可用积分，1积分可抵%.02f元，最多可抵订单%.0f%%。 ",cm.downLimit, cm.fee2Rmb,cm.maxRatio]];

                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取积分规则异常" setMessage:[error localizedDescription]];
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

/**
 * 调用支付宝支付前的订单验证
 */
-(void) preAliPay {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','orderId':'%@','payParam':{'orderId':'%@'}}",self.timeStamp,[Utils md5:beforeMd5],self.orderInfo.orderId,self.orderInfo.orderId]};
            
            [self.afm POST:kPreAliPayUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取订单状态异常" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
                    NSLog(@"JSON: %@", responseObject);
                    
                    // real alipay invocation
                    [self Alipay:[responseObject objectForKey:@"payId"] inTime:[responseObject objectForKey:@"remainTime"]];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取订单状态异常" setMessage:[error localizedDescription]];
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

/**
 * 从服务器获取场馆详情
 */
-(void) getSiteDetail {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','sportSiteId':'%@'}",self.timeStamp,[Utils md5:beforeMd5],self.orderInfo.sportId]};
            
            [self.afm POST:kStadiumDetailJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取场馆详情异常" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
                    NSLog(@"JSON: %@", responseObject);
                    // 重新设置地址
                    StadiumManager *stadiumManager = [StadiumManager sharedInstance];
                    StadiumRecord *stadium = [stadiumManager.stadiumList objectForKey:self.orderInfo.sportId];
                    [stadium setGotDetail:TRUE];
                    self.addressLabel.text = stadium.address;
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取场馆详情异常" setMessage:[error localizedDescription]];
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

- (IBAction)switchAction:(id)sender {
}
@end