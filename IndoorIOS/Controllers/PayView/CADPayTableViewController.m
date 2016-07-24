//
//  CADPayTableViewController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/23.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADPayTableViewController.h"
#import "CADStoryBoardUtilities.h"
#import "Constants.h"
#import "CADAlertManager.h"
#import "Order.h"
#import "Utils.h"
#import "CADUser.h"
#import "CADUserManager.h"
#import <AlipaySDK-2.0/AlipaySDK/AlipaySDK.h>
#import <AlipaySDK-2.0/NSString+AlipayOrder.h>

NSString *const kPayMethodCellIdentifier = @"CADPayMethodCell";
NSString *const kPayMethodCellNibName = @"CADPayMethodCell";

@interface CADPayTableViewController ()

@end

@implementation CADPayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.afm = [AFHTTPSessionManager manager];
    
    // we use a nib which contains the cell's view and this class as the files owner
    [self.tableView registerNib:[UINib nibWithNibName:kPayMethodCellNibName bundle:nil] forCellReuseIdentifier:kPayMethodCellIdentifier];
    
    // hide empty cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self initAlertController];
}


- (void)viewWillAppear:(BOOL)animated{
    // update user info
    [self getUserInfo];
    
    // 获取积分规则
    [self getRule];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPayMethodCellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"余额支付";
                break;
                
            case 1:
                cell.textLabel.text = @"微信支付";
                break;
                
            case 2:
                cell.textLabel.text = @"支付宝";
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
            {
                [self presentViewController:self.alertController animated:YES completion:nil];
                break;
            }
            case 1:
                break;
                
            case 2:
                [self preAliPay];
                break;
            default:
                break;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    
    NSString *orderString = [NSString
                             alipayOrderWithPartner:partner
                             seller:seller
                             productName:self.orderInfo.orderTitle
                             productDescription:self.orderInfo.orderTitle
                             amount:self.orderInfo.totalMoney
                             notifyURL:kAlipayCallbackUrl
                             tradeNumber:payId
                             rsaPrivateKey:privateKey
                             ];
    
    NSString *appScheme = @"IndoorIOS";
    
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
                    user.imgUrl = [userInfo objectForKey:@"image_url"];
                    user.name = [userInfo objectForKey:@"name"];
                    user.score = [[userInfo objectForKey:@"score"] stringValue];
                    user.qq = [userInfo objectForKey:@"qq"];
                    
                    // TODO
                    // 设置余额和积分
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
                    
                    // TODO
                    // 显示积分规则
//                    [self.ruleTips setText:[[NSString alloc] initWithFormat:@"*订单%.0f元起可用积分，1积分可抵%.02f元，最多可抵订单%.0f%%。 ",cm.downLimit, cm.fee2Rmb,cm.maxRatio]];
                    
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

#pragma marks - remain pay alert controller

- (void)initAlertController{
    self.alertController = [UIAlertController
                                          alertControllerWithTitle:@"余额支付"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert
                                          ];
    
    __weak CADPayTableViewController * weakSelf = self;
    
    [self.alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"余额支付密码", @"password");
         textField.secureTextEntry = YES;
         [textField addTarget:weakSelf
                       action:@selector(alertTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"取消", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"确定", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *password = self.alertController.textFields.lastObject;
                                   [self RemainPayWithPassword:password.text];
                                   
                                   password.text = @"";
                                   action.enabled = NO;
                               }];
    
    okAction.enabled = NO;
    
    [self.alertController addAction:cancelAction];
    [self.alertController addAction:okAction];
    
}

- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *password = alertController.textFields.lastObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = password.text.length > 4;
    }
}

@end
