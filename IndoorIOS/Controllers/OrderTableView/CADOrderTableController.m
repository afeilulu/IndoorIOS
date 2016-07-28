//
//  CADOrderTableController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/28.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADOrderTableController.h"
#import "Utils.h"
#import "Constants.h"
#import "CADAlertManager.h"
#import "CADUserManager.h"
#import "CADOrderListItem.h"
#import "CADOrderTableCell.h"
#import <UIImageView+WebCache.h>

NSString *const kCADOrderTableCellIdentifier = @"CADOrderTableCell";
NSString *const kCADOrderTableCellNibName = @"CADOrderTableCell";

@interface CADOrderTableController ()

@end

@implementation CADOrderTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = self.codeDesc;
    
    self.afm = [AFHTTPSessionManager manager];
    
    // hide empty cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // we use a nib which contains the cell's view and this class as the files owner
    [self.tableView registerNib:[UINib nibWithNibName:kCADOrderTableCellNibName bundle:nil] forCellReuseIdentifier:kCADOrderTableCellIdentifier];
    
    // 结束时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow: +(24 * 60 * 60)];
    self.tomorrow = [dateFormatter stringFromDate:tmpDate];
    
    [self getOrderListFrom:@"2015-01-01" to:self.tomorrow];
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
    return self.orders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CADOrderTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kCADOrderTableCellIdentifier forIndexPath:indexPath];
    
    CADOrderListItem *item = [self.orders objectAtIndex:indexPath.row];
    
    [cell.icon sd_setImageWithURL:[NSURL URLWithString:item.sportTypeSmallImage]];
    cell.title.text = item.orderTitle;
    cell.pay.text = [[NSString alloc] initWithFormat:@"￥%@",item.payFee];
    cell.date.text = item.createTime;
    cell.valiCode.text = [[NSString alloc] initWithFormat:@"验证码 %@",item.valiCode];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
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
 * 按状态获取订单
 */
- (void)getOrderListFrom:(NSString *)fromDateString to:(NSString *)toDateString{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            CADUser *user = [[CADUserManager sharedInstance] getUser];
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','phone':'%@','startDate':'%@','endDate':'%@','code':'%@'}",self.timeStamp,[Utils md5:beforeMd5],user.phone,fromDateString,toDateString,self.code]};
            
            [self.afm POST:kOrderStatusListJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取订单列表错误" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
                    //                    NSLog(@"JSON: %@", responseObject);
                    NSArray *listArray = [responseObject objectForKey:@"list"];
                    
                    self.orders = [[NSMutableArray alloc] init];
                    for (int i=0; i < listArray.count; i++) {
                        NSDictionary *item = (NSDictionary *)[listArray objectAtIndex:i];
                        CADOrderListItem *orderItem = [[CADOrderListItem alloc] init];
                        [orderItem setCreateTime:[item objectForKey:@"pay_time"]]; // 支付时间
//                        [orderItem setFpPrintYn:[item objectForKey:@"fpPrintYn"]];
                        [orderItem setOrderId:[item objectForKey:@"id"]];
//                        [orderItem setOrderSeq:[item objectForKey:@"orderSeq"]];
//                        [orderItem setOrderStatus:[item objectForKey:@"orderStatus"]];
                        [orderItem setOrderTitle:[item objectForKey:@"orderTitle"]];
//                        [orderItem setRemainTime:[[item objectForKey:@"remainTime"] intValue]];
//                        [orderItem setSiteTimeList:[item objectForKey:@"siteTimeList"]];
                        [orderItem setTotalMoney:[item objectForKey:@"payable_fee"]]; // 总金额
//                        [orderItem setZflx:[item objectForKey:@"zflx"]];
//                        [orderItem setSportId:[item objectForKey:@"sportId"]];
//                        [orderItem setSportTypeId:[item objectForKey:@"sportTypeId"]];
                        [orderItem setSportTypeName:[item objectForKey:@"sportTypeName"]];
                        [orderItem setSportTypeSmallImage:[item objectForKey:@"sportTypeSmallImage"]];
                        
                        [orderItem setPayFee:[item objectForKey:@"pay_fee"]]; // 实际支付金额
                        [orderItem setUsedScoreAmount:[item objectForKey:@"exchange_amount"]];
                        [orderItem setUsedScoreToFee:[item objectForKey:@"exchange_fee"]];
                        [orderItem setValiCode:[item objectForKey:@"validate_code"]];
                        
                        [self.orders addObject:orderItem];
                    }
                    
                    [self.tableView reloadData];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取订单列表错误" setMessage:[error localizedDescription]];
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
 * 订单统计
 * 待支付 待消费 已消费 退款
 */
- (void) statistics{
    
}

@end
