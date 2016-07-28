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
#import "CADChangePasswordController.h"

NSString *const kCADAccountNormalCellIdentifier = @"CADAccountNormalCell";
NSString *const kCADAccountNormalCellNibName = @"CADAccountNormalCell";



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
    
    [self.tableView registerNib:[UINib nibWithNibName:kCADAccountNormalCellNibName bundle:nil] forCellReuseIdentifier:kCADAccountNormalCellIdentifier];
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"user"];
    CADUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (user == nil){
        [self.navigationController popViewControllerAnimated:true];
        return;
    }
    
    // 每次都要获取用户最新信息
    [self getUserInfo];
    
    // 结束时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow: +(24 * 60 * 60)];
    self.tomorrow = [dateFormatter stringFromDate:tmpDate];
    
    [self getOrderStatusFrom:@"2015-01-01" to:self.tomorrow];

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
- (void)getOrderStatusFrom:(NSString *)fromDateString to:(NSString *)toDateString{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','phone':'%@','startDate':'%@','endDate':'%@'}",self.timeStamp,[Utils md5:beforeMd5],self.user.phone,fromDateString,toDateString]};
            
            [self.afm POST:kOrderStatusJsonUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                if ([[responseObject objectForKey:@"success"] intValue] == NO){
                    
                    NSString* errmsg = [responseObject objectForKey:@"msg"];
                    [CADAlertManager showAlert:self setTitle:@"获取订单状态错误" setMessage:errmsg];
                    
                } else if ([[responseObject objectForKey:@"success"] intValue] == YES){
                    //                    NSLog(@"JSON: %@", responseObject);
                    self.orderStatus = [responseObject objectForKey:@"list"];
                    
                    NSArray *indexPathArray = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil];
                    [self.tableView  reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取订单状态错误" setMessage:[error localizedDescription]];
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
    return 3;
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
                [detailsCell.icon sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"defaultTrainerImage"]];
                detailsCell.fee.text = [[NSString alloc] initWithFormat:@"余额：%@元", (self.user.fee == nil)?@"":self.user.fee];
                detailsCell.score.text = [[NSString alloc] initWithFormat:@"积分：%@", (self.user.score==nil)?@"":self.user.score ];
                detailsCell.name.text = self.user.name;
                
                if (self.orderStatus != nil && self.orderStatus.count > 0){
                    detailsCell.status1name.text = [[self.orderStatus objectAtIndex:0] objectForKey:@"code_desc"];
                    detailsCell.status1value.text = [[[self.orderStatus objectAtIndex:0] objectForKey:@"count"] stringValue];
                    detailsCell.status2name.text = [[self.orderStatus objectAtIndex:1] objectForKey:@"code_desc"];
                    detailsCell.status2value.text = [[[self.orderStatus objectAtIndex:1] objectForKey:@"count"] stringValue];
                    detailsCell.status3name.text = [[self.orderStatus objectAtIndex:2] objectForKey:@"code_desc"];
                    detailsCell.status3value.text = [[[self.orderStatus objectAtIndex:2] objectForKey:@"count"] stringValue];
                    detailsCell.status4name.text = [[self.orderStatus objectAtIndex:3] objectForKey:@"code_desc"];
                    detailsCell.status4value.text = [[[self.orderStatus objectAtIndex:3] objectForKey:@"count"] stringValue];
                } else {
                    detailsCell.status1name.text = @"待支付";
                    detailsCell.status1value.text = @"0";
                    detailsCell.status2name.text = @"待消费";
                    detailsCell.status2value.text = @"0";
                    detailsCell.status3name.text = @"已消费";
                    detailsCell.status3value.text = @"0";
                    detailsCell.status4name.text = @"退款";
                    detailsCell.status4value.text = @"0";
                }
                cell = detailsCell;
            }
            break;
            
        case 1:
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:kCADAccountNormalCellIdentifier];
                cell.textLabel.text = @"修改密码";
            }
            break;
        case 2:
            if (indexPath.row == 0) {
//                CADAccountLogoutCell *logoutCell = [tableView dequeueReusableCellWithIdentifier:@"CADAccountLogoutCell"];
//                if (logoutCell == nil)
//                    logoutCell = [CADAccountLogoutCell makeCell];
//                
//                cell = logoutCell;
                
                cell = [tableView dequeueReusableCellWithIdentifier:kCADAccountNormalCellIdentifier];
                cell.textLabel.text = @"退出登录";
            }
            break;
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
                height = 155;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            
            break;
        case 1:
            if (indexPath.row == 0) {
                CADChangePasswordController * vc = (CADChangePasswordController *)[CADStoryBoardUtilities viewControllerForStoryboardName:@"ChangePassword" class:[CADChangePasswordController class]];
                
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case 2:
            if (indexPath.row == 0) {
                NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                [defaults removeObjectForKey:@"user"];
                [[CADUserManager sharedInstance] setUser:nil];
                
                [self.navigationController popViewControllerAnimated:true];
            }
            break;
            
        default:
            break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
