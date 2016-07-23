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
#import <AlipaySDK-2.0/AlipaySDK/AlipaySDK.h>
#import <AlipaySDK-2.0/NSString+AlipayOrder.h>
#import <AlipaySDK-2.0/NSString+AlipaySigner.h>

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
                break;
                
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
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
                             productName:@"1"
                             productDescription:@"测试"
                             amount:[NSString stringWithFormat:@"%.2f",0.02f]
                             notifyURL:@"http://www.xxx.com"
                             tradeNumber:[NSString generateAlipayTradeNo]
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


@end
