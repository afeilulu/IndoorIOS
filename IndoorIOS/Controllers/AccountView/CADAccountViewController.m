//
//  CADAccountViewController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/16.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//
//  section 0 : 帐号信息(头像，名称，积分，余额)，订单信息
//  section 1 : 已有的场馆预约，如果有
//  section 2 : 已有的教练预约，如果有
//  section 3 : 参与的活动，如果有
//  section 4 : 设置
//  section 5 : 退出
//

#import "CADAccountViewController.h"
#import "CADUser.h"
#import "CADUserManager.h"
#import "CADAlertManager.h"
#import "Constants.h"
#import "Utils.h"
#import "CADAccountDetailCell.h"
#import <UIImageView+WebCache.h>
#import "CADLoginController.h"
#import "CADStoryBoardUtilities.h"
#import "CADAccountLogoutCell.h"
#import "CADOrderListItem.h"

@interface CADAccountViewController ()

@end

@implementation CADAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"我";
    self.user = CADUserManager.sharedInstance.getUser;
    
    self.afm = [AFHTTPSessionManager manager];
    
    // hide empty cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self getUserInfo];
    
    // 结束时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow: +(24 * 60 * 60)];
    self.tomorrow = [dateFormatter stringFromDate:tmpDate];
    
    [self getOrderListFrom:@"2015-01-01" to:self.tomorrow];
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
                    
                    [CADUserManager.sharedInstance setUser:user];
                    self.user = user;
                    
                    [self.tableView reloadData];
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
 * 获取所有订单列表
 */
- (void)getOrderListFrom:(NSString *)fromDateString to:(NSString *)toDateString{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','phone':'%@','startDate':'%@','endDate':'%@'}",self.timeStamp,[Utils md5:beforeMd5],self.user.phone,fromDateString,toDateString]};
            
            [self.afm POST:kOrderListJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取订单信息错误" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
//                    NSLog(@"JSON: %@", responseObject);
                    NSArray *listArray = [responseObject objectForKey:@"list"];
                    
                    self.orders = [[NSMutableArray alloc] init];
                    for (int i=0; i < listArray.count; i++) {
                        NSDictionary *item = (NSDictionary *)[listArray objectAtIndex:i];
                        CADOrderListItem *orderItem = [[CADOrderListItem alloc] init];
                        [orderItem setCreateTime:[item objectForKey:@"createTime"]];
                        [orderItem setFpPrintYn:[item objectForKey:@"fpPrintYn"]];
                        [orderItem setOrderId:[item objectForKey:@"orderId"]];
                        [orderItem setOrderSeq:[item objectForKey:@"orderSeq"]];
                        [orderItem setOrderStatus:[item objectForKey:@"orderStatus"]];
                        [orderItem setOrderTitle:[item objectForKey:@"orderTitle"]];
                        [orderItem setRemainTime:[[item objectForKey:@"remainTime"] intValue]];
                        [orderItem setSiteTimeList:[item objectForKey:@"siteTimeList"]];
                        [orderItem setTotalMoney:[item objectForKey:@"totalMoney"]];
                        [orderItem setZflx:[item objectForKey:@"zflx"]];
                        [orderItem setSportId:[item objectForKey:@"sportId"]];
                        [orderItem setSportTypeId:[item objectForKey:@"sportTypeId"]];
                        [orderItem setSportTypeName:[item objectForKey:@"sportTypeName"]];
                        [orderItem setSportTypeSmallImage:[item objectForKey:@"sportTypeSmallImage"]];
                        
                        [self.orders addObject:orderItem];
                    }
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取订单信息错误" setMessage:[error localizedDescription]];
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
 * 订单统计
 * 待支付 待消费 已消费 退款
 */
- (void) statistics{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
        case 1:
        case 2:
            return 1;
            break;
            
        default:
            break;
    }
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    UITableViewCell* cell = nil;
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row ==0){
                CADAccountDetailCell *detailsCell = [tableView dequeueReusableCellWithIdentifier:@"CADAccountDetailCell"];
                if(detailsCell == nil)
                    detailsCell = [CADAccountDetailCell makeCell];
                
                NSString *imgUrl = [[NSString alloc] initWithFormat:@"%@%@",KImageUrl,self.user.imgUrl ];
                [detailsCell.icon sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
                detailsCell.fee.text = [[NSString alloc] initWithFormat:@"余额：%@元", (self.user.fee == nil)?@"":self.user.fee];
                detailsCell.score.text = [[NSString alloc] initWithFormat:@"积分：%@", (self.user.score==nil)?@"":self.user.score ];
                detailsCell.name.text = self.user.name;
                
                cell = detailsCell;
            }
            break;
            
        case 1:
            if (indexPath.row == 0) {
                CADAccountLogoutCell *logoutCell = [tableView dequeueReusableCellWithIdentifier:@"CADAccountLogoutCell"];
                if (logoutCell == nil)
                    logoutCell = [CADAccountLogoutCell makeCell];
                
                cell = logoutCell;
            }
            
        default:
            break;
    }
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A much nicer way to deal with this would be to extract this code to a factory class, that would return the cells' height.
    CGFloat height = 0;
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                height = 120;
            }
            break;
        }
        default:
        {
            height = 44;
            break;
        }
    }
    
    return height;
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

@end
