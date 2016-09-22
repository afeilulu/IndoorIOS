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
#import "CADPayScoreRuleCell.h"
#import "CADPayScoreCell.h"
#import <AlipaySDK-2.0/AlipaySDK/AlipaySDK.h>
#import <AlipaySDK-2.0/NSString+AlipayOrder.h>
#import <UIImageView+WebCache.h>
#import "SDWebImagePrefetcher.h"
#import "CADOrderDetailSportTypeCell.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <CommonCrypto/CommonDigest.h>

NSString *const kPayMethodCellIdentifier = @"CADPayMethodCell";
NSString *const kPayMethodCellNibName = @"CADPayMethodCell";

NSString *const kCADOrderDetailNormalCellIdentifier = @"CADOrderDetailNormalCell";
NSString *const kCADOrderDetailNormalCellNibName = @"CADOrderDetailNormalCell";

NSString *const kCADOrderDetailMoneyCellIdentifier = @"CADOrderDetailMoneyCell";
NSString *const kCADOrderDetailMoneyCellNibName = @"CADOrderDetailMoneyCell";

NSString *const kCADPayScoreCellIdentifier = @"CADPayScoreCell";
NSString *const kCADPayScoreCellNibName = @"CADPayScoreCell";

NSString *const kCADOrderDetailSportTypeCellIdentifier = @"CADOrderDetailSportTypeCell";
NSString *const kCADOrderDetailSportTypeCellNibName = @"CADOrderDetailSportTypeCell";

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
    
    self.title = @"订单";
    
    // we use a nib which contains the cell's view and this class as the files owner
    [self.tableView registerNib:[UINib nibWithNibName:kPayMethodCellNibName bundle:nil] forCellReuseIdentifier:kPayMethodCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kCADOrderDetailNormalCellNibName bundle:nil] forCellReuseIdentifier:kCADOrderDetailNormalCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kCADOrderDetailMoneyCellNibName bundle:nil] forCellReuseIdentifier:kCADOrderDetailMoneyCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kCADPayScoreCellNibName bundle:nil] forCellReuseIdentifier:kCADPayScoreCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kCADOrderDetailSportTypeCellNibName bundle:nil] forCellReuseIdentifier:kCADOrderDetailSportTypeCellIdentifier];
    
    self.originalTotalMoney = [self.orderInfo.totalMoney floatValue];
    
    // hide empty cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self initAlertController];
    
    NSArray *prefetchURLs = [[NSArray alloc] initWithObjects:self.orderInfo.sportTypeSmallImage, nil];
    SDWebImagePrefetcher *prefetcher = [SDWebImagePrefetcher sharedImagePrefetcher];
    [prefetcher prefetchURLs:prefetchURLs progress:nil completed:^(NSUInteger completedNo, NSUInteger skippedNo) {
        NSLog(@"%@ - %@", NSStringFromClass([self class]),@"image prefetched");
        NSArray *indexPathArray = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil];
        [self.tableView  reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    if (self.orderInfo.siteTimeList == nil || self.orderInfo.siteTimeList.count == 0) {
        // 查询订单详情
        [self getOrderDetail];
    }
}


- (void)viewWillAppear:(BOOL)animated{
    // update user info
    [self getUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            // 订单信息
            return [self.orderInfo.siteTimeList count] + 2;
            break;
        
        case 1:
            // 积分
            return 2;
            break;
            
        default:
            // 支付
            return 4;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = [self.orderInfo.siteTimeList count];
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0){
        
        if (indexPath.row == 0) {
            CADOrderDetailSportTypeCell *sportTypeCell = [tableView dequeueReusableCellWithIdentifier:kCADOrderDetailSportTypeCellIdentifier];
            NSArray *array = [self.orderInfo.orderTitle componentsSeparatedByString:@" "];
            sportTypeCell.textLabel.text = array[0];
            sportTypeCell.detailTextLabel.text = @"";
            [sportTypeCell.imageView sd_setImageWithURL:[NSURL URLWithString:self.orderInfo.sportTypeSmallImage]];
            cell = sportTypeCell;
        } else if (indexPath.row - 1 < count) {
            cell = [tableView dequeueReusableCellWithIdentifier:kCADOrderDetailNormalCellIdentifier];
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = self.orderInfo.siteTimeList[indexPath.row - 1];
        } else if (indexPath.row - 1 == count){
            cell = [tableView dequeueReusableCellWithIdentifier:kCADOrderDetailMoneyCellIdentifier];
            cell.textLabel.text = @"订单金额";
            cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"￥%@",self.orderInfo.totalMoney ];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([self isNotPaid]){
        
        if (indexPath.section == 1){
            if (indexPath.row == 0){
                CADPayScoreRuleCell *ruleCell = [tableView dequeueReusableCellWithIdentifier:@"CADPayScoreRuleCell"];
                
                if (ruleCell == nil)
                    ruleCell = [CADPayScoreRuleCell makeCell];
                
                CADUserManager *cm = [CADUserManager sharedInstance];
                ruleCell.ruleLabel.text = [[NSString alloc] initWithFormat:@"*订单%.0f元起可用积分，1积分可抵%.02f元，最多可抵订单%.0f%%。 ",cm.downLimit, cm.fee2Rmb,cm.maxRatio];
                
                cell = ruleCell;
            }
            
            if (indexPath.row == 1){
                CADPayScoreCell *scoreCell = [tableView dequeueReusableCellWithIdentifier:kCADPayScoreCellIdentifier forIndexPath:indexPath];
                
                if (scoreCell == nil)
                    scoreCell = [CADPayScoreCell makeCell];
                
                scoreCell.textLabel.text = @"积分抵扣";
                if (self.usedScore > 0){
                    CADUserManager *cm = [CADUserManager sharedInstance];
                    scoreCell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"￥%.02f",self.usedScore * cm.fee2Rmb] ;
                } else {
                    scoreCell.detailTextLabel.text = @"";
                }
                
                cell = scoreCell;
            }
        }
        
        if (indexPath.section == 2){
            
            
            switch (indexPath.row) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:kCADOrderDetailMoneyCellIdentifier];
                    CADUserManager *cm = [CADUserManager sharedInstance];
                    cell.textLabel.text = @"还需支付";
                    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"￥%.02f",self.originalTotalMoney - self.usedScore * cm.fee2Rmb ];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    break;
                }
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:kPayMethodCellIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = @"余额支付";
                    
                    CADUser *cu = [[CADUserManager sharedInstance] getUser];
                    CADUserManager *cm = [CADUserManager sharedInstance];
                    NSString *check;
                    if (self.originalTotalMoney - self.usedScore * cm.fee2Rmb > [cu.fee floatValue]){
                        check = [[NSString alloc] initWithFormat:@"您的余额(￥%@)不足",cu.fee];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    } else {
                        check = [[NSString alloc] initWithFormat:@"您的余额:￥%@",cu.fee];
                        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    }
                    cell.detailTextLabel.text = check;
                    
                    break;
                }
                case 2:
                    cell = [tableView dequeueReusableCellWithIdentifier:kPayMethodCellIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = @"微信支付";
                    break;
                    
                case 3:
                    cell = [tableView dequeueReusableCellWithIdentifier:kPayMethodCellIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = @"支付宝";
                    break;
                default:
                    break;
            }
        }
    } else {
        
        // 已经支付
        
        if (indexPath.section == 1){
            if (indexPath.row == 0){
                CADPayScoreRuleCell *ruleCell = [tableView dequeueReusableCellWithIdentifier:@"CADPayScoreRuleCell"];
                
                if (ruleCell == nil)
                    ruleCell = [CADPayScoreRuleCell makeCell];
                
                CADUserManager *cm = [CADUserManager sharedInstance];
                ruleCell.ruleLabel.text = [[NSString alloc] initWithFormat:@"*订单%.0f元起可用积分，1积分可抵%.02f元，最多可抵订单%.0f%%。 ",cm.downLimit, cm.fee2Rmb,cm.maxRatio];
                
                cell = ruleCell;
            }
            
            if (indexPath.row == 1){
                cell = [tableView dequeueReusableCellWithIdentifier:kCADOrderDetailMoneyCellIdentifier];
                
                cell.textLabel.text = @"积分抵扣";
                if (_orderInfo.usedScoreToFee.length > 0){
                    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"￥%@",_orderInfo.usedScoreToFee] ;
                } else {
                    cell.detailTextLabel.text = @"无";
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        
        if (indexPath.section == 2){
            
            switch (indexPath.row) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:kCADOrderDetailMoneyCellIdentifier];
                    cell.textLabel.text = @"实际支付";
                    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"￥%@",self.orderInfo.payFee];
                    
                    break;
                }
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:kCADOrderDetailNormalCellIdentifier];
                    cell.textLabel.text = @"支付方式";
                    cell.detailTextLabel.text = self.orderInfo.payType;
                    
                    break;
                }
                case 2:
                    cell = [tableView dequeueReusableCellWithIdentifier:kCADOrderDetailNormalCellIdentifier];
                    cell.textLabel.text = @"支付日期";
                    cell.detailTextLabel.text = self.orderInfo.payDate;
                    break;
                    
                case 3:
                    cell = [tableView dequeueReusableCellWithIdentifier:kCADOrderDetailNormalCellIdentifier];
                    cell.textLabel.text = @"验证码";
                    cell.detailTextLabel.text = self.orderInfo.valiCode;
                    break;
                default:
                    break;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![self isNotPaid]){
        return;
    }
    
    if (indexPath.section == 1 && indexPath.row == 1){
        CADUserManager *cm = [CADUserManager sharedInstance];
        if (self.originalTotalMoney > cm.downLimit){
            // 使用积分
            [self presentViewController:self.scoreAlertController animated:YES completion:nil];
        }
    }
    
    if (indexPath.section == 2){
        // 支付
        switch (indexPath.row) {
            case 1:
                // 余额
            {
                [self presentViewController:self.alertController animated:YES completion:nil];
                break;
            }
            case 2:
                // 微信
                [self wxPayAction];
                break;
                
            case 3:
                // 支付宝
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
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','orderId':'%@','payParam':{'orderId':'%@'},'isUseJf':%@,'jf':'%.0f'}",self.timeStamp,[Utils md5:beforeMd5],self.orderInfo.orderId,self.orderInfo.orderId,self.usedScore>0?@YES:@NO,self.usedScore]};
            
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
            NSString* errmsg = [responseObject objectForKey:@"msg"];
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
    
    CADUserManager *cm = [CADUserManager sharedInstance];
    NSString *orderString = [NSString
                             alipayOrderWithPartner:partner
                             seller:seller
                             productName:self.orderInfo.orderTitle
                             productDescription:self.orderInfo.orderTitle
                             amount:[[NSString alloc] initWithFormat:@"%.02f",self.originalTotalMoney - self.usedScore * cm.fee2Rmb]
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
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','phone':'%@','orderId':'%@','payPassword':'%@','isUseJf':%@,'jf':'%.0f'}",self.timeStamp,[Utils md5:beforeMd5],user.phone,self.orderInfo.orderId,password,self.usedScore>0?@YES:@NO,self.usedScore]};
            
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
            NSString* errmsg = [responseObject objectForKey:@"msg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
}


#pragma mark - 微信支付

- (void)wxPayAction{

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','deviceInfo':'WEB','orderId':'%@','isUseJf':%@,'jf':'%.0f'}",self.timeStamp,[Utils md5:beforeMd5],self.orderInfo.orderId,self.usedScore>0?@YES:@NO,self.usedScore]};
            
            [self.afm POST:kWXPayUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"微信支付异常" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
                    NSDictionary *dict = [responseObject objectForKey:@"msg"];
                    
                    //调起微信支付
                    PayReq* req             = [[PayReq alloc] init];
                    req.partnerId           = [dict objectForKey:@"mch_id"];
                    req.prepayId            = [dict objectForKey:@"prepay_id"];
                    req.nonceStr            = [dict objectForKey:@"nonce_str"];
                    req.timeStamp           = self.timeStamp.intValue;
                    req.package             = @"Sign=WXPay";
                    req.sign                = [self createMD5SingForPayWithAppID:[dict objectForKey:@"appid"] partnerid:req.partnerId prepayid:req.prepayId package:req.package noncestr:req.nonceStr timestamp:req.timeStamp];
                    [WXApi sendReq:req];
                    //日志输出
                    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                    
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"微信支付异常" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"msg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
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
//                    NSLog(@"JSON: %@", responseObject);
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
                    
                    self.maxScoreCanBeUse = [user.score floatValue];
                    CADUserManager *cm = [CADUserManager sharedInstance];
                    CGFloat thisOrderScore = self.originalTotalMoney * cm.maxRatio / cm.fee2Rmb / 100;
                    if (self.maxScoreCanBeUse > thisOrderScore ){
                        self.maxScoreCanBeUse = thisOrderScore;
                    }
                    
                    [self initScoreAlertController];
                    
                    // TODO
                    // 更新积分
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取用户信息错误" setMessage:[error localizedDescription]];
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

/**
 * 查询订单详情
 */
-(void) getOrderDetail{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','orderId':'%@'}",self.timeStamp,[Utils md5:beforeMd5],self.orderInfo.orderId]};
            
            [self.afm POST:kOrderInfoJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取订单详情错误" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
//                    NSLog(@"JSON: %@", responseObject);
                    self.orderInfo.siteTimeList = [[responseObject objectForKey:@"orderInfo" ] objectForKey:@"siteTimeList"];
                    
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取订单详情错误" setMessage:[error localizedDescription]];
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

#pragma marks - remain pay alert controller

- (void)initAlertController{
    CADUser *cu = [[CADUserManager sharedInstance] getUser];
    
    self.alertController = [UIAlertController
                                          alertControllerWithTitle:@"余额支付"
                            message:[[NSString alloc] initWithFormat:@"您的余额:￥%@元",cu.fee]
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

- (void)initScoreAlertController{
    
    CADUser *cu = [[CADUserManager sharedInstance] getUser];
    
    self.scoreAlertController = [UIAlertController
                            alertControllerWithTitle:@"使用积分"
                            message:[[NSString alloc] initWithFormat:@"您的积分:%@分",cu.score ]
                            preferredStyle:UIAlertControllerStyleAlert
                            ];
    
    __weak CADPayTableViewController * weakSelf = self;
    
    [self.scoreAlertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = [[NSString alloc] initWithFormat:@"本订单最多使用%.00f积分" ,weakSelf.maxScoreCanBeUse];
         textField.secureTextEntry = NO;
         textField.keyboardType = UIKeyboardTypeNumberPad;
         [textField addTarget:weakSelf
                       action:@selector(scoreTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"取消", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       
                                       UITextField *score = self.scoreAlertController.textFields.lastObject;
                                       score.text = @"";
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"确定", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *score = self.scoreAlertController.textFields.lastObject;
                                   
                                   if ([score.text stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceCharacterSet]].length > 0 ){
                                       self.usedScore = [score.text floatValue];
                                       
                                       score.text = @"";
                                       action.enabled = NO;
                                       
                                       NSArray *indexPathArray = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:0 inSection:2], nil];
                                       [weakSelf.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationBottom];
                                   }
                               }];
    
    okAction.enabled = NO;
    
    [self.scoreAlertController addAction:cancelAction];
    [self.scoreAlertController addAction:okAction];
    
}

- (void)scoreTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *scoreAlertController = (UIAlertController *)self.presentedViewController;
    if (scoreAlertController)
    {
        UITextField *scoreText = scoreAlertController.textFields.lastObject;
        UIAlertAction *okAction = scoreAlertController.actions.lastObject;
        
        __weak CADPayTableViewController * weakSelf = self;
        
        if ([Utils textIsValidValue:scoreText.text]){
            okAction.enabled = [scoreText.text stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]].length > 0 && [scoreText.text floatValue] < weakSelf.maxScoreCanBeUse+1;
        }
    }
}

- (BOOL)isNotPaid {
    return self.orderInfo.status == nil                    // 新建订单
    || [self.orderInfo.status isEqualToString:@"0"] // 未支付
    || [self.orderInfo.status isEqualToString:@"1"] // 支付中
    || [self.orderInfo.status isEqualToString:@"2"] // 用户取消
    || [self.orderInfo.status isEqualToString:@"4"]; // 支付失败
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (self
            && [self respondsToSelector:@selector(managerDidRecvMessageResponse:)]) {
            SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
            [self managerDidRecvMessageResponse:messageResp];
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (self
            && [self respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [self managerDidRecvAuthResponse:authResp];
        }
    } else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {
        if (self
            && [self respondsToSelector:@selector(managerDidRecvAddCardResponse:)]) {
            AddCardToWXCardPackageResp *addCardResp = (AddCardToWXCardPackageResp *)resp;
            [self managerDidRecvAddCardResponse:addCardResp];
        }
    }else if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *strMsg,*strTitle = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = @"支付结果：成功！";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
        }
        [CADAlertManager showAlert:self setTitle:strTitle setMessage:strMsg];
    }
    
}

- (void)onReq:(BaseReq *)req {
    if ([req isKindOfClass:[GetMessageFromWXReq class]]) {
        if (self
            && [self respondsToSelector:@selector(managerDidRecvGetMessageReq:)]) {
            GetMessageFromWXReq *getMessageReq = (GetMessageFromWXReq *)req;
            [self managerDidRecvGetMessageReq:getMessageReq];
        }
    } else if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        if (self
            && [self respondsToSelector:@selector(managerDidRecvShowMessageReq:)]) {
            ShowMessageFromWXReq *showMessageReq = (ShowMessageFromWXReq *)req;
            [self managerDidRecvShowMessageReq:showMessageReq];
        }
    } else if ([req isKindOfClass:[LaunchFromWXReq class]]) {
        if (self
            && [self respondsToSelector:@selector(managerDidRecvLaunchFromWXReq:)]) {
            LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
            [self managerDidRecvLaunchFromWXReq:launchReq];
        }
    }
}

#pragma mark - WXApiManagerDelegate
- (void)managerDidRecvGetMessageReq:(GetMessageFromWXReq *)req {
    // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
    NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
    NSString *strMsg = [NSString stringWithFormat:@"openID: %@", req.openID];
    
    [CADAlertManager showAlert:self setTitle:strTitle setMessage:strMsg];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
//                                                    message:strMsg
//                                                   delegate:self
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil, nil];
//    alert.tag = kRecvGetMessageReqAlertTag;
//    [alert show];
//    [alert release];
}

- (void)managerDidRecvShowMessageReq:(ShowMessageFromWXReq *)req {
    WXMediaMessage *msg = req.message;
    
    //显示微信传过来的内容
    WXAppExtendObject *obj = msg.mediaObject;
    
    NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
    NSString *strMsg = [NSString stringWithFormat:@"openID: %@, 标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%lu bytes\n附加消息:%@\n", req.openID, msg.title, msg.description, obj.extInfo, (unsigned long)msg.thumbData.length, msg.messageExt];
    
    [CADAlertManager showAlert:self setTitle:strTitle setMessage:strMsg];
}

- (void)managerDidRecvLaunchFromWXReq:(LaunchFromWXReq *)req {
    WXMediaMessage *msg = req.message;
    
    //从微信启动App
    NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
    NSString *strMsg = [NSString stringWithFormat:@"openID: %@, messageExt:%@", req.openID, msg.messageExt];
    
    [CADAlertManager showAlert:self setTitle:strTitle setMessage:strMsg];
}

- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response {
    NSString *strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", response.errCode];
    
    [CADAlertManager showAlert:self setTitle:strTitle setMessage:strMsg];
}

- (void)managerDidRecvAddCardResponse:(AddCardToWXCardPackageResp *)response {
    NSMutableString* cardStr = [[NSMutableString alloc] init];
    for (WXCardItem* cardItem in response.cardAry) {
        [cardStr appendString:[NSString stringWithFormat:@"cardid:%@ cardext:%@ cardstate:%u\n",cardItem.cardId,cardItem.extMsg,(unsigned int)cardItem.cardState]];
    }
    [CADAlertManager showAlert:self setTitle:@"add card resp" setMessage:cardStr];
}

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response {
    NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
    NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d", response.code, response.state, response.errCode];
    
    [CADAlertManager showAlert:self setTitle:strTitle setMessage:strMsg];
}

#pragma mark -  微信支付本地签名
//创建发起支付时的sign签名
-(NSString *)createMD5SingForPayWithAppID:(NSString *)appid_key partnerid:(NSString *)partnerid_key prepayid:(NSString *)prepayid_key package:(NSString *)package_key noncestr:(NSString *)noncestr_key timestamp:(UInt32)timestamp_key{
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject:appid_key forKey:@"appid"];//微信appid 例如wxfb132134e5342
    [signParams setObject:noncestr_key forKey:@"noncestr"];//随机字符串
    [signParams setObject:package_key forKey:@"package"];//扩展字段  参数为 Sign=WXPay
    [signParams setObject:partnerid_key forKey:@"partnerid"];//商户账号
    [signParams setObject:prepayid_key forKey:@"prepayid"];//此处为统一下单接口返回的预支付订单号
    [signParams setObject:[NSString stringWithFormat:@"%u",timestamp_key] forKey:@"timestamp"];//时间戳
    
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [signParams allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[signParams objectForKey:categoryId] isEqualToString:@""]
            && ![[signParams objectForKey:categoryId] isEqualToString:@"sign"]
            && ![[signParams objectForKey:categoryId] isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [signParams objectForKey:categoryId]];
        }
    }
    //添加商户密钥key字段  API 密钥
    [contentString appendFormat:@"key=%@", kWXMchKey];
    NSString *result = [self generateMD5:contentString];//md5加密
    return result;
}

/**
 * #import <CommonCrypto/CommonDigest.h>
 *  MD5 加密
 *
 *  @return 加密后字符串
 */
- (NSString *) generateMD5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
