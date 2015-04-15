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
#import <AlipaySDK/AlipaySDK.h>

@interface CADPayViewController ()

@property (weak, nonatomic) IBOutlet UIButton *ConfirmPayButton;
- (IBAction)payAction:(id)sender;

@end

@implementation CADPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _ConfirmPayButton.layer.cornerRadius = 5.0;
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


- (IBAction)payAction:(id)sender {
    NSLog(@"pay clicked");
    
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
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.productName = @"商品标题"; //商品标题
    order.productDescription = @"商品描述"; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",0.01]; //商品价格
    order.notifyURL =  @"http://www.baidu.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"chinaairdome";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
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

@end